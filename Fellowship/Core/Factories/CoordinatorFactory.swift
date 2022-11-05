//
//  CoordinatorFactory.swift
//  Fellowship
//
//  Created by Hardik Patel on 11/1/22.
//

import Foundation
import SwiftKeychainWrapper

class CoordinatorFactory {
  private let httpClient = DefaultHttpClient()
  private lazy var userSession = makeUserSession()
  private lazy var oauthClient = makeTwitterOAuthClient()
  private lazy var authHttpClient = makeAuthHttpClient()
  private lazy var factory = makeViewControllerFactory()
}

extension CoordinatorFactory {
  func makeAppCoordinator(with router: Router) -> AppCoordinator {
    let appCoordinator = AppCoordinator(
      router: router, userSession: userSession, coordinatorFactory: self
    )
    return appCoordinator
  }
}

extension CoordinatorFactory {
  func makeAuthCoordinator(with router: Router) -> AuthCoordinator {
    return AuthCoordinator(router: router, factory: factory)
  }
}

extension CoordinatorFactory {
  func makeMainCoordinator(with router: Router) -> MainCoordinator {
    return MainCoordinator(router: router, factory: factory)
  }
}

extension CoordinatorFactory {
  
  private func makeUserSession() -> UserSession {
    return UserSession(
      storage: UserDefaults.standard,
      keychain: KeychainWrapper.standard
    )
  }
  
  private func makeTwitterOAuthClient() -> OAuthClient {
    let oauthClient = DefaultOAuthClient(
      authHost: "twitter.com", authPath: "/i/oauth2/authorize",
      tokenHost: "api.twitter.com", tokenPath: "/2/oauth2/token",
      clientID: "VzVmR0g0R0xpS1JNZ3k0WWdZYWk6MTpjaQ",
      redirectURI: "fellowship://oauth",
      scope: "tweet.read users.read follows.read offline.access"
    )
    return oauthClient
  }
  
  private func makeAuthHttpClient() -> AuthHttpClient {
    let authHttpClient = DefaultAuthHttpClient(
      httpClient: httpClient,
      userSession: userSession
    )
    return authHttpClient
  }
  
  private func makeViewControllerFactory() -> ViewControllerFactory {
    let vcFactory = ViewControllerFactory(
      userSession: userSession,
      httpClient: httpClient,
      authHttpClient: authHttpClient,
      oauthClient: oauthClient
    )
    return vcFactory
  }
}

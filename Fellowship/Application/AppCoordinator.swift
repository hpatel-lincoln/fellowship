//
//  AppCoordinator.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import UIKit

class AppCoordinator: NavigationCoordinator {
  private(set) var hasStarted: Bool = false
  private(set) var coordinator: Coordinator?
  private(set) var router: Router
  private let userSession = UserSession.shared
  
  private lazy var httpClient = DefaultHttpClient()
  private lazy var oauthClient = makeTwitterOAuthClient()
  private lazy var authHttpClient = makeAuthHttpClient()
  private lazy var vcFactory = makeViewControllerFactory()
  
  init(router: Router) {
    self.router = router
  }
  
  func start(with link: DeepLink?) {
    if hasStarted {
      coordinator?.start(with: link)
    } else {
      if userSession.isLoggedIn {
        startMainFlow(with: link)
      } else {
        startAuthFlow(with: link)
      }
      self.hasStarted = true
    }
  }
  
  private func startMainFlow(with link: DeepLink?) {
    let mainCoordinator = MainCoordinator(
      router: router,
      viewControllerFactory: vcFactory
    )
    coordinator = mainCoordinator
    coordinator?.start(with: link)
  }
  
  private func startAuthFlow(with link: DeepLink?) {
    let authCoordinator = AuthCoordinator(
      router: router,
      viewControllerFactory: vcFactory
    )
    authCoordinator.didCompleteFlow = { [unowned self] in
      coordinator = nil
      startMainFlow(with: link)
    }
    coordinator = authCoordinator
    coordinator?.start(with: nil)
  }
}

extension AppCoordinator {
  
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

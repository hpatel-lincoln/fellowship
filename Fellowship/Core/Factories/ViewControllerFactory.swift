//
//  ViewControllerFactory.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/31/22.
//

import UIKit

final class ViewControllerFactory:
  AuthFlowViewControllerFactory,
  MainFlowViewControllerFactory
{
  private let userSession = UserSession.shared
  private lazy var httpClient = makeHttpClient()
  private lazy var authHttpClient = makeAuthHttpClient()
  private lazy var twitterOAuthClient = makeTwitterOAuthClient()
  
  // MARK: - Auth Flow
  
  func makeLoginViewController() -> LoginViewController {
    let authStoryboard = UIStoryboard(storyboard: .auth)
    let loginViewController = authStoryboard.instantiateViewController(
      identifier: "\(LoginViewController.self)"
    ) { [unowned self] coder in
      LoginViewController(
        coder: coder,
        userSession: userSession,
        oauthClient: twitterOAuthClient,
        userService: makeUserService()
      )
    }
    return loginViewController
  }
  
  // MARK: - Main Flow
  
  func makeMainViewController() -> MainViewController {
    let mainViewController = MainViewController(
      userSession: userSession,
      httpClient: DefaultHttpClient()
    )
    return mainViewController
  }
  
  // MARK: - Services
  
  private func makeUserService() -> UserService {
    return DefaultUserService(authHttpClient: authHttpClient)
  }
  
  // MARK: - Networking (HttpClient, AuthHttpClient, OAuthClient, etc...)
  
  private func makeHttpClient() -> HttpClient {
    return DefaultHttpClient()
  }
  
  private func makeAuthHttpClient() -> AuthHttpClient {
    let authHttpClient = DefaultAuthHttpClient(
      httpClient: httpClient,
      userSession: userSession
    )
    return authHttpClient
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
}

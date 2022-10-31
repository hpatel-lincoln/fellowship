//
//  AuthCoordinator.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import UIKit

class AuthCoordinator: NavigationCoordinator {
  private(set) var hasStarted: Bool = false
  private(set) var coordinator: Coordinator?
  private(set) var router: Router
  
  var didCompleteFlow: (() -> Void)?
  
  init(router: Router) {
    self.router = router
  }
  
  func start(with link: DeepLink?) {
    if hasStarted == false {
      showLogin()
      hasStarted = true
    }
  }
  
  private func showLogin() {
    let authStoryboard = UIStoryboard(storyboard: .auth)
    let loginViewController = authStoryboard.instantiateViewController(
      identifier: "\(LoginViewController.self)"
    ) { coder in
      LoginViewController(
        coder: coder,
        userSession: UserSession.shared,
        oauthClient: self.makeTwitterOAuthClient(),
        userService: self.makeUserService()
      )
    }
    loginViewController.didCompleteLogin = didCompleteFlow
    router.setRootController(loginViewController)
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
  
  private func makeUserService() -> UserService {
    let authHttpClient = DefaultAuthHttpClient(
      httpClient: DefaultHttpClient(),
      userSession: UserSession.shared
    )
    return UserService(authHttpClient: authHttpClient)
  }
}

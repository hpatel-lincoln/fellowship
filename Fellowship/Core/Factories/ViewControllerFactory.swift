//
//  ViewControllerFactory.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/31/22.
//

import UIKit

final class ViewControllerFactory {
  
  private let userSession: UserSession
  private let httpClient: HttpClient
  private let authHttpClient: AuthHttpClient
  private let oauthClient: OAuthClient
  
  init(
    userSession: UserSession,
    httpClient: HttpClient,
    authHttpClient: AuthHttpClient,
    oauthClient: OAuthClient
  ) {
    self.userSession = userSession
    self.httpClient = httpClient
    self.authHttpClient = authHttpClient
    self.oauthClient = oauthClient
  }
}

// MARK: - Auth Flow
extension ViewControllerFactory: AuthFlowViewControllerFactory {
  func makeLoginViewController() -> LoginViewController {
    let authStoryboard = UIStoryboard(storyboard: .auth)
    let loginViewController = authStoryboard.instantiateViewController(
      identifier: "\(LoginViewController.self)"
    ) { [unowned self] coder in
      LoginViewController(
        coder: coder,
        userSession: userSession,
        oauthClient: oauthClient,
        userService: makeUserService()
      )
    }
    return loginViewController
  }
}

// MARK: - Main Flow
extension ViewControllerFactory: MainFlowViewControllerFactory {
  func makeMainViewController() -> MainViewController {
    let mainViewController = MainViewController(
      userSession: userSession,
      httpClient: httpClient
    )
    return mainViewController
  }
}

// MARK: - Services
extension ViewControllerFactory {
  private func makeUserService() -> UserService {
    return DefaultUserService(authHttpClient: authHttpClient)
  }
}

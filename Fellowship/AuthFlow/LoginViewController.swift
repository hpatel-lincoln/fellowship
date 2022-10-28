//
//  LoginViewController.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/27/22.
//

import UIKit
import PromiseKit
import AuthenticationServices

class LoginViewController: UIViewController {
  
  var didCompleteLogin: (() -> Void)?
  
  private let userSession = UserSession.shared
  private lazy var authClient = makeTwitterAuthClient()
  private lazy var userService = makeUserService()
  
  @IBAction
  private func didTapLogin(_ sender: UIButton) {
    firstly {
      authClient.authenticate()
    }.then { authToken -> Promise<User> in
      self.userSession.setToken(authToken)
      return self.userService.getUser()
    }.done { [weak self] user in
      guard let self = self else { return }
      self.userSession.loginUser(user)
      self.didCompleteLogin?()
    }.catch { error in
      print(error)
    }
  }
  
  private func makeTwitterAuthClient() -> OAuthClient {
    let authClient = DefaultOAuthClient(
      authHost: "twitter.com", authPath: "/i/oauth2/authorize",
      tokenHost: "api.twitter.com", tokenPath: "/2/oauth2/token",
      clientID: "VzVmR0g0R0xpS1JNZ3k0WWdZYWk6MTpjaQ",
      redirectURI: "fellowship://oauth",
      scope: "tweet.read users.read follows.read offline.access",
      delegate: self
    )
    return authClient
  }
  
  private func makeUserService() -> UserService {
    let authHttpClient = DefaultAuthHttpClient(
      httpClient: DefaultHttpClient(),
      userSession: UserSession.shared
    )
    return UserService(authHttpClient: authHttpClient)
  }
}

extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    view.window ?? ASPresentationAnchor()
  }
}

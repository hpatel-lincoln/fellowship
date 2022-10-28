//
//  ViewController.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/27/22.
//

import UIKit
import PromiseKit
import AuthenticationServices

class ViewController: UIViewController {
  
  private let userSession = UserSession.shared
  private lazy var authClient = makeTwitterAuthClient()
  private lazy var userService = makeUserService()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  @IBAction
  func didTapLogin(_ sender: UIButton) {
    firstly {
      authClient.authenticate()
    }.then { authToken -> Promise<User> in
      self.userSession.setToken(authToken)
      return self.userService.getUser()
    }.done { user in
      self.userSession.loginUser(user)
      print(user)
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

extension ViewController: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    view.window ?? ASPresentationAnchor()
  }
}

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
  
  private lazy var authClient = makeTwitterAuthClient()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  @IBAction
  func didTapLogin(_ sender: UIButton) {
    firstly {
      authClient.authenticate()
    }.done { code in
      print(code)
    }.catch { error in
      print(error)
    }
  }
  
  private func makeTwitterAuthClient() -> DefaultOAuthClient {
    authClient = DefaultOAuthClient(
      authHost: "twitter.com", authPath: "/i/oauth2/authorize",
      tokenHost: "api.twitter.com", tokenPath: "/2/oauth2/token",
      clientID: "VzVmR0g0R0xpS1JNZ3k0WWdZYWk6MTpjaQ",
      redirectURI: "fellowship://oauth",
      scope: "tweet.read users.read follows.read",
      delegate: self
    )
    return authClient
  }
}

extension ViewController: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    view.window ?? ASPresentationAnchor()
  }
}

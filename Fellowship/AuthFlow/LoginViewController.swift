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
  
  private var loggingIn: Bool = false {
    didSet {
      loginButton.setNeedsUpdateConfiguration()
    }
  }
  
  @IBOutlet var coverImageView: UIImageView!
  @IBOutlet var coverImageViewBottom: NSLayoutConstraint!
  @IBOutlet var loginButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCoverImageView()
    setupLoginButton()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animateCoverImageView()
  }
  
  private func setupCoverImageView() {
    coverImageView.image = UIImage(named: "twitter")?
      .withRenderingMode(.alwaysTemplate)
    coverImageView.tintColor = view.tintColor
    coverImageView.layer.cornerRadius = 16
    coverImageViewBottom.constant = 16
  }
  
  private func setupLoginButton() {
    var buttonConfiguration = UIButton.Configuration.filled()
    buttonConfiguration.buttonSize = .large
    buttonConfiguration.cornerStyle = .medium
    
    buttonConfiguration.titleTextAttributesTransformer =
      UIConfigurationTextAttributesTransformer { input in
        var output = input
        output.font = .preferredFont(forTextStyle: .headline)
        return output
      }
    
    buttonConfiguration.image = UIImage(systemName: "chevron.right")
    buttonConfiguration.imagePadding = 8
    buttonConfiguration.imagePlacement = .trailing
    buttonConfiguration.preferredSymbolConfigurationForImage =
      UIImage.SymbolConfiguration(scale: .medium)
    
    loginButton.configuration = buttonConfiguration
    
    loginButton.configurationUpdateHandler = { [unowned self] button in
      var configuration = button.configuration
      configuration?.showsActivityIndicator = loggingIn
      configuration?.imagePlacement = loggingIn ? .leading : .trailing
      configuration?.title = loggingIn ? "Logging In..." : "Login"
      button.isEnabled = !loggingIn
      button.configuration = configuration
    }
  }
  
  private func animateCoverImageView() {
    coverImageViewBottom.constant = 96
    UIView.animate(withDuration: 0.5) { [weak self] in
      self?.view.layoutIfNeeded()
    }
  }
  
  @IBAction
  private func onLoginTap(_ sender: UIButton) {
    loggingIn = true
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
    }.finally { [weak self] in
      self?.loggingIn = false
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

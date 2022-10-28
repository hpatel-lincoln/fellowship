//
//  AuthCoordinator.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import Foundation

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
    let loginViewController = LoginViewController.controllerFromStoryboard(.auth)
    loginViewController.didCompleteLogin = didCompleteFlow
    router.setRootController(loginViewController)
  }
}

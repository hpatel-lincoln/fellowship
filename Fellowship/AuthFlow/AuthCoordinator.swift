//
//  AuthCoordinator.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import Foundation

class AuthCoordinator: NavigationCoordinator {
  
  var didCompleteFlow: (() -> Void)?
  
  private(set) var hasStarted: Bool = false
  private(set) var coordinator: Coordinator?
  private(set) var router: Router
  private let factory: AuthFlowViewControllerFactory
  
  init(
    router: Router,
    factory: AuthFlowViewControllerFactory
  ) {
    self.router = router
    self.factory = factory
  }
  
  func start(with link: DeepLink?) {
    if hasStarted == false {
      showLogin()
      hasStarted = true
    }
  }
  
  private func showLogin() {
    let loginViewController = factory.makeLoginViewController()
    loginViewController.didCompleteLogin = didCompleteFlow
    router.setRootController(loginViewController, hideBar: true)
  }
}

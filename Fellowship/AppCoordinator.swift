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
  private let userSession: UserSession
  
  init(router: Router) {
    self.router = router
    userSession = UserSession.shared
  }
  
  func start(with link: DeepLink?) {
    if hasStarted {
      coordinator?.start(with: link)
    } else {
      if userSession.isLoggedIn {
        startMainFlow(with: link)
        self.hasStarted = true
      } else {
        startAuthFlow(with: link)
        self.hasStarted = true
      }
    }
  }
  
  private func startMainFlow(with link: DeepLink?) {
    let controller = UIViewController()
    controller.view.backgroundColor = .green
    router.setRootController(controller, hideBar: true)
  }
  
  private func startAuthFlow(with link: DeepLink?) {
    let controller = UIViewController()
    controller.view.backgroundColor = .red
    router.setRootController(controller, hideBar: true)
  }
}

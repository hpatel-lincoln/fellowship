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
  private let viewControllerFactory: ViewControllerFactory = ViewControllerFactory()
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
    let mainCoordinator = MainCoordinator(
      router: router,
      viewControllerFactory: viewControllerFactory
    )
    coordinator = mainCoordinator
    coordinator?.start(with: link)
  }
  
  private func startAuthFlow(with link: DeepLink?) {
    let authCoordinator = AuthCoordinator(
      router: router,
      viewControllerFactory: viewControllerFactory
    )
    authCoordinator.didCompleteFlow = { [unowned self] in
      coordinator = nil
      startMainFlow(with: link)
    }
    coordinator = authCoordinator
    coordinator?.start(with: nil)
  }
}

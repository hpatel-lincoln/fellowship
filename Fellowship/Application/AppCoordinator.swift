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
  private let coordinatorFactory: CoordinatorFactory
  
  init(
    router: Router,
    userSession: UserSession,
    coordinatorFactory: CoordinatorFactory
  ) {
    self.router = router
    self.userSession = userSession
    self.coordinatorFactory = coordinatorFactory
  }
  
  func start(with link: DeepLink?) {
    if hasStarted {
      coordinator?.start(with: link)
    } else {
      if userSession.isLoggedIn {
        startMainFlow(with: link)
      } else {
        startAuthFlow(with: link)
      }
      self.hasStarted = true
    }
  }
  
  private func startMainFlow(with link: DeepLink?) {
    let mainCoordinator = coordinatorFactory.makeMainCoordinator(with: router)
    mainCoordinator.didCompleteFlow = { [unowned self] in
      userSession.logout()
      coordinator = nil
      startAuthFlow(with: .loggedOut)
    }
    coordinator = mainCoordinator
    coordinator?.start(with: link)
  }
  
  private func startAuthFlow(with link: DeepLink?) {
    let authCoordinator = coordinatorFactory.makeAuthCoordinator(with: router)
    authCoordinator.didCompleteFlow = { [unowned self] in
      coordinator = nil
      startMainFlow(with: link)
    }
    coordinator = authCoordinator
    coordinator?.start(with: link)
  }
}

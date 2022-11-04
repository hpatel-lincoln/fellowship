//
//  MainCoordinator.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/31/22.
//

import Foundation

class MainCoordinator: NavigationCoordinator {
  
  var didCompleteFlow: (() -> Void)?
  
  private(set) var hasStarted: Bool = false
  private(set) var coordinator: Coordinator?
  private(set) var router: Router
  private let factory: MainFlowViewControllerFactory
  
  init(
    router: Router,
    factory: MainFlowViewControllerFactory
  ) {
    self.router = router
    self.factory = factory
  }
  
  func start(with link: DeepLink?) {
    if hasStarted == false {
      showMain()
      hasStarted = true
    }
  }
  
  private func showMain() {
    let mainViewController = factory.makeMainViewController()
    router.setRootController(mainViewController, hideBar: true)
  }
}

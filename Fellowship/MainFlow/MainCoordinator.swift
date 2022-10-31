//
//  MainCoordinator.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/31/22.
//

import Foundation

class MainCoordinator: NavigationCoordinator {
  private(set) var hasStarted: Bool = false
  private(set) var coordinator: Coordinator?
  private(set) var router: Router
  
  var didCompleteFlow: (() -> Void)?
  
  init(router: Router) {
    self.router = router
  }
  
  func start(with link: DeepLink?) {
    if hasStarted == false {
      showMain()
      hasStarted = true
    }
  }
  
  private func showMain() {
    let mainViewController = MainViewController(
      userSession: UserSession.shared,
      httpClient: DefaultHttpClient()
    )
    router.setRootController(mainViewController)
  }
}

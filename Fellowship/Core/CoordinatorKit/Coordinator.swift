//
//  Coordinator.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import Foundation

protocol Coordinator: AnyObject {
  func start(with link: DeepLink?)
}

protocol NavigationCoordinator: Coordinator {
  var hasStarted: Bool { get }
  var coordinator: Coordinator? { get }
  var router: Router { get }
}

protocol TabBarCoordinator: Coordinator {
  var coordinators: [Int: Coordinator] { get }
}

protocol PresentingCoordinator {
  func dismiss()
}

protocol PresentedCoordinator { }

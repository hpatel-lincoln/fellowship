//
//  Router.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import UIKit

protocol Router {
  
  func setRootController(_ controller: UIViewController)
  func setRootController(_ controller: UIViewController, hideBar: Bool)
  
  func present(_ controller: UIViewController)
  func present(_ controller: UIViewController, animated: Bool, completion: (() -> Void)?)
  
  func dismissController()
  func dismissController(animated: Bool, completion: (() -> Void)?)
  
  func push(_ controller: UIViewController)
  func push(_ controller: UIViewController, animated: Bool)
  func push(_ controller: UIViewController, hideBottomBar: Bool)
  func push(_ controller: UIViewController, animated: Bool, completion: (() -> Void)?)
  func push(_ controller: UIViewController, animated: Bool, hideBottomBar: Bool, completion: (() -> Void)?)
  
  func popController()
  func popController(animated: Bool)
  
  func popToRootController(animated: Bool)
}

final class RouterImp: NSObject, Router {
  
  private var rootController: UINavigationController
  private var completions: [UIViewController : () -> Void]
  
  init(rootController: UINavigationController) {
    self.rootController = rootController
    completions = [:]
    super.init()
    self.rootController.delegate = self
  }
  
  func setRootController(_ controller: UIViewController) {
    setRootController(controller, hideBar: false)
  }
  
  func setRootController(_ controller: UIViewController, hideBar: Bool) {
    rootController.setViewControllers([controller], animated: false)
    rootController.isNavigationBarHidden = hideBar
  }
  
  func present(_ controller: UIViewController) {
    present(controller, animated: true, completion: nil)
  }
  
  func present(_ controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
    if controller is UINavigationController {
      controller.presentationController?.delegate = self
    }
    if let completion = completion {
      completions[controller] = completion
    }
    rootController.present(controller, animated: animated, completion: nil)
  }
  
  func dismissController() {
    dismissController(animated: true, completion: nil)
  }
  
  func dismissController(animated: Bool, completion: (() -> Void)?) {
    rootController.dismiss(animated: animated, completion: completion)
  }
  
  func push(_ controller: UIViewController)  {
    push(controller, animated: true)
  }
  
  func push(_ controller: UIViewController, hideBottomBar: Bool)  {
    push(controller, animated: true, hideBottomBar: hideBottomBar, completion: nil)
  }
  
  func push(_ controller: UIViewController, animated: Bool)  {
    push(controller, animated: animated, completion: nil)
  }
  
  func push(_ controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
    push(controller, animated: animated, hideBottomBar: false, completion: completion)
  }
  
  func push(_ controller: UIViewController, animated: Bool, hideBottomBar: Bool, completion: (() -> Void)?) {
    guard
      (controller is UINavigationController == false)
    else {
      assertionFailure("Deprecated push UINavigationController.")
      return
    }
    
    if let completion = completion {
      completions[controller] = completion
    }
    controller.hidesBottomBarWhenPushed = hideBottomBar
    rootController.pushViewController(controller, animated: animated)
  }
  
  func popController()  {
    popController(animated: true)
  }
  
  func popController(animated: Bool)  {
    if let controller = rootController.popViewController(animated: animated) {
      runCompletion(for: controller)
    }
  }
  
  func popToRootController(animated: Bool) {
    if let controllers = rootController.popToRootViewController(animated: animated) {
      controllers.forEach { controller in
        runCompletion(for: controller)
      }
    }
  }
  
  private func runCompletion(for controller: UIViewController) {
    guard let completion = completions[controller] else { return }
    completion()
    completions.removeValue(forKey: controller)
  }
}

extension RouterImp: UINavigationControllerDelegate {
  
  func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    guard
      let prevController = rootController.transitionCoordinator?.viewController(forKey: .from),
      rootController.viewControllers.contains(prevController) == false
    else { return }
    runCompletion(for: prevController)
  }
}

extension RouterImp: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    let presentedController = presentationController.presentedViewController
    runCompletion(for: presentedController)
  }
}

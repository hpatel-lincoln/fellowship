//
//  MainFlowViewControllerFactory.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/31/22.
//

import Foundation

protocol MainFlowViewControllerFactory {
  
  ///  Return an instance of MainViewController
  func makeMainViewController() -> MainViewController
}

//
//  AuthFlowViewControllerFactory.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/31/22.
//

import Foundation

protocol AuthFlowViewControllerFactory {
  
  /// Return an instance of LoginViewController
  func makeLoginViewController() -> LoginViewController
}

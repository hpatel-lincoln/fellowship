//
//  UserService.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import Foundation
import PromiseKit

protocol UserService {
  
  /// Get current user associated with the access token
  func getUser() -> Promise<User>
}

//
//  UserSession.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import Foundation

class UserSession {
  
  private var authToken: OAuthToken?
  private var user: User?
  
  private let queue = DispatchQueue(label: "com.example.Fellowship.UserSession",
                                    attributes: .concurrent)
  
  var isLoggedIn: Bool {
    queue.sync {
      return user != nil
    }
  }
  
  var currentUser: User? {
    queue.sync {
      return user
    }
  }
  
  var tokenType: String? {
    queue.sync {
      return authToken?.type
    }
  }
  
  var accessToken: String? {
    queue.sync {
      return authToken?.accessToken
    }
  }
  
  var refreshToken: String? {
    queue.sync {
      return authToken?.refreshToken
    }
  }
  
  func setToken(_ token: OAuthToken) {
    queue.async(flags: .barrier) {
      self.authToken = token
    }
  }
  
  func loginUser(_ user: User) {
    guard authToken != nil else { return }
    queue.async(flags: .barrier) {
      self.user = user
    }
  }
  
  func logout() {
    queue.async(flags: .barrier) {
      self.user = nil
      self.authToken = nil
    }
  }
}

//
//  UserSession.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import Foundation
import SwiftKeychainWrapper

class UserSession {
  
  private struct Constants {
    static let UserKey = "com.example.fellowship.user"
    static let RefreshTokenKey = "com.example.fellowship.refreshtoken"
    static let QueueLabel = "com.example.fellowship.usersession"
  }
  
  private var authToken: OAuthToken?
  
  private(set) var currentUser: User? {
    get { loadUser() }
    set { saveUser(newValue) }
  }
  
  private let queue = DispatchQueue(label: Constants.QueueLabel, attributes: .concurrent)
  
  private let storage: UserDefaults
  private let keychain: KeychainWrapper
  
  init(storage: UserDefaults, keychain: KeychainWrapper) {
    self.storage = storage
    self.keychain = keychain
  }
  
  var isLoggedIn: Bool {
    queue.sync {
      return currentUser != nil
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
      if let refreshToken = authToken?.refreshToken {
        return refreshToken
      } else if let refreshToken = keychain.string(forKey: Constants.RefreshTokenKey) {
        return refreshToken
      } else {
        return nil
      }
    }
  }
  
  var issueDate: Date? {
    queue.sync {
      return authToken?.issueDate
    }
  }
  
  func setToken(_ token: OAuthToken) {
    queue.async(flags: .barrier) {
      self.authToken = token
      self.keychain.set(token.refreshToken, forKey: Constants.RefreshTokenKey)
    }
  }
  
  func loginUser(_ user: User) {
    guard authToken != nil else { return }
    queue.async(flags: .barrier) {
      self.currentUser = user
    }
  }
  
  func logout() {
    queue.async(flags: .barrier) {
      self.currentUser = nil
      self.authToken = nil
      self.keychain.removeObject(forKey: Constants.RefreshTokenKey)
    }
  }
  
  private func loadUser() -> User? {
    guard
      let userData = storage.object(forKey: Constants.UserKey) as? Data,
      let user = try? JSONDecoder().decode(User.self, from: userData)
    else {
      return nil
    }
    return user
  }
  
  private func saveUser(_ user: User?) {
    let userData = try? JSONEncoder().encode(user)
    storage.setValue(userData, forKey: Constants.UserKey)
  }
}

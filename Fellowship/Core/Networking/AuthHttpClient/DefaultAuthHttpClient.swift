//
//  DefaultAuthHttpClient.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import Foundation
import PromiseKit

class DefaultAuthHttpClient: AuthHttpClient {
  
  private typealias Injected = (authRequest: HttpRequest, injectionDate: Date)
  
  private struct Constants {
    static let AuthorizationHeaderKey = "Authorization"
    static let AuthQueueLabel = "com.example.Fellowship.AuthHttpClient"
  }
  
  private let httpClient: HttpClient
  private let userSession: UserSession
  private let oauthClient: OAuthClient
  
  private let authQueue = DispatchQueue(
    label: Constants.AuthQueueLabel, qos: .background, attributes: .concurrent
  )
  private let lock = NSLock()
  
  init(
    httpClient: HttpClient,
    userSession: UserSession,
    oauthClient: OAuthClient
  ) {
    self.httpClient = httpClient
    self.userSession = userSession
    self.oauthClient = oauthClient
  }
  
  func perform(request: HttpRequest, withRetries retryCount: Int) -> Promise<Data> {
    var injectionDate = Date.now
    return firstly {
      Guarantee<Void>()
    }.then(on: authQueue) { [unowned self] in
      injectAccessToken(forRequest: request)
    }.then(on: authQueue) { [unowned self] injected -> Promise<Data> in
      injectionDate = injected.injectionDate
      return httpClient.perform(request: injected.authRequest)
    }.recover(on: authQueue) { [unowned self] error -> Promise<Data> in
      guard
        retryCount > 0,
        case NetworkError.unauthorized = error
      else {
        throw error
      }
      
      lock.lock()
      if
        let issueDate = self.userSession.issueDate,
        issueDate.timeIntervalSince(injectionDate) >= 0
      {
        lock.unlock()
        return self.perform(request: request, withRetries: retryCount-1)
      }
      
      guard let refreshToken = self.userSession.refreshToken else {
        lock.unlock()
        throw NetworkError.unauthorized
      }
      
      return firstly {
        oauthClient.refresh(with: refreshToken)
      }.then { authToken -> Promise<Data> in
        self.userSession.setToken(authToken)
        self.lock.unlock()
        return self.perform(request: request, withRetries: retryCount-1)
      }.recover { error -> Promise<Data> in
        self.lock.unlock()
        if case NetworkError.badRequest(_) = error {
          throw NetworkError.unauthorized
        } else {
          throw error
        }
      }
    }
  }
  
  private func injectAccessToken(forRequest request: HttpRequest) -> Promise<Injected> {
    return Promise { seal in
      guard
        let accessToken = userSession.accessToken,
        let tokenType = userSession.tokenType
      else {
        throw NetworkError.unauthorized
      }
      var authRequest = request
      var headers = authRequest.headers ?? [:]
      headers[Constants.AuthorizationHeaderKey] = "\(tokenType) \(accessToken)"
      authRequest.headers = headers
      let injectionDate = Date.now
      let injected = (authRequest, injectionDate)
      return seal.fulfill(injected)
    }
  }
}

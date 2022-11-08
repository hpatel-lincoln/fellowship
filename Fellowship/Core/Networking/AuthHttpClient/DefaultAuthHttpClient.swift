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
      // Retry count must be more than 0 and response status code
      // must be 401 in order to proceed refreshing token.
      guard
        retryCount > 0,
        case NetworkError.unauthorized = error
      else {
        throw error
      }
      
      //
      lock.lock()
      
      // If access token issue date is more recent than the date when
      // access token was injected for the request, a new token must be
      // available. We should retry without having to refresh token.
      if
        let issueDate = self.userSession.issueDate,
        issueDate.timeIntervalSince(injectionDate) >= 0
      {
        lock.unlock()
        return self.perform(request: request, withRetries: retryCount-1)
      }
      
      // If refresh token isn't availabe from the keychain,
      // throw unauthorized error.
      guard let refreshToken = self.userSession.refreshToken else {
        lock.unlock()
        throw NetworkError.unauthorized
      }
      
      // Start refresh token process
      return firstly {
        oauthClient.refresh(with: refreshToken)
      }.then { authToken -> Promise<Data> in
        // Set tokens in UserSession and retry
        self.userSession.setToken(authToken)
        self.lock.unlock()
        return self.perform(request: request, withRetries: retryCount-1)
      }.recover { error -> Promise<Data> in
        // Sadly, Twitter returns 400 in-case the refresh token is invalid.
        // Map status code 400 to unauthorized error.
        self.lock.unlock()
        switch error {
        case let NetworkError.badRequest(code) where code == 400:
          throw NetworkError.unauthorized
        default:
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

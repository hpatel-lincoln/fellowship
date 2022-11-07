//
//  DefaultAuthHttpClient.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import Foundation
import PromiseKit

class DefaultAuthHttpClient: AuthHttpClient {
  
  private struct Constants {
    static let AuthorizationHeaderKey = "Authorization"
  }
  
  private let httpClient: HttpClient
  private let userSession: UserSession
  private let oauthClient: OAuthClient
  
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
    var authRequest: HttpRequest = request
    
    return firstly {
      injectAccessToken(forRequest: request)
    }.then { request -> Promise<Data> in
      authRequest = request
      return self.httpClient.perform(request: request)
    }.recover { error -> Promise<Data> in
      guard retryCount > 0 else {
        throw error
      }
      
      guard let refreshToken = self.userSession.refreshToken else {
        throw NetworkError.unauthorized
      }
      
      if case NetworkError.unauthorized = error {
        return firstly {
          self.oauthClient.refresh(with: refreshToken)
        }.then { authToken -> Promise<Data> in
          self.userSession.setToken(authToken)
          return self.perform(request: authRequest, withRetries: retryCount-1)
        }
      } else {
        throw error
      }
    }
  }
  
  private func injectAccessToken(forRequest request: HttpRequest) -> Promise<HttpRequest> {
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
      return seal.fulfill(authRequest)
    }
  }
}

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
  
  init(
    httpClient: HttpClient,
    userSession: UserSession
  ) {
    self.httpClient = httpClient
    self.userSession = userSession
  }
  
  func perform(request: HttpRequest, withRetries retryCount: Int) -> Promise<Data> {
    firstly {
      injectAccessToken(forRequest: request)
    }.then { request in
      self.httpClient.perform(request: request)
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

//
//  DefaultHttpClient.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/27/22.
//

import Foundation
import PromiseKit

class DefaultHttpClient: HttpClient {
  
  func perform(request: HttpRequest) -> Promise<Data> {
    guard let urlRequest = request.makeURLRequest() else {
      return Promise(error: NetworkError.invalidURL)
    }
    
    return firstly {
      URLSession.shared.dataTask(.promise, with: urlRequest)
    }.then {
      self.handle(response: $0.response, data: $0.data)
    }
  }
  
  private func handle(response: URLResponse, data: Data) -> Promise<Data> {
    guard let httpResponse = response as? HTTPURLResponse else {
      return Promise(error: NetworkError.invalidResponse)
    }
    
    switch httpResponse.statusCode {
      // bad status code
    case let code where code < 100 && code >= 600:
      return Promise(error: NetworkError.invalidResponse)
      
      // 4xx
    case 401:
      return Promise(error: NetworkError.unauthorized)
    case 404:
      return Promise(error: NetworkError.notFound)
    case let code where 400..<500 ~= code:
      return Promise(error: NetworkError.badRequest(code: code))
      
      // 5xx
    case 503:
      return Promise(error: NetworkError.maintenance)
    case let code where 500..<600 ~= code:
      return Promise(error: NetworkError.badResponse(code: code))
      
      // 1xx, 2xx, 3xx
    default:
      break
    }
    
    return Promise.value(data)
  }
}

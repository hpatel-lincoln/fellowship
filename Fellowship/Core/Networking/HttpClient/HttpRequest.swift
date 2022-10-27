//
//  HttpRequest.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/27/22.
//

import Foundation

/**
 Http method
 */
enum HttpMethod: String {
  case get        = "GET"
  case post       = "POST"
}

/**
 Http request
 */
struct HttpRequest {
  var host                : String
  var path                : String
  var method              : HttpMethod
  var parameters          : [String: String?]?
  var headers             : [String: String]?
  
  init(host: String,
       path: String,
       method: HttpMethod,
       parameters: [String: String?]?,
       headers: [String: String]?) {
    
    self.host = host
    self.path = path
    self.method = method
    self.parameters = parameters
    self.headers = headers
  }
}

extension HttpRequest {
  
  struct Constants {
    static let Scheme = "https"
    static let AcceptHeaderKey = "Accept"
    static let AcceptHeaderValue = "application/json"
  }
  
  func makeURL() -> URL? {
    var components = URLComponents()
    components.scheme = Constants.Scheme
    components.host = host
    components.path = path
    
    if let parameters = parameters {
      components.queryItems = parameters.map {
        URLQueryItem(name: $0, value: $1)
      }
    }
    
    return components.url
  }
  
  func makeURLRequest() -> URLRequest? {
    guard let url = makeURL() else {
      return nil
    }
    
    var request = URLRequest(url: url)
    
    request.httpMethod = method.rawValue
    
    request.allHTTPHeaderFields = headers ?? [:]
    request.setValue(Constants.AcceptHeaderValue, forHTTPHeaderField: Constants.AcceptHeaderKey)
    
    return request
  }
}

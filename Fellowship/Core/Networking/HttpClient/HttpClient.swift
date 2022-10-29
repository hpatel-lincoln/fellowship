//
//  HttpClient.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/27/22.
//

import Foundation
import PromiseKit

/**
 Http client to perform http requests.
 */
protocol HttpClient {
  /**
   Perform http request and return the response.
   
   - Parameter request: Http request to perform.
   - Returns: Http response data.
   */
  func perform(request: HttpRequest) -> Promise<Data>
  
  /**
   Perform URL request and return the response.
   
   - Parameter request: URL request to perform.
   - Returns: Http response data.
   */
  func perform(request: URLRequest) -> Promise<Data>
}

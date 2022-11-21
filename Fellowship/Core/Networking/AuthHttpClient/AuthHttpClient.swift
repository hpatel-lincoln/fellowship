//
//  AuthHttpClient.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import Foundation
import PromiseKit

/**
 HttpClient to perform authenticated http requests.
 */
protocol AuthHttpClient {
  /**
   Perform http request and return the response.
   
   - Parameter request: Http request to perform.
   - Parameter retryCount: Retry count in case of a failure.
   - Returns: Http response data.
   */
  func perform(request: HttpRequest, withRetries retryCount: Int) -> Promise<Data>
}

extension AuthHttpClient {
  func perform(request: HttpRequest) -> Promise<Data> {
    return perform(request: request, withRetries: 1)
  }
}

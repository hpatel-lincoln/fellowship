//
//  HttpClientTestCase.swift
//  FellowshipTests
//
//  Created by Hardik Patel on 11/22/22.
//

import XCTest
@testable import Fellowship

class HttpClientTestCase: XCTestCase {
  
  func test_HttpClient_200() {
    let client = DefaultHttpClient()
    let request = HttpRequest(
      host: "httpbin.org",
      path: "/status/200",
      method: .get
    )
    let exp = expectation(description: #function)
    var optionalError: Error? = nil
    
    client.perform(request: request).done { data in
      exp.fulfill()
    }.catch { error in
      optionalError = error
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10)
    XCTAssertNil(optionalError)
  }
  
  func test_HttpClient_204() {
    let client = DefaultHttpClient()
    let request = HttpRequest(
      host: "httpbin.org",
      path: "/status/204",
      method: .get
    )
    let exp = expectation(description: #function)
    var optionalError: Error? = nil
    
    client.perform(request: request).done { data in
      exp.fulfill()
    }.catch { error in
      optionalError = error
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10)
    XCTAssertNil(optionalError)
  }
  
  func test_HttpClient_401() {
    let client = DefaultHttpClient()
    let request = HttpRequest(
      host: "httpbin.org",
      path: "/status/401",
      method: .get
    )
    let exp = expectation(description: #function)
    var optionalError: Error? = nil
    
    client.perform(request: request).done { data in
      exp.fulfill()
    }.catch { error in
      optionalError = error
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10)
    XCTAssertNotNil(optionalError)
    XCTAssertThrowsError(
      try XCTUnwrap(optionalError)
    )
  }
}

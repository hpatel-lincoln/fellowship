//
//  URL+Extensions.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/29/22.
//

import Foundation

extension URL {
  subscript(name: String) -> String? {
    guard let components = URLComponents(
      url: self, resolvingAgainstBaseURL: false
    ) else {
      return nil
    }
    
    let queryItem = components.queryItems?.first {
      $0.name == name
    }
    return queryItem?.value
  }
}

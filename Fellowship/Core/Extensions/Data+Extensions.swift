//
//  Data+Extensions.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/29/22.
//

import Foundation

extension Data {
  var base64URLEncoded: String {
    return self.base64EncodedString()
      .replacingOccurrences(of: "=", with: "")
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .trimmingCharacters(in: .whitespaces)
  }
}

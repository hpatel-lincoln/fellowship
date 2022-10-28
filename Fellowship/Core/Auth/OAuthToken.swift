//
//  OAuthToken.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import Foundation

struct OAuthToken: Codable {
  var type: String
  var expiresIn: Int
  var accessToken: String
  var refreshToken: String
  var scope: String
  
  let issueDate = Date()
  
  enum CodingKeys: String, CodingKey {
    case type = "token_type"
    case expiresIn = "expires_in"
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case scope
  }
}

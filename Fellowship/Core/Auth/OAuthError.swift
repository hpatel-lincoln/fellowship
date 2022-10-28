//
//  OAuthError.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/27/22.
//

import Foundation

enum OAuthError: Error {
  case failedCodeVerifier
  case failedCodeChallenge
  case badAuthorizationURL
  case badAuthorizationResponse
  case invalidJson
}

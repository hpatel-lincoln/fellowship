//
//  OAuthError.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/27/22.
//

import Foundation

enum OAuthError: Error {  
  case failedProducingCodeVerifier
  case failedProducingCodeChallenge
  case failedProducingState
  case failedProducingAuthURL
  case invalidAuthResponse
  case invalidAuthResponseNoState
  case invalidAuthResponseBadState
  case invalidAuthResponseNoCode
}

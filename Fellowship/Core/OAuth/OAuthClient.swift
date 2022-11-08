//
//  OAuthClient.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/27/22.
//

import Foundation
import PromiseKit

/**
 OAuth client to perform OAuth 2.0 flow with PKCE.
 */
protocol OAuthClient {
  /**
   Authenticate via OAuth 2.0 flow with PKCE
   
   - Returns: OAuthToken containing access token, refresh token, and other metadata.
   */
  func authenticate() -> Promise<OAuthToken>
  
  /**
   Refresh access token with the given refresh token.
   
   - Parameter token: Refresh token
   - Returns: OAuthToken containing access token, refresh token, and other metadata.
   */
  func refresh(with token: String) -> Promise<OAuthToken>
}


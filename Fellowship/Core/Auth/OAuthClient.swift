//
//  OAuthClient.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/27/22.
//

import Foundation
import CryptoKit

class DefaultOAuthClient {
  
  // MARK: - Constants
  
  private struct Constants {
    static let ResponseType = "code"
    static let CodeChallengeMethod = "S256"
    static let CodeVerifierKey = "code_verifier"
    static let StateKey = "state"
    static let AuthCodeKey = "code"
    static let AuthCodeGrantType = "authorization_code"
    static let RefreshTokenGrantType = "refresh_token"
  }
  
  private let authHost: String
  private let authPath: String
  private let tokenHost: String
  private let tokenPath: String
  private let clientID: String
  private let redirectURI: String
  private let scope: String
  private let httpClient: HttpClient
  
  private var codeVerifier: String?
  private var state: String?
  
  init(
    authHost: String, authPath: String,
    tokenHost: String, tokenPath: String,
    clientID: String, redirectURI: String, scope: String,
    httpClient: HttpClient = DefaultHttpClient()
  ) {
    self.authHost = authHost
    self.authPath = authPath
    self.tokenHost = tokenHost
    self.tokenPath = tokenPath
    self.clientID = clientID
    self.redirectURI = redirectURI
    self.scope = scope
    self.httpClient = httpClient
  }
  
  private func getAuthorizationURL() throws -> URL {
    codeVerifier = generateCodeVerifier()
    guard codeVerifier != nil else { throw OAuthError.failedCodeVerifier }
    
    let codeChallenge = generateCodeChallenge(fromVerifier: codeVerifier!)
    guard codeChallenge != nil else { throw OAuthError.failedCodeChallenge }
    
    state = UUID.init().uuidString
    
    let params = [
      "response_type": Constants.ResponseType,
      "client_id": clientID,
      "redirect_uri": redirectURI,
      "scope": scope,
      "state": state,
      "code_challenge": codeChallenge,
      "code_challenge_method": Constants.CodeChallengeMethod
    ]
    
    let request = HttpRequest(
      host: authHost,
      path: authPath,
      method: .get,
      parameters: params,
      headers: nil
    )
    
    guard let url = request.makeURL() else {
      throw OAuthError.badAuthorizationURL
    }
    return url
  }
  
  // MARK: - Private methods
  
  private func generateCodeVerifier() -> String? {
    var buffer = [UInt8](repeating: 0, count: 32)
    let status = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
    
    guard status == errSecSuccess else {
      return nil
    }
    
    let verifier = Data(buffer).base64EncodedString()
      .replacingOccurrences(of: "=", with: "")
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .trimmingCharacters(in: .whitespaces)
    return verifier
  }
  
  private func generateCodeChallenge(fromVerifier verifier: String) -> String? {
    guard let data = verifier.data(using: .utf8) else {
      return nil
    }
    
    let hashed = SHA256.hash(data: data)
    let encoded = Data(hashed).base64EncodedString()
      .replacingOccurrences(of: "=", with: "")
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .trimmingCharacters(in: .whitespaces)
    return encoded
  }
}

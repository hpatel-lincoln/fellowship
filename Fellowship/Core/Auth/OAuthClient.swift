//
//  OAuthClient.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/27/22.
//

import Foundation
import CryptoKit
import PromiseKit
import AuthenticationServices

/**
 OAuth client to perform OAuth 2.0 flow with PKCE.
 */
protocol OAuthClient {
  /**
   Authenticate via OAuth 2.0 flow with PKCE
   
   - Returns: OAuthToken containing access token, refresh token, and other metadata.
   */
  func authenticate() -> Promise<OAuthToken>
}

class DefaultOAuthClient: OAuthClient {
  
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
  private weak var delegate: ASWebAuthenticationPresentationContextProviding?
  
  private var codeVerifier: String?
  private var state: String?
  
  init(
    authHost: String, authPath: String,
    tokenHost: String, tokenPath: String,
    clientID: String, redirectURI: String, scope: String,
    httpClient: HttpClient = DefaultHttpClient(),
    delegate: ASWebAuthenticationPresentationContextProviding?
  ) {
    self.authHost = authHost
    self.authPath = authPath
    self.tokenHost = tokenHost
    self.tokenPath = tokenPath
    self.clientID = clientID
    self.redirectURI = redirectURI
    self.scope = scope
    self.httpClient = httpClient
    self.delegate = delegate
  }
  
  func authenticate() -> Promise<OAuthToken> {
    return firstly {
      makeAuthorizationURL()
    }.then { authURL in
      self.authorize(at: authURL)
    }.then { code in
      self.authenticate(withCode: code)
    }
  }
  
  private func makeAuthorizationURL() -> Promise<URL> {
    return Promise { seal in
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
        parameters: params
      )
      
      guard let url = request.makeURL() else {
        throw OAuthError.badAuthorizationURL
      }
      
      seal.fulfill(url)
    }
  }
  
  private func authorize(at authURL: URL) -> Promise<String> {
    return Promise { seal in
      let authenticationSession = ASWebAuthenticationSession(
        url: authURL, callbackURLScheme: nil
      ) { optionalURL, optionalError in
        if let error = optionalError {
          return seal.reject(error)
        }
        
        guard let url = optionalURL else {
          return seal.reject(OAuthError.badAuthorizationResponse)
        }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let codeQueryItem = components?.queryItems?.first {
          $0.name == Constants.ResponseType
        }
        guard let code = codeQueryItem?.value else {
          return seal.reject(OAuthError.badAuthorizationResponse)
        }
        seal.fulfill(code)
      }
      
      authenticationSession.presentationContextProvider = delegate
      authenticationSession.start()
    }
  }
  
  private func authenticate(withCode code: String) -> Promise<OAuthToken> {
    guard let verifier = codeVerifier else {
      return Promise(error: OAuthError.failedCodeVerifier)
    }
    
    let parameters = [
      "grant_type": "authorization_code",
      "code": code,
      "client_id": clientID,
      "redirect_uri": redirectURI,
      "code_verifier": verifier
    ]
    
    do {
      let encoder = JSONEncoder()
      let httpBody = try encoder.encode(parameters)
      
      let request = HttpRequest(
        host: tokenHost,
        path: tokenPath,
        method: .post,
        httpBody: httpBody
      )
      
      return firstly {
        httpClient.perform(request: request)
      }.then { tokenData -> Promise<OAuthToken> in
        let decoder = JSONDecoder()
        let tokenResponse = try decoder.decode(OAuthToken.self, from: tokenData)
        return Promise.value(tokenResponse)
      }
    } catch {
      return Promise(error: error)
    }
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

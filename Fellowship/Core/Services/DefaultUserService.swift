//
//  DefaultUserService.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/31/22.
//

import Foundation
import PromiseKit

class DefaultUserService: UserService {
  
  let authHttpClient: AuthHttpClient
  
  init(authHttpClient: AuthHttpClient) {
    self.authHttpClient = authHttpClient
  }
  
  func getUser() -> Promise<User> {
    let params = [
      "user.fields": "profile_image_url,public_metrics"
    ]
    
    let request = HttpRequest(
      host: "api.twitter.com",
      path: "/2/users/me",
      method: .get,
      parameters: params
    )
    
    return firstly {
      authHttpClient.perform(request: request, withRetries: 1)
    }.then { data -> Promise<User> in
      do {
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: data)
        return Promise.value(user)
      } catch {
        throw error
      }
    }
  }
}

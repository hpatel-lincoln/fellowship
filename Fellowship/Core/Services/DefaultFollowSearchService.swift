//
//  DefaultFollowSearchService.swift
//  Fellowship
//
//  Created by Hardik Patel on 11/1/22.
//

import Foundation
import PromiseKit

class DefaultFollowSearchService: FollowSearchService {
  
  let authHttpClient: AuthHttpClient
  
  init(authHttpClient: AuthHttpClient) {
    self.authHttpClient = authHttpClient
  }
  
  func getFollowing(forUser id: String) -> PromiseKit.Promise<TwitterUserList> {
    let request = HttpRequest(
      host: "api.twitter.com",
      path: "/2/users/\(id)/following",
      method: .get
    )
    
    return firstly {
      authHttpClient.perform(request: request)
    }.then { data -> Promise<TwitterUserList> in
      do {
        let decoder = JSONDecoder()
        let followingList = try decoder.decode(TwitterUserList.self, from: data)
        return Promise.value(followingList)
      } catch {
        throw error
      }
    }
  }
  
  func getFollowers(forUser id: String) -> PromiseKit.Promise<TwitterUserList> {
    let request = HttpRequest(
      host: "api.twitter.com",
      path: "/2/users/\(id)/followers",
      method: .get
    )
    
    return firstly {
      authHttpClient.perform(request: request)
    }.then { data -> Promise<TwitterUserList> in
      do {
        let decoder = JSONDecoder()
        let followingList = try decoder.decode(TwitterUserList.self, from: data)
        return Promise.value(followingList)
      } catch {
        throw error
      }
    }
  }
}

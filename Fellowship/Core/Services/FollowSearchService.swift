//
//  FollowSearchService.swift
//  Fellowship
//
//  Created by Hardik Patel on 11/1/22.
//

import Foundation
import PromiseKit

protocol FollowSearchService {
  
  /// Get users followed by the user
  func getFollowing(forUser id: String) -> Promise<TwitterUserList>
  
  /// Get followers for the user
  func getFollowers(forUser id: String) -> Promise<TwitterUserList>
}

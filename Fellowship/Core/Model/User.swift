//
//  User.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/28/22.
//

import Foundation

struct FollowMetrics: Codable {
  var followersCount: Int
  var followingCount: Int
  
  enum CodingKeys: String, CodingKey {
    case followersCount = "followers_count"
    case followingCount = "following_count"
  }
}

struct User: Codable {
  var id: String
  var name: String
  var username: String
  var profileImageURL: URL?
  var followMetrics: FollowMetrics?
  
  enum CodingKeys: String, CodingKey {
    case id, name, username
    case profileImageURL = "profile_image_url"
    case followMetrics = "public_metrics"
  }
  
  enum ParentCodingKeys: String, CodingKey {
    case data
  }
  
  init(from decoder: Decoder) throws {
    let parentContainer = try decoder.container(keyedBy: ParentCodingKeys.self)
    let container = try parentContainer.nestedContainer(keyedBy: CodingKeys.self,
                                                        forKey: .data)
    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.username = try container.decode(String.self, forKey: .username)
    self.profileImageURL = try container.decodeIfPresent(URL.self, forKey: .profileImageURL)
    self.followMetrics = try container.decodeIfPresent(FollowMetrics.self, forKey: .followMetrics)
  }
}

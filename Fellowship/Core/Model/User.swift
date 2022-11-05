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
    
    // By default Twitter returns low quality profile image.
    // Replace with original profile image instead.
    let normalProfileURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
    if let normalProfileURL = normalProfileURL {
      let originalProfileURL = normalProfileURL.replacingOccurrences(of: "_normal", with: "")
      self.profileImageURL = URL(string: originalProfileURL)
    } else {
      self.profileImageURL = nil
    }
    
    self.followMetrics = try container.decodeIfPresent(FollowMetrics.self, forKey: .followMetrics)
  }
  
  func encode(to encoder: Encoder) throws {
    var parentContainer = encoder.container(keyedBy: ParentCodingKeys.self)
    
    
    var container = parentContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.username, forKey: .username)
    try container.encodeIfPresent(self.profileImageURL, forKey: .profileImageURL)
    try container.encodeIfPresent(self.followMetrics, forKey: .followMetrics)
  }
}

//
//  TwitterUserList.swift
//  Fellowship
//
//  Created by Hardik Patel on 11/1/22.
//

import Foundation

struct TwitterUser: Codable {
  var id: String
  var name: String
  var username: String
}

struct TwitterUserList: Codable {
  var users: [TwitterUser]
  
  enum CodingKeys: String, CodingKey {
    case users = "data"
  }
}

//
//  NetworkError.swift
//  Fellowship
//
//  Created by Hardik Patel on 10/27/22.
//

import Foundation

enum NetworkError: Error {
  case invalidURL
  case invalidResponse
  case unauthorized
  case notFound
  case badRequest(code: Int)
  case maintenance
  case badResponse(code: Int)
}

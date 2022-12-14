//
//  MemberModels.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/14.
//

import Foundation

struct UserInput: Encodable {
  let user: UserLoginInput
}

struct UserLoginInput: Encodable {
  let login: String
  let email: String
  let password: String
}

struct User: Decodable {
  var userToken: String?
  var login: String?
  
  enum CodingKeys: String, CodingKey {
    case userToken = "User-Token"
    case login
  }
}

struct UserError: Decodable, Error {
  var errorCode: Int?
  var localizedDescription: String?
  
  enum CodingKeys: String, CodingKey {
    case errorCode = "error_code"
    case localizedDescription = "message"
  }
}

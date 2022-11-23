//
//  auth.swift
//  RailwayInformation
//
//  Created by User20 on 2022/11/23.
//

import Foundation

struct Token: Decodable {
  let access_token: String
  let expires_in: Int
  let token_type: String
}

class Auth: ObservableObject {
  @Published var showError = false
  @Published var token = Token(access_token: "", expires_in: 0, token_type: "")
  
  var error: Error? {
    willSet {
      DispatchQueue.main.async {
        self.showError = newValue != nil
      }
    }
  }
  
  func errorHandle(_ error: Error?) {
    print("error \(String(describing: error))")
    self.error = error
  }
  
  func fetchTocken() {
    let id = "CLIENT_ID"
    let secret = "CLIENT_SECRET"
    
    let urlStr = "https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token"
    let contentType = "application/x-www-form-urlencoded"
    let grantType = "grant_type=client_credentials"
    let clientId = "client_id=\(id)"
    let clientSecret = "client_secret=\(secret)"
    let data: Data = "\(grantType)&\(clientId)&\(clientSecret)"
      .data(using: .utf8)!
    
    guard let url = URL(string: urlStr) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(contentType, forHTTPHeaderField: "content-type")
    request.httpBody = data
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let data = data {
        do {
          let x = try JSONDecoder().decode(Token.self, from: data)
          DispatchQueue.main.sync {
            self.token = x
            self.error = nil
          }
        } catch {
          self.errorHandle(error)
        }
      } else {
        self.errorHandle(error)
      }
    }.resume()
  }
}

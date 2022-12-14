//
//  MemberController.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/14.
//

import Foundation

class MemberController: ObservableObject {
  @Published var showError = false
  @Published var loading = 0
  @Published var user: User? = nil
  var session: URLSession = URLSession(configuration: .default)
  
  let USERS_URL: String
  
  init() {
    let HTTPS_HOST = "https://favqs.com/api"
    USERS_URL = "\(HTTPS_HOST)/users"
    
    let contentType = "application/json"
    let auth = "Token token=\(Bundle.main.infoDictionary?["FAVQS"] ?? "")"
    let config = URLSessionConfiguration.default
    config.httpAdditionalHeaders = [
      "content-type": contentType,
      "authorization": auth
    ]
    session = URLSession(configuration: config)
  }
  
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
  
  func createUser(login: String, email: String, password: String) {
    loading += 1
    let userInput = UserInput(user: UserLoginInput(login: login, email: email, password: password))
    let data = try? JSONEncoder().encode(userInput)
    
    guard let url = URL(string: USERS_URL) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = data
    
    session.dataTask(with: request) { data, response, error in
      if let data = data {
        do {
          let user = try JSONDecoder().decode(User.self, from: data)
          let userError = try JSONDecoder().decode(UserError.self, from: data)
          guard userError.errorCode == nil else { throw userError }
          DispatchQueue.main.sync {
            self.user = user
            self.error = nil
            self.loading -= 1
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

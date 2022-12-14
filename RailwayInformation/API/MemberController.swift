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
  let USERS_URL: String
  
  init() {
    let HTTPS_HOST = "https://favqs.com/api"
    USERS_URL = "\(HTTPS_HOST)/users"
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
    let contentType = "application/json"
    let auth = "Token token=\(Bundle.main.infoDictionary?["FAVQS"] ?? "")"
    let userInput = UserInput(user: UserLoginInput(login: login, email: email, password: password))
    let data = try? JSONEncoder().encode(userInput)
    
    guard let url = URL(string: USERS_URL) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(auth, forHTTPHeaderField: "authorization")
    request.setValue(contentType, forHTTPHeaderField: "content-type")
    request.httpBody = data
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let data = data {
        do {
          print(data.description)
          let user = try JSONDecoder().decode(User.self, from: data)
          let userError = try JSONDecoder().decode(UserError.self, from: data)
          guard userError.errorCode == nil else { throw userError }
          DispatchQueue.main.sync {
            self.user = user
            print(user.login ?? "nil")
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

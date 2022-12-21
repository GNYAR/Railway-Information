//
//  MemberController.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/14.
//

import SwiftUI

class MemberController: ObservableObject {
  @AppStorage("user") var appUser: Data?
  
  @Published var isLoading = false
  @Published var showError = false
  @Published var user: User? = nil {
    didSet {
      do {
        appUser = try JSONEncoder().encode(user)
      } catch {
        print(error)
      }
    }
  }
  
  var session: URLSession = URLSession(configuration: .default)
  
  let SESSION_URL: String
  let USERS_URL: String
  
  init() {
    let HTTPS_HOST = "https://favqs.com/api"
    SESSION_URL = "\(HTTPS_HOST)/session"
    USERS_URL = "\(HTTPS_HOST)/users"
    
    let contentType = "application/json"
    let auth = "Token token=\(Bundle.main.infoDictionary?["FAVQS"] ?? "")"
    let config = URLSessionConfiguration.default
    config.httpAdditionalHeaders = [
      "content-type": contentType,
      "authorization": auth
    ]
    session = URLSession(configuration: config)
    
    if let appUser = appUser {
      do {
        user = try JSONDecoder().decode(User.self, from: appUser)
      } catch {
        print(error)
      }
    }
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
    DispatchQueue.main.sync {
      self.isLoading = false
    }
  }
  
  func postUserData(url: URL, data: Data?) {
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
            self.isLoading = false
          }
        } catch {
          self.errorHandle(error)
        }
      } else {
        self.errorHandle(error)
      }
    }.resume()
  }
  
  func createUser(login: String, email: String, password: String) {
    if isLoading { return }
    isLoading = true
    
    let userInput = UserInput(user: UserLoginInput(login: login, email: email, password: password))
    let data = try? JSONEncoder().encode(userInput)
    
    guard let url = URL(string: USERS_URL) else { return }
    
    postUserData(url: url, data: data)
  }
  
  func login(login: String, password: String) {
    if isLoading { return }
    isLoading = true
    
    let userInput = UserInput(user: UserLoginInput(login: login, password: password))
    let data = try? JSONEncoder().encode(userInput)
    
    guard let url = URL(string: SESSION_URL) else { return }
    
    postUserData(url: url, data: data)
  }
  
  func logout() {
    user = User()
  }
}

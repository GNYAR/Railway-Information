//
//  DataController.swift
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

class DataController: ObservableObject {
  @Published var lines: [Line] = []
  @Published var loading = 0
  @Published var stations: [String: Station] = [:]
  @Published var stationsOfLine: [StationOfLine] = []
  @Published var stationTimeTables: [Int: [StationTimeTable]] = [:]
  @Published var stationTrainsLive: [String: [TrainLive]] = [:]
  @Published var trainsLive: [String: TrainLive] = [:]
  
  @Published var showError = false
  @Published var token = Token(access_token: "", expires_in: 0, token_type: "")
  @Published var tokenLoading = 0
  var session: URLSession = URLSession(configuration: .default)
  
  let TOKEN_URL: String
  let TRA_V3_BASE: String
  
  init() {
    let HTTPS_HOST = "https://tdx.transportdata.tw"
    TOKEN_URL = "\(HTTPS_HOST)/auth/realms/TDXConnect/protocol/openid-connect/token"
    TRA_V3_BASE = "\(HTTPS_HOST)/api/basic/v3/Rail/TRA"
    
    fetchTocken()
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
  
  func fetchTocken() {
    tokenLoading += 1
    let contentType = "application/x-www-form-urlencoded"
    let grantType = "grant_type=client_credentials"
    let clientId = "client_id=\(Bundle.main.infoDictionary?["CLIENT_ID"] ?? "")"
    let clientSecret = "client_secret=\(Bundle.main.infoDictionary?["CLIENT_SECRET"] ?? "")"
    let data: Data = "\(grantType)&\(clientId)&\(clientSecret)"
      .data(using: .utf8)!
    
    guard let url = URL(string: TOKEN_URL) else { return }
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
            let config = URLSessionConfiguration.default
            config.httpAdditionalHeaders = [
              "authorization": "Bearer \(x.access_token)"
            ]
            self.session = URLSession(configuration: config)
            self.error = nil
            self.tokenLoading -= 1
          }
        } catch {
          self.errorHandle(error)
        }
      } else {
        self.errorHandle(error)
      }
    }.resume()
  }
  
  func queryStations() {
    guard let url = URL(string: "\(TRA_V3_BASE)/Station?$format=JSON") else { return }
    
    session.dataTask(with: url) { data, response, error in
      if let data = data {
        do {
          let xs = try JSONDecoder().decode(StationsDecode.self, from: data).Stations
          let stationDict = Dictionary(grouping: xs, by: { $0.StationID }).mapValues({ $0.first! })
          
          DispatchQueue.main.sync {
            self.stations = stationDict
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
  
  func queryLines() {
    guard let url = URL(string: "\(TRA_V3_BASE)/Line?$format=JSON&$orderby=IsBranch") else { return }
    
    session.dataTask(with: url) { data, response, error in
      if let data = data {
        do {
          let xs = try JSONDecoder().decode(LinesDecode.self, from: data)
          DispatchQueue.main.sync {
            self.lines = xs.Lines
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
  
  func queryStationsOfLine() {
    guard let url = URL(string: "\(TRA_V3_BASE)/StationOfLine?$format=JSON") else { return }
    
    session.dataTask(with: url) { data, response, error in
      if let data = data {
        do {
          let xs = try JSONDecoder().decode(StationsOfLineDecode.self, from: data)
          DispatchQueue.main.sync {
            self.stationsOfLine = xs.StationOfLines
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
  
  func queryStationTimeTables(_ id: String) {
    loading += 1
    guard let url = URL(string: "\(TRA_V3_BASE)/DailyStationTimetable/Today/Station/\(id)?$format=JSON") else { return }
    
    session.dataTask(with: url) { data, response, error in
      if let data = data {
        do {
          let xs = try JSONDecoder().decode(StationTimeTablesDecode.self, from: data).StationTimetables
          
          DispatchQueue.main.sync {
            xs.forEach({ x in
              self.stationTimeTables[x.Direction] = x.TimeTables.sorted(by: { a, b in a.id < b.id })
            })
            self.loading -= 1
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
  
  func queryTrainsLive() {
    guard var urlC = URLComponents(string: "\(TRA_V3_BASE)/TrainLiveBoard") else { return }
    
    let dateFormatter = ISO8601DateFormatter()
    let past = Date().addingTimeInterval(-10 * 60) // past 10 minutes
    let timeFilter = "UpdateTime gt \(dateFormatter.string(from: past))"
    
    urlC.queryItems = [
      URLQueryItem(name: "$format", value: "JSON"),
      URLQueryItem(name: "$filter", value: timeFilter)
    ]
    
    guard let url = urlC.url else { return }
    
    session.dataTask(with: url) { data, response, error in
      if let data = data {
        do {
          let xs = try JSONDecoder().decode(TrainLiveBoardsDecode.self, from: data).TrainLiveBoards
          let stationGroup = Dictionary(grouping: xs, by: { $0.StationID })
          let trainsLive = Dictionary(grouping: xs, by: { $0.TrainNo }).mapValues({ $0.first! })
          
          DispatchQueue.main.sync {
            self.stationTrainsLive = stationGroup
            self.trainsLive = trainsLive
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

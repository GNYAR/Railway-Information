//
//  DataModels.swift
//  RailwayInformation
//
//  Created by User20 on 2022/11/16.
//

import Foundation

struct Name: Decodable {
  let Zh_tw: String
  let En: String
}

// Decode
struct LinesDecode: Decodable {
  let Lines: [Line]
}

struct StationsDecode: Decodable {
  let Stations: [Station]
}

// Line
struct Line: Decodable, Identifiable {
  var id: String { LineID }
  
  let LineID: String
  let LineName: Name
  let LineSectionName: Name
  let IsBranch: Bool
}

struct LineStation: Decodable, Identifiable {
  var id: String { StationID }
  
  let Sequence: Int
  let StationID: String
  let StationName: Name
}

// Station
struct Station: Decodable, Identifiable {
  var id: String { StationUID }
  
  let StationUID: String
  let StationID: String
  let StationName: Name
  var ReservationCode: String?
  var StationAddress: String?
  var StationPhone: String?
  var StationClass: String? // ['0: 特等', '1: 一等', '2: 二等', '3: 三等', '4: 簡易', '5: 招呼', '6: 號誌', 'A: 貨運', 'B: 基地', 'X: 非車']
  var StationURL: String?
}

struct StationOfLine: Decodable, Identifiable {
  var id: String { LineID }
  
  let LineID: String
  let Stations: [LineStation]
}

struct StationsOfLineDecode: Decodable {
  let StationOfLines: [StationOfLine]
}

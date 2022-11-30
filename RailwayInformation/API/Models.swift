//
//  Models.swift
//  RailwayInformation
//
//  Created by User20 on 2022/11/16.
//

import Foundation

struct Name: Decodable {
  let Zh_tw: String
  let En: String
}

struct Station: Decodable, Identifiable {
  var id: String { StationUID }
  
  let StationUID: String
  let StationID: String
  let StationName: Name
  let ReservationCode: String?
  let StationAddress: String?
  let StationPhone: String?
  let StationClass: String? // ['0: 特等', '1: 一等', '2: 二等', '3: 三等', '4: 簡易', '5: 招呼', '6: 號誌', 'A: 貨運', 'B: 基地', 'X: 非車']
  let StationURL: String?
}

struct StationsDecode: Decodable {
  let Stations: [Station]
}

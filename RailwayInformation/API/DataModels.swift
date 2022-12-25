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

struct StationsOfLineDecode: Decodable {
  let StationOfLines: [StationOfLine]
}

struct StationTimeTablesDecode: Decodable {
  let StationTimetables: [StationTimeTables]
}

struct TrainLiveBoardsDecode: Decodable {
  let TrainLiveBoards: [TrainLive]
}

struct TrainTimeTablesDecode: Decodable {
  let TrainTimetables: [TrainTimeTable]
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

// TimeTable
struct StationTimeTable: Decodable, Identifiable {
  var id: Int { Sequence }
  
  let Sequence: Int
  let TrainNo: String
  let TrainTypeCode: String
  let TrainTypeName: Name
  let DestinationStationID: String
  let DestinationStationName: Name
  let ArrivalTime: String
  let DepartureTime: String
}

struct StationTimeTables: Decodable {
  let Direction: Int // [0:'順行',1:'逆行']
  let TimeTables: [StationTimeTable]
}

struct StopTime: Decodable, Identifiable {
  var id: Int { StopSequence }
  
  let StopSequence: Int
  let StationID: String
  let StationName: Name
  let ArrivalTime: String
  let DepartureTime: String
  let SuspendedFlag: Int // [0:'否',1:'是']
}

struct TrainInfo: Decodable {
  let TrainNo: String
  let Direction: Int
  let TrainTypeCode: String
  let TrainTypeName: Name
  
  let TripHeadSign: String
  let StartingStationID: String
  let StartingStationName: Name
  let EndingStationID: String
  let EndingStationName: Name
  let TripLine: Int // [0:'不經山海線',1:'山線',2:'海線',3:'成追線']
  
  let WheelChairFlag: Int
  let PackageServiceFlag: Int
  let DiningFlag: Int
  let BreastFeedFlag: Int
  let BikeFlag: Int
  
  let DailyFlag: Int
  let ExtraTrainFlag: Int
  let SuspendedFlag: Int // [0:'正常行駛',1:'停駛',2:'部份停駛']
  
  let Note: String
}

struct TrainTimeTable: Decodable {
  let TrainInfo: TrainInfo
  let StopTimes: [StopTime]
}

// Train
struct TrainLive: Decodable, Identifiable {
  var id: String { TrainNo }
  
  let TrainNo: String
  let TrainTypeCode: String // ['1: 太魯閣', '2: 普悠瑪', '3: 自強', '4: 莒光', '5: 復興', '6: 區間', '7: 普快', '10: 區間快', '11: 自強(3000)']
  let TrainTypeName: Name
  let StationID: String
  let TrainStationStatus: Int // [0:'進站中', 1:'在站上', 2:'已離站']
  let DelayTime: Int // minutes
}

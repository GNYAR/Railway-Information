//
//  TrainView.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/21.
//

import SwiftUI

struct TrainView: View {
  @EnvironmentObject var dataController: DataController
  @Binding var isActive: Bool
  let trainNo: String
  let trainTypeCode: String
  
  var body: some View {
    let timeTable = dataController.trainTimeTable
    
    VStack {
      HStack {
        Text(trainNo)
          .font(.title)
          .foregroundColor(.white)
        
        Spacer()
        
        Button(action: { isActive = false }, label: {
          Image(systemName: "xmark")
            .font(.title2)
            .foregroundColor(.white)
        })
      }
      .padding()
      .background(Color("TrainType\(trainTypeCode)"))
      
      if dataController.loading == 0 {
        TrainInfoView(trainInfo: timeTable?.TrainInfo)
          .padding(.horizontal)
        TrainTimeView(stopTimes: timeTable?.StopTimes)
      } else {
        LottieView(lottieFile: "loading", loop: .loop)
      }
      
      Spacer()
    }
    .onAppear(perform: { dataController.queryTrainTimeTable(trainNo) })
  }
}

struct TrainInfoView: View {
  let trainInfo: TrainInfo?
  
  var body: some View {
    if trainInfo == nil {
      Text("查無資料")
    } else {
      let x = trainInfo!
      let lineTrip = getTripLineString(x.TripLine)
      
      VStack(alignment: .leading) {
        HStack {
          Text(x.TripHeadSign)
            .font(.largeTitle)
            .bold()
          
          VStack(alignment: .leading) {
            Text(x.TrainTypeName.Zh_tw)
              .lineLimit(1)
            
            Text(lineTrip)
              .foregroundColor(.secondary)
          }
          
          Spacer()
        }
        .padding(.bottom, 4)
        
        Text(x.Note)
          .font(.footnote)
      }
    }
  }
  
  func getTripLineString(_ x: Int) -> String {
    switch x {
    case 1:
      return "山線"
    case 2:
      return "海線"
    case 3:
      return "成追線"
    default:
      return ""
    }
  }
}

struct TrainTimeView: View {
  let stopTimes: [StopTime]?
  
  var body: some View {
    if stopTimes == nil {
      Text("查無資料")
    } else {
      let xs = stopTimes!
      
      List {
        Section(
          header: VStack(spacing: 0) {
            HStack {
              let first = xs.first!
              let last = xs.last!
              
              Text("\(first.ArrivalTime) \(first.StationName.Zh_tw)")
              Text("-")
              Text("\(last.ArrivalTime) \(last.StationName.Zh_tw)")
              
              Spacer()
            }
            .padding(.vertical, 4)
            
            Divider()
            
            StopRow(
              x: StopTime(
                StopSequence: 0,
                StationID: "",
                StationName: Name(Zh_tw: "車站名稱", En: "Station"),
                ArrivalTime: "到站時間",
                DepartureTime: "離站時間",
                SuspendedFlag: 0
              )
            )
            .padding(.vertical, 4)
          }
        ) {
          ForEach(xs) { x in
            StopRow(x: x)
          }
        }
      }
    }
  }
}

struct StopRow: View {
  let x: StopTime
  
  var body: some View {
    HStack {
      Text(x.StationName.Zh_tw)
        .fontWeight(.regular)
        .frame(width: 100, alignment: .leading)
      
      Group {
        Text(x.ArrivalTime)
        Text(x.DepartureTime)
      }
      .font(.system(.body, design: .monospaced))
      .frame(width: 100)
      
      Spacer()
    }
  }
}

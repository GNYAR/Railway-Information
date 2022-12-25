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
      
      Group {
        if dataController.loading == 0 {
          TrainInfoView(trainInfo: timeTable?.TrainInfo)
        } else {
          LottieView(lottieFile: "loading", loop: .loop)
        }
      }
      .padding(.horizontal)
      
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


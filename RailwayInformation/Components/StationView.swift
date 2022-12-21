//
//  StationView.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/20.
//

import SwiftUI

struct StationView: View {
  @EnvironmentObject var dataController: DataController
  @State var nextTrain = 0
  @State var updatedTime = Date()
  @State var selectedDirection = 0
  let id: String
  
  let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
  
  var body: some View {
    let station = dataController.stations[id]
    let xs = dataController.stationTimeTables[selectedDirection] ?? []
    
    ScrollViewReader { scrollView in
      if (dataController.loading != 0) {
        ProgressView()
      } else {
        ScrollView(.vertical) {
          LazyVStack(pinnedViews: [.sectionHeaders]) {
            Section(
              header: StationTimeHeader(
                selectedDirection: $selectedDirection,
                updatedTime: updatedTime
              ).id(updatedTime)
            ) {
              ForEach(xs) { x in
                StationTimeRow(x: x)
                  .padding(.horizontal)
                  .padding(.vertical, -2)
                
                Divider()
              }
            }
          }
          .onAppear() {
            if xs.isEmpty { return }
            // for auto scroll
            // scrollView.scrollTo(xs[xs.count - 1].id)
          }
        }
      }
    }
    .navigationTitle(station?.StationName.Zh_tw ?? "Not Found")
    .onAppear() {
      dataController.queryStationTimeTables(id)
      refreshTrainLive()
    }
    .onReceive(timer, perform: { _ in
      refreshTrainLive()
    })
  }
  
  func refreshTrainLive() {
    dataController.queryTrainsLive()
    updatedTime = Date()
  }
}

struct StationTimeHeader: View {
  @Binding var selectedDirection: Int
  @State var updatedTime: Date
  let directions = ["順行", "逆行"]
  
  var body: some View {
    VStack(spacing: 4) {
      HStack(spacing: 0) {
        Spacer()
        
        Text(updatedTime, style: .relative)
        Text("前更新")
      }
      .padding(.top, 4)
      .padding(.horizontal)
      
      Picker("方向", selection: $selectedDirection) {
        ForEach(directions.indices) { i in
          Text(directions[i])
        }
      }
      .pickerStyle(SegmentedPickerStyle())
    }
    .background(Color(.systemBackground))
  }
}

struct StationTimeRow: View {
  @EnvironmentObject var dataController: DataController
  let x: StationTimeTable
  
  var body: some View {
    let delayTime = dataController.trainsLive[x.TrainNo]?.DelayTime
    
    HStack {
      Circle()
        .frame(width: 12, height: 12)
      
      Text(x.ArrivalTime)
        .font(.system(.body, design: .monospaced))
      
      TrainTag(trainNo: x.TrainNo, trainTypeCode: x.TrainTypeCode)
        .frame(width: 80, alignment: .center)
      
      Text(x.DestinationStationName.Zh_tw)
      
      Spacer()
      
      if delayTime == 0 { Text("準點").foregroundColor(.green) }
      else if delayTime != nil { Text("晚\(delayTime!)分").foregroundColor(.red) }
    }
  }
}

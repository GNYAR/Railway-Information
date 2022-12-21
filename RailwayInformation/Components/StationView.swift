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
  @State var selectedDirection = 0
  let id: String
  let directions = ["順行", "逆行"]
  
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
              header: Picker("方向", selection: $selectedDirection) {
                ForEach(directions.indices) { i in
                  Text(directions[i])
                }
              }
              .pickerStyle(SegmentedPickerStyle())
              .background(Color(.systemBackground))
            ) {
              ForEach(xs) { x in
                StationTimeRow(x: x)
                  .padding(.horizontal)
                  .padding(.vertical, 8)
                
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
    .onAppear(perform: { dataController.queryStationTimeTables(id) })
  }
}

struct StationTimeRow: View {
  let x: StationTimeTable
  
  var body: some View {
    HStack {
      Circle()
        .frame(width: 12, height: 12)
      
      Text(x.ArrivalTime)
        .font(.system(.body, design: .monospaced))
      
      TrainTag(trainNo: x.TrainNo, trainTypeCode: x.TrainTypeCode)
        .frame(width: 80, alignment: .center)
      
      Text(x.DestinationStationName.Zh_tw)
      
      Spacer()
    }
  }
}

//
//  StationView.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/20.
//

import SwiftUI

struct StationView: View {
  @EnvironmentObject var dataController: DataController
  @State var nextTrainSequence: Int? = nil
  @State var updatedTime = Date()
  @State var selectedDirection = 0
  @State var isShareLink: Bool = false
  let id: String
  
  let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
  
  var body: some View {
    let station = dataController.stations[id]
    let xs = dataController.stationTimeTables[selectedDirection] ?? []
    
    ScrollViewReader { proxy in
      if (dataController.loading != 0) {
        LottieView(lottieFile: "loading", loop: .loop, isComplete: .constant(false))
      } else {
        ScrollView(.vertical) {
          LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
            Section(
              header: StationTimeHeader(
                selectedDirection: $selectedDirection,
                updatedTime: updatedTime
              ).id(updatedTime)
            ) {
              ForEach(xs) { x in
                StationTimeRow(x: x)
                  .padding(.horizontal)
                  .padding(.vertical, 2)
                  .background(Group {
                    if (nextTrainSequence == x.id) {
                      LinearGradient(
                        gradient: Gradient(
                          colors: [
                            Color.accentColor.opacity(0.2),
                            Color(.systemBackground)
                          ]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                      )
                    }
                  })
                
                Divider()
              }
            }
          }
          .onAppear() {
            if xs.isEmpty { return }
            updateNextTrainSequence(xs, now: updatedTime)
            proxy.scrollTo(nextTrainSequence! - 2)
          }
          .onChange(of: selectedDirection, perform: { x in
            let data = dataController.stationTimeTables[x] ?? []
            updateNextTrainSequence(data, now: updatedTime)
          })
        }
      }
    }
    .navigationTitle(station?.StationName.Zh_tw ?? "Not Found")
    .navigationBarItems(
      trailing: Button(action: { isShareLink = true }) {
        Image(systemName: "info.circle")
      }
    )
    .sheet(isPresented: $isShareLink, content: {
      Share(urlString: station?.StationURL ?? "https://google.com")
    })
    .onAppear() {
      dataController.queryStationTimeTables(id)
      refreshTrainLive()
    }
    .onReceive(timer, perform: { _ in
      refreshTrainLive()
      updateNextTrainSequence(xs, now: updatedTime)
    })
  }
  
  func refreshTrainLive() {
    dataController.queryTrainsLive()
    updatedTime = Date()
  }
  
  func updateNextTrainSequence(_ xs: [StationTimeTable], now: Date) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let updatedTimeString = dateFormatter.string(from: now)
    nextTrainSequence = xs.first(where: { updatedTimeString <= $0.ArrivalTime })?.id
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

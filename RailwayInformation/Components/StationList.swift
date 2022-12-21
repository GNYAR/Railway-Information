//
//  StationList.swift
//  RailwayInformation
//
//  Created by User20 on 2022/11/30.
//

import SwiftUI

struct StationList: View {
  @EnvironmentObject var dataController: DataController
  @State var refreshTime: Date = Date()
  @State var selectedLine: Line? = nil
  let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
  
  var body: some View {
    let filteredStations = dataController.stationsOfLine.first(
      where: { $0.LineID == selectedLine?.LineID }
    )?.Stations ?? []
    
    NavigationView {
      VStack(alignment: .leading) {
        DisclosureGroup {
          LineChips(selected: $selectedLine, lines: dataController.lines.filter({ !$0.IsBranch }))
          LineChips(selected: $selectedLine, lines: dataController.lines.filter({ $0.IsBranch }))
        } label: {
          let lineName = selectedLine?.LineName.Zh_tw ?? "全部"
          
          HStack(alignment: .bottom) {
            Text(lineName)
              .font(.title)
          }
        }
        .padding([.horizontal, .top])
        
        List {
          Section(header: HStack(spacing: 0) {
            let sectionName = selectedLine?.LineSectionName.Zh_tw ?? ""
            
            Text(sectionName)
            
            Spacer()
            
            Text(refreshTime, style: .relative)
            Text("前更新")
          }) {
            if(selectedLine == nil) {
              ForEach(dataController.stations.sorted(by: {a, b in
                a.key < b.key
              }), id: \.key) { _, x in
                StationRow(id: x.StationID, name: x.StationName)
              }
            } else {
              ForEach(filteredStations) { x in
                StationRow(id: x.StationID, name: x.StationName)
              }
            }
          }
        }
        .listStyle(PlainListStyle())
        .onAppear(perform: refreshTrainLive)
        .onReceive(timer, perform: { _ in refreshTrainLive() })
      }
      .navigationTitle("車站列表")
      .navigationBarHidden(true)
    }
  }
  
  func refreshTrainLive() {
    dataController.queryTrainsLive()
    refreshTime = Date()
  }
}

struct LineChips: View {
  @Binding var selected: Line?
  let lines: [Line]
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false, content: {
      HStack(spacing: 24) {
        ForEach(lines) { x in
          let isSelected = selected?.id == x.id
          
          Button(x.LineName.Zh_tw) {
            selected = isSelected ? nil : x
          }
          .foregroundColor(isSelected ? .accentColor : .gray)
        }
      }
      .padding(.vertical, 2)
    })
  }
}

struct StationRow: View {
  @EnvironmentObject var dataController: DataController
  let id: String
  let name: Name
  
  var body: some View {
    ZStack {
      NavigationLink(destination: StationView(id: id)) { EmptyView() }
        .opacity(0)
      
      HStack(spacing: 0) {
        Text(name.Zh_tw)
        
        Spacer()
        
        ForEach(dataController.stationTrainsLive[id] ?? []) { y in
          TrainTag(trainNo: y.TrainNo, trainTypeCode: y.TrainTypeCode)
        }
      }
    }
  }
}

struct CTagButton: ButtonStyle {
  var color: Color = Color.accentColor
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, 8)
      .padding(.vertical, 8)
      .background(color)
      .foregroundColor(.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}

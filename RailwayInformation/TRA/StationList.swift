//
//  StationList.swift
//  RailwayInformation
//
//  Created by User20 on 2022/11/30.
//

import SwiftUI

struct StationList: View {
  @EnvironmentObject var dataController: DataController
  @State var selectedLine: Line? = nil
  
  var body: some View {
    VStack(alignment: .leading) {
      
      DisclosureGroup {
        LineChips(selected: $selectedLine, lines: dataController.lines.filter({ !$0.IsBranch }))
        LineChips(selected: $selectedLine, lines: dataController.lines.filter({ $0.IsBranch }))
      } label: {
        let lineName = selectedLine?.LineName.Zh_tw ?? "全部"
        let sectionName = selectedLine?.LineSectionName.Zh_tw ?? ""
        
        HStack(alignment: .bottom) {
          Text(lineName)
            .font(.title)
          
          Text(sectionName)
            .font(.subheadline)
            .foregroundColor(.secondary)
          
          Spacer()
        }
      }
      .padding(.horizontal)
      
      List {
        if(selectedLine == nil) {
          ForEach(dataController.stations) { x in
            Text(x.StationName.Zh_tw)
          }
        } else {
          ForEach(
            dataController.stationsOfLine.first(
              where: { $0.LineID == selectedLine?.LineID }
            )?.Stations ?? []
          ) { x in
            Text(x.StationName.Zh_tw)
          }
        }
      }
    }
    .onAppear(perform: {
      dataController.queryStations()
      dataController.queryStationsOfLine()
      dataController.queryLines()
    })
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

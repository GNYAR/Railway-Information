//
//  StationList.swift
//  RailwayInformation
//
//  Created by User20 on 2022/11/30.
//

import SwiftUI

struct StationList: View {
  @EnvironmentObject var dataController: DataController
  
  var body: some View {
    List {
      ForEach(dataController.stations) { x in
        Text(x.StationName.Zh_tw)
      }
    }
    .onAppear(perform: {
      dataController.queryStations()
    })
  }
}

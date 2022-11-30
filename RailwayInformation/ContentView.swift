//
//  ContentView.swift
//  RailwayInformation
//
//  Created by User20 on 2022/11/16.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var dataController: DataController
  
  var body: some View {
    if (dataController.tokenLoading) != 0 {
      Text("Loading...")
    } else {
      List {
        ForEach(dataController.stations) { x in
          Text(x.StationName.Zh_tw)
        }
      }
      .alert(isPresented: $dataController.showError, content: {
        Alert(
          title: Text("Query stations failed!"),
          message: Text("\(dataController.error!.localizedDescription)")
        )
      })
      .onAppear(perform: {
        dataController.queryStations()
      })
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
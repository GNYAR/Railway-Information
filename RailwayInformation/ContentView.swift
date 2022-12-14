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
      ProgressView("載入中...")
    } else {
      TabView {
        StationList().tabItem {
          Label("車站列表", systemImage: "list.dash")
        }
        Member().tabItem {
          Label("我的帳號", systemImage: "person.fill")
        }
      }
      .onAppear(perform: {
        dataController.queryStations()
        dataController.queryStationsOfLine()
        dataController.queryLines()
      })
      .alert(isPresented: $dataController.showError, content: {
        Alert(
          title: Text("Query stations failed!"),
          message: Text("\(dataController.error!.localizedDescription)")
        )
      })
    }
  }
}

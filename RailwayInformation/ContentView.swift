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
      LottieView(lottieFile: "loading", loop: .loop)
    } else {
      TabView {
        StationList().tabItem {
          Label("首頁", systemImage: "tram")
        }
        
        Search().tabItem {
          Label("搜尋", systemImage: "magnifyingglass")
        }
        
//        Collection().tabItem {
//          Label("收藏", systemImage: "text.badge.star")
//        }
        
        Member().tabItem {
          Label("帳號", systemImage: "person.fill")
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

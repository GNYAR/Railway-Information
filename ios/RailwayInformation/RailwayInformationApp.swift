//
//  RailwayInformationApp.swift
//  RailwayInformation
//
//  Created by User20 on 2022/11/16.
//

import SwiftUI

@main
struct RailwayInformationApp: App {
  @StateObject private var dataController = DataController()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(dataController)
    }
  }
}

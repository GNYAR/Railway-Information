//
//  TrainTag.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/21.
//

import SwiftUI

struct TrainTag: View {
  @State var isActive: Bool = false
  let trainNo: String
  let trainTypeCode: String
  
  var body: some View {
    Button(trainNo, action: { isActive = true })
      .scaleEffect(0.8)
      .buttonStyle(CTagButton(color: Color("TrainType\(trainTypeCode)")))
      .fullScreenCover(isPresented: $isActive) {
        TrainView(isActive: $isActive, trainNo: trainNo, trainTypeCode: trainTypeCode)
      }
    
  }
}

//
//  TrainTag.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/21.
//

import SwiftUI

struct TrainTag: View {
  let trainNo: String
  let trainTypeCode: String
  
  var body: some View {
    Button(trainNo, action: {
      print(trainNo)
    })
    .scaleEffect(0.8)
    .buttonStyle(CTagButton(color: Color("TrainType\(trainTypeCode)")))
  }
}

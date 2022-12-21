//
//  TrainView.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/21.
//

import SwiftUI

struct TrainView: View {
  @Binding var isActive: Bool
  let trainNo: String
  
  var body: some View {
    VStack {
      HStack {
        Text(trainNo)
        Spacer()
        Button(action: { isActive = false }, label: {
          Image(systemName: "xmark")
        })
      }
      Spacer()
    }
    .padding()
  }
}

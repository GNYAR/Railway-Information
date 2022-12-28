//
//  Share.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/25.
//

import SwiftUI
import UIKit

struct Share: UIViewControllerRepresentable {
  let urlString: String
  
  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: [URL(string: urlString)!], applicationActivities: nil)
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
  
  typealias UIViewControllerType = UIActivityViewController
}

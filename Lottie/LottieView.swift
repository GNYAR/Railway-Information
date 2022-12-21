//
//  LottieView.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/21.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
  let lottieFile: String
  var loop: LottieLoopMode = .playOnce
  
  let animationView = LottieAnimationView()
  
  func makeUIView(context: Context) -> some UIView {
    let view = UIView(frame: .zero)
    
    animationView.animation = Animation.named(lottieFile)
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = loop
    animationView.play()
    
    view.addSubview(animationView)
    
    animationView.translatesAutoresizingMaskIntoConstraints = false
    animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    
    return view
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    
  }
}

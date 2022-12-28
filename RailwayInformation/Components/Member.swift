//
//  Member.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/14.
//

import SwiftUI

struct Member: View {
  @State var showAnimation = false
  @State var showLogin = false
  @State var showRegister = false
  @StateObject var memberController = MemberController()
  @State var isFirst = true
  @State var isAnimationComplete = false
  
  var body: some View {
    let acc = memberController.user?.login
    let isLogin = acc != nil
    
    VStack {
      HStack(spacing: 24) {
        ZStack {
          Circle()
            .frame(width: 50, height: 50)
            .foregroundColor(.accentColor)
          
          Text(acc?.prefix(1) ?? "?")
            .foregroundColor(.white)
            .font(.title)
        }
        
        Text(acc ?? "尚未登入")
          .font(.title3)
        
        Spacer()
        
        if isLogin {
          Button("登出", action: { memberController.logout() })
            .onAppear {
              if isFirst { memberController.localAuth() }
            }
        } else {
          Button("註冊", action: {
            showRegister = true
            isFirst = false
          })
          .sheet(isPresented: $showRegister) {
            Register(
              show: $showRegister,
              controller: memberController
            )
          }
          
          Button("登入", action: {
            showLogin = true
            isFirst = false
          })
          .buttonStyle(CButton())
          .sheet(isPresented: $showLogin) {
            Register(
              show: $showLogin,
              controller: memberController,
              isLoginAction: true
            )
          }
        }
      }.padding()
      
      Spacer()
    }
    .onChange(of: isLogin, perform: { x in
      if x {
        isAnimationComplete = false
        showAnimation = true
      }
    })
    .onDisappear { isFirst = false }
    .overlay(Group {
      if showAnimation && !isAnimationComplete {
        LottieView(
          lottieFile: "checked",
          isComplete: $isAnimationComplete
        )
      }
    })
  }
}

struct Member_Previews: PreviewProvider {
  static var previews: some View {
    Member()
  }
}

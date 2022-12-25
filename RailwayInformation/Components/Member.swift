//
//  Member.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/14.
//

import SwiftUI

struct Member: View {
  @State var showLogin = false
  @State var showRegister = false
  @StateObject var memberController = MemberController()
  @State var isFirst = true
  
  var body: some View {
    let isLogin = memberController.user?.login != nil
    VStack {
      Text(memberController.user?.login ?? "尚未登入")
      
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
        .sheet(isPresented: $showLogin) {
          Register(
            show: $showLogin,
            controller: memberController,
            isLoginAction: true
          )
        }
      }
    }
    .onDisappear {
      isFirst = false
    }
  }
}

struct Member_Previews: PreviewProvider {
  static var previews: some View {
    Member()
  }
}

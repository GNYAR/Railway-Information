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
  
  var body: some View {
    VStack {
      Text(memberController.user?.login ?? "尚未登入")
      
      Button("註冊", action: { showRegister = true })
        .sheet(isPresented: $showRegister) {
          Register(
            show: $showRegister,
            controller: memberController
          )
        }
      
      Button("登入", action: { showLogin = true })
        .sheet(isPresented: $showLogin) {
          Register(
            show: $showLogin,
            controller: memberController,
            isLoginAction: true
          )
        }
    }
  }
}

struct Member_Previews: PreviewProvider {
  static var previews: some View {
    Member()
  }
}

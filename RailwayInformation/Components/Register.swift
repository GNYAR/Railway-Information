//
//  Register.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/14.
//

import SwiftUI

struct Register: View {
  @Binding var show: Bool
  @StateObject var controller: MemberController
  @State var login: String = ""
  @State var email: String = ""
  @State var password: String = ""
  
  var body: some View {
    if controller.user?.login != nil {
      Text("註冊完成！")
        .onAppear {
          Timer.scheduledTimer(
            withTimeInterval: 3,
            repeats: false
          ) { _ in show = false }
        }
    }
    else if controller.isLoading {
      ProgressView()
    } else {
      Form {
        Section(
          header:
            Text("註冊帳號")
            .font(.title)
            .foregroundColor(.primary),
          content: {}
        )
        .padding(.top)
        
        CField(
          input: $login,
          title: "使用者名稱",
          placeholder: "可包含字母、數字以及底線(_)"
        )
        
        CField(
          input: $email,
          title: "電子郵件",
          placeholder: "Email"
        )
        
        CField(
          input: $password,
          title: "密碼",
          placeholder: "至少５字",
          isSecure: true
        )
        
        Section(
          header:
            HStack(spacing: 24) {
              Spacer()
              
              Button("取消", action: { show = false })
                .font(.body)
                .foregroundColor(.accentColor)
              
              Button("註冊", action: {
                controller.createUser(
                  login: login,
                  email: email,
                  password: password
                )
              })
              .font(.body)
              .buttonStyle(CButton())
            },
          content: {}
        )
      }
    }
  }
}

struct CField: View {
  @Binding var input: String
  let title: String
  let placeholder: String
  var isSecure: Bool = false
  
  var body: some View {
    Section(header: Text(title)) {
      if isSecure {
        SecureField(placeholder, text: $input)
      } else {
        TextField(placeholder, text: $input)
      }
    }
  }
}

struct CButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal)
      .padding(.vertical, 8)
      .background(Color.accentColor)
      .foregroundColor(.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}


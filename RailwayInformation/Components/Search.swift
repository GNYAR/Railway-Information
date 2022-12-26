//
//  Search.swift
//  RailwayInformation
//
//  Created by User20 on 2022/12/25.
//

import SwiftUI

struct Search: View {
  @EnvironmentObject var dataController: DataController
  @State var isTrainShow: Bool = false
  @State var keyword: String = ""
  
  @AppStorage("searchRecords") var appRecords: Data?
  @State var records: [Record] = [] {
    didSet {
      do {
        appRecords = try JSONEncoder().encode(records)
      } catch {
        print(error)
      }
    }
  }
  
  init() {
    if let appRecords = appRecords {
      do {
        records = try JSONDecoder().decode([Record].self, from: appRecords)
      } catch {
        print(error)
      }
    }
  }
  
  var body: some View {
    let xs = dataController.stations.sorted(by: {a, b in
      a.key < b.key
    })
    let isAllNumber = keyword
      .range(of: "^[0-9]*$", options: .regularExpression) != nil
    let filtered = xs.filter({ _, x in
      x.StationName.Zh_tw.contains(keyword) ||
        x.StationName.En.contains(keyword)
    })
    
    NavigationView {
      VStack {
        SearchBar(text: $keyword, placeHolder: "搜尋車站／今日車次")
          .padding(.top)
        
        
        if keyword == "" {
          Spacer()
          Text("請輸入關鍵字")
            .foregroundColor(.secondary)
          Spacer()
          
        } else if isAllNumber {
          HStack {
            Button("搜尋今日車次 \(keyword)", action: { isTrainShow = true })
              .fullScreenCover(isPresented: $isTrainShow) {
                TrainView( isActive: $isTrainShow, trainNo: keyword)
              }
            
            Spacer()
          }.padding()
          
          Spacer()
          
        } else if filtered.isEmpty {
          Spacer()
          Text("查無資料")
            .foregroundColor(.secondary)
          Spacer()
          
        } else {
          List {
            ForEach(filtered, id: \.key) { _, x in
              NavigationLink(
                x.StationName.Zh_tw,
                destination: StationView(id: x.StationID)
              )
            }
          }
          .listStyle(PlainListStyle())
        }
      }
      .navigationTitle("搜尋")
      .navigationBarHidden(true)
    }
  }
  
  struct Record: Codable {
    var station: Station?
    var trainNo: String?
  }
}

struct SearchBar: View {
  @Binding var text: String
  @State private var isEditing = false
  var placeHolder: String = "Search..."
  
  var body: some View {
    HStack {
      TextField(placeHolder, text: $text)
        .padding(7)
        .padding(.horizontal, 25)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .overlay(
          HStack {
            Image(systemName: "magnifyingglass")
              .foregroundColor(.gray)
              .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 8)
            
            if isEditing {
              Button(action: {
                self.text = ""
              }) {
                Image(systemName: "multiply.circle.fill")
                  .foregroundColor(.gray)
                  .padding(.trailing, 8)
              }
            }
          }
        )
        .padding(.horizontal, 10)
        .onTapGesture {
          self.isEditing = true
        }
      
      if isEditing {
        Button(action: {
          self.isEditing = false
          self.text = ""
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
          
        }) {
          Text("Cancel")
        }
        .padding(.trailing, 10)
        .transition(.move(edge: .trailing))
        .animation(.default)
      }
    }
  }
}

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
        
        if keyword == "" && records.isEmpty {
          Spacer()
          Text("請輸入關鍵字")
            .foregroundColor(.secondary)
          Spacer()
          
        } else if keyword == "" && !(records.isEmpty) {
          let reversed = records.reversed()
          let trains = reversed.filter({ $0.train != nil })
            .map({ $0.train! })
          let stations = reversed.filter({ $0.station != nil })
            .map({ $0.station! })
          
          HStack {
            Text("歷史紀錄")
              .foregroundColor(.secondary)
            
            Spacer()
            
            Button("清除全部", action: { records.removeAll() })
          }.padding(.horizontal)
          
          ScrollView(.horizontal) {
            HStack {
              ForEach(trains) { x in
                TrainTag(trainNo: x.trainNo, trainTypeCode: x.trainTypeCode)
              }
            }.padding(.horizontal)
          }
          
          Divider().padding(.horizontal)
          
          List {
            ForEach(stations) { x in
              NavigationLink(
                x.StationName.Zh_tw,
                destination: StationView(id: x.StationID)
                  .onAppear {
                    let index = getStationIndexInRecords(x)
                    records.move(
                      fromOffsets: IndexSet(integer: index!),
                      toOffset: records.count
                    )
                  }
              )
            }
            .onDelete { index in
              let x = stations[index.first!]
              records.remove(at: getStationIndexInRecords(x)!)
            }
          }
          
        } else if isAllNumber {
          HStack {
            Button("搜尋今日車次 \(keyword)", action: { isTrainShow = true })
              .fullScreenCover(isPresented: $isTrainShow) {
                TrainView( isActive: $isTrainShow, trainNo: keyword)
                  .onDisappear {
                    let train = dataController.trainTimeTable?.TrainInfo
                    if train == nil { return }
                    
                    records.append(Record(train: TrainRecord(
                      trainNo: train!.TrainNo,
                      trainTypeCode: train!.TrainTypeCode
                    )))
                  }
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
                  .onAppear { records.append(Record(station: x)) }
              )
            }
          }
        }
      }
      .navigationTitle("搜尋")
      .navigationBarHidden(true)
      .listStyle(PlainListStyle())
    }
    .onAppear {
      if let appRecords = appRecords {
        do {
          records = try JSONDecoder().decode([Record].self, from: appRecords)
        } catch {
          print(error)
        }
      }
    }
  }
  
  struct Record: Codable {
    var station: Station?
    var train: TrainRecord?
  }
  
  struct TrainRecord: Codable, Identifiable {
    var id: String { trainNo }
    
    let trainNo: String
    let trainTypeCode: String
  }
  
  func getStationIndexInRecords(_ x: Station) -> Int? {
    records
      .firstIndex(where: { $0.station?.id == x.id })
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
          
        }) { Text("取消") }
        .padding(.vertical, 7)
        .padding(.trailing, 10)
        .transition(.move(edge: .trailing))
        .animation(.default)
      }
    }
  }
}

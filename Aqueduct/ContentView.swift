//
//  ContentView.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 13/04/2022.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var model: Model
  
  @Binding var showExport: Bool
  @Binding var showAdd: Bool
  
  @State var selectedChannel: Channel? = nil
  
  func add() {
    showAdd.toggle()
  }
  
  var body: some View {
    NavigationView {
      Sidebar(selectedChannel: $selectedChannel)
        .toolbar {
          Button(action: add) {
            Image(systemName: "plus")
          }
          RefreshButton(isLoading: model.isLoading, action: {
            Task {
              await model.refresh()
            }
          })
        }
      PostListView(filter: nil)
    }
    .task {
      await model.refresh()
    }
    .sheet(isPresented: $showAdd) {
      AddView()
    }
    .sheet(isPresented: $showExport) {
      ExportView()
    }
    .sheet(isPresented: Binding(
      get: { self.selectedChannel != nil },
      set: {
        if !$0 {
          self.selectedChannel = nil
        }
      }
    )) {
      TagView(selectedChannel: $selectedChannel)
    }
  }
}



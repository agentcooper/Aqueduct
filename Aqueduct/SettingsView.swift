//
//  SettingsView.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 25/06/2022.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var model: Model
  @Environment(\.openURL) var openURL
  
  var body: some View {
    TabView {
      Form {
        Picker("Default category", selection: $model.defaultCategory) {
          Text("Feed").tag("Feed")
          ForEach(model.tagNames(), id: \.self) { tagName in
            Text(tagName).tag(tagName)
          }
        }
      }
      .tabItem { Label("Viewing", systemImage: "eyeglasses") }
      
      TabView {
        Form {
          Toggle(isOn: $model.removeForeignAgentText) {
            Text("Remove foreign agent text").bold()
            Text("ДАННОЕ СООБЩЕНИЕ (МАТЕРИАЛ)...").italic().foregroundColor(.gray)
          }
        }
      }.tabItem { Label("Content filters", systemImage: "paintbrush") }
      
      TabView {
        Form {
          Button(role: .destructive) {
            model.channels = []
            model.posts = []
            model.save()
          } label: {
            Label("Remove all data", systemImage: "trash").foregroundColor(.red)
          }
        }
      }.tabItem { Label("Data", systemImage: "folder") }
    }
    .frame(width: 500, height: 200)
    .padding(20)
  }
}

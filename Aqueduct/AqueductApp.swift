//
//  AqueductApp.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 13/04/2022.
//

import SwiftUI

@main
struct AqueductApp: App {
  @Environment(\.openURL) var openURL
  @StateObject private var model = Model()
  
  @State var showExport: Bool = false
  @State var showAdd: Bool = false
  
  var body: some Scene {
    WindowGroup {
      ContentView(showExport: $showExport, showAdd: $showAdd).environmentObject(model)
        .onAppear {
          model.load()
        }
    }.commands {
      SidebarCommands()
      CommandGroup(replacing: CommandGroupPlacement.newItem) {
        Button("Add…") {
          showAdd.toggle()
        }.keyboardShortcut("n", modifiers: [.command])
      }
      CommandGroup(after: CommandGroupPlacement.newItem) {
        Button("Export as Markdown…") {
          showExport.toggle()
        }.keyboardShortcut("e", modifiers: [.command])
      }
      CommandMenu("Posts") {
        Button("Expand all") {
          model.expandAllAction()
        }.keyboardShortcut("+", modifiers: [.command])
        Button("Collapse all") {
          model.collapseAllAction()
        }.keyboardShortcut("-", modifiers: [.command])
      }
    }
  }
}

func copyToClipBoard(textToCopy: String) {
  let pasteBoard = NSPasteboard.general
  pasteBoard.clearContents()
  pasteBoard.setString(textToCopy, forType: .string)
}

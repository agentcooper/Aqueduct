//
//  RefreshButton.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 20/06/2022.
//

import SwiftUI

struct RefreshButton: View {
  let isLoading: Bool
  
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Image(systemName: "arrow.clockwise.circle")
        .opacity(isLoading ? 0 : 1)
        .overlay(alignment: .center) {
          if isLoading {
            ProgressView().progressViewStyle(.circular).scaleEffect(0.5)
          } else {
            EmptyView()
          }
        }
    }
    .help("Refresh")
    .keyboardShortcut("r", modifiers: [.command])
  }
}

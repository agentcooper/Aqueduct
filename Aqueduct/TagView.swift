//
//  TagView.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 20/06/2022.
//

import SwiftUI

struct TagView: View {
  @EnvironmentObject var model: Model
  
  @Binding var selectedChannel: Channel?
  
  @State var tagInput = ""
  
  var body: some View {
    VStack {
      TextField("Tags (separated by comma or space)", text: $tagInput)
        .onSubmit {
          let indices: [Array.Index] = model.channels.enumerated().compactMap { (index, element) in
            
            if element == selectedChannel {
              return index
            }
            
            return nil
          }
          
          let tags: [String] = tagInput.components(separatedBy: CharacterSet(charactersIn: ", ")).compactMap {
            let trimmmed = $0.trimmingCharacters(in: .whitespaces)
            if trimmmed.isEmpty {
              return nil
            }
            return trimmmed
          }
          
          for index in indices {
            model.channels[index].tags = tags
          }
          model.save()
          
          selectedChannel = nil
        }
    }
    .onAppear {
      tagInput = ""
    }
    .padding()
    .frame(minWidth: 400)
    .onExitCommand {
      selectedChannel = nil
    }
  }
}

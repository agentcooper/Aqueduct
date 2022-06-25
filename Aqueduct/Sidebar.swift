//
//  Sidebar.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 20/06/2022.
//

import SwiftUI

struct Sidebar: View {
  @EnvironmentObject var model: Model
  @Environment(\.openURL) var openURL
  
  @Binding var selectedChannel: Channel?
  
  @State var selection: String?
  
  var body: some View {
    List {
      NavigationLink(
        destination: PostListView(filter: nil),
        tag: "Feed",
        selection: $selection,
        label: {
          Text("Feed")
        })
      
      Section(header: Text("Tags")) {
        ForEach(model.tagNames(), id: \.self) { tagName in
          NavigationLink(
            destination: PostListView(filter: .tag(tagName: tagName)),
            tag: tagName,
            selection: $selection,
            label: {
              Text(tagName)
            })
        }
      }
      
      Section(header: Text("Channels")) {
        ForEach(model.channels.sorted()) { channel in
          NavigationLink(
            destination: PostListView(filter: .channel(channel: channel)),
            tag: channel.id,
            selection: $selection,
            label: {
              Text(channel.label)
            }).contextMenu {
              channelContextMenuItems(channel: channel)
            }
        }
      }
    }
    .frame(minWidth: 200)
    .listStyle(.sidebar)
    .onAppear {
      selection = model.defaultCategory
    }
  }
  
  @ViewBuilder
  func channelContextMenuItems(channel: Channel) -> some View {
    Button {
      openURL(channel.getTelegramWebURL())
    } label: {
      Text("Open on Web")
    }
    
    Divider()
    
    Button {
      selectedChannel = channel
    } label: {
      Text("Set tags…")
    }
    
    if !channel.tags.isEmpty {
      ForEach(channel.tags, id: \.self) { tag in
        Text(tag)
      }
    }
    
    Divider()
    
    Button {
      copyToClipBoard(textToCopy: channel.getTelegramWebURL().absoluteString)
    } label: {
      Text("Copy URL")
    }
    
    Divider()
    
    Button("Delete") {
      model.removeChannel(channel)
      model.save()
    }
  }
}

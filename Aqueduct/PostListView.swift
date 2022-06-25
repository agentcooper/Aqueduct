//
//  PostListView.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 20/06/2022.
//

import SwiftUI

enum Filter {
  case channel(channel: Channel)
  case tag(tagName: String)
}

struct PostListView: View {
  @EnvironmentObject var model: Model
  
  let filter: Filter?
  
  @State var collapseState = [Post.ID: Bool]()
  
  func filteredPosts(_ filter: Filter?) -> [Post] {
    switch filter {
    case .channel(let channel):
      return model.posts.filter { $0.channelId == channel.id }
    case .tag(let tagName):
      return model.posts.filter { post in
        guard let channel = model.channels.first(where: { $0.id == post.channelId }) else {
          return false
        }
        return channel.tags.contains(tagName)
      }
    case .none:
      return model.posts
    }
  }
  
  func isCollapsedByDefault() -> Bool {
    switch filter {
    case .channel(channel: _): return false
    default: return true
    }
  }
  
  func isCollapsed(_ post: Post) -> Binding<Bool> {
    Binding(
      get: {
        return collapseState[post.id] ?? isCollapsedByDefault()
      },
      set: { collapseState[post.id] = $0 }
    )
  }
  
  func setCollapsed(_ filter: Filter?, value: Bool) {
    for post in filteredPosts(filter) {
      collapseState[post.id] = value
    }
  }
  
  func getNavigationTitle() -> String {
    switch filter {
    case .channel(channel: let channel): return channel.label
    case .tag(tagName: let tagName): return "Tag: \(tagName)"
    case .none: return "Feed"
    }
  }
  
  var body: some View {
    if model.channels.isEmpty {
      Text("No channels found. Press ⌘N to add.")
        .font(.title)
        .foregroundColor(Color.gray)
    } else {
      ScrollView {
        LazyVStack {
          ForEach(filteredPosts(filter)) { post in
            PostView(post: post, isCollapsed: isCollapsed(post))
          }
        }.padding()
      }
      .background(.background)
      .frame(minWidth: 400)
      .navigationTitle(getNavigationTitle())
      .onReceive(model.collapseState, perform: { value in
        setCollapsed(filter, value: value)
      })
      .toolbar {
        Button(action: {
          setCollapsed(filter, value: true)
        }) {
          Image(systemName: "arrow.up.to.line.compact")
        }.help("Collapse all (Command -)")
        
        Button(action: {
          setCollapsed(filter, value: false)
        }) {
          Image(systemName: "arrow.down.to.line.compact")
        }.help("Expand all (Command +)")
      }
    }
  }
}

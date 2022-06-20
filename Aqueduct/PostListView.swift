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
  
  var filteredPosts: [Post] {
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
  
  func createBinding(_ post: Post) -> Binding<Bool> {
    Binding(
      get: { collapseState[post.id] ?? true },
      set: { collapseState[post.id] = $0 }
    )
  }
  
  func expandAll() {
    for post in filteredPosts {
      collapseState[post.id] = false
    }
  }
  
  func collapseAll() {
    for post in filteredPosts {
      collapseState[post.id] = true
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
          ForEach(filteredPosts) { post in
            PostView(post: post, isCollapsed: createBinding(post))
          }
        }.padding()
      }
      .background(.background)
      .frame(minWidth: 400)
      .navigationTitle("Feed")
      .onAppear {
        model.expandAllAction = expandAll
        model.collapseAllAction = collapseAll
      }
    }
  }
}

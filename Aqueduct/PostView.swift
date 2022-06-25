//
//  PostView.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 20/06/2022.
//

import SwiftUI
import AVKit

struct PostView: View {
  @EnvironmentObject var model: Model
  @Environment(\.openURL) var openURL
  let post: Post
  
  @State var isHover = false
  @Binding var isCollapsed: Bool
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        if let userPhotoURL = post.userPhotoURL {
          AsyncImage(url: userPhotoURL) { image in
            image.resizable().clipShape(Circle())
          } placeholder: {
            ProgressView()
          }
          .tag(post.userPhotoURL)
          .frame(width: 40, height: 40)
        }
        Text(post.ownerName).font(.title2)
        
        Text(post.date.timeAgoDisplay()).foregroundColor(.gray)
        
        if isHover {
          Image(systemName: isCollapsed ? "arrow.down.to.line.compact" : "arrow.up.to.line.compact").foregroundColor(.gray)
        }
        Spacer()
      }
      
      Text(htmlToAttributedString(post.body, isCollapsed, removeForeignAgentText: model.removeForeignAgentText))
        .minimumScaleFactor(0.5)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
      if isCollapsed {
        Image(systemName: "ellipsis").padding(.top, 2).opacity(isHover ? 1 : 0.5)
      } else {
        if let mainPhoto = post.mainPhotoURL {
          ImageView(url: mainPhoto)
        }
        
        if !post.photoURLs.isEmpty {
          HStack {
            ForEach(post.photoURLs, id: \.self) {
              ImageView(url: $0)
            }
          }
        }
        
        if let videoURL = post.videoURL {
          VideoView(videoURL: videoURL)
        }
        
        if let preview = post.preview, let imageURL = preview.imageURL {
          ImageView(url: imageURL)
        }
      }
    }
    .contentShape(Rectangle())
    .padding(2)
    .onHover { over in isHover = over }
    .onTapGesture {
      isCollapsed.toggle()
    }
    .contextMenu {
      Button("Open on Web") {
        openURL(post.webURL)
      }
    }
    .frame(width: 500)
  }
}

struct ImageView: View {
  let url: URL?
  
  var body: some View {
    AsyncImage(url: url) { image in
      image.resizable().scaledToFit()
    } placeholder: {
      ProgressView()
    }
  }
}

extension Date {
  func timeAgoDisplay() -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: self, relativeTo: Date())
  }
}

struct VideoView: View {
  @State private var avPlayer: AVPlayer
  
  init(videoURL: URL) {
    let player = AVPlayer(url: videoURL)
    _avPlayer = .init(wrappedValue: player)
  }
  
  var body: some View {
    VStack {
      VideoPlayer(player: avPlayer).frame(height: 400)
    }
  }
}


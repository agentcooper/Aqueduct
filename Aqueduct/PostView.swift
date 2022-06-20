//
//  PostView.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 20/06/2022.
//

import SwiftUI

struct PostView: View {
  @Environment(\.openURL) var openURL
  let post: Post
  
  @State var isHover = false
  @Binding var isCollapsed: Bool
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        AsyncImage(url: post.userPhotoURL) { image in
          image.resizable().clipShape(Circle())
        } placeholder: {
          ProgressView()
        }.tag(post.userPhotoURL)
          .frame(width: 40, height: 40)
        Text(post.ownerName).font(.title2)
        
        Text(post.date.timeAgoDisplay()).foregroundColor(.gray)
        
        if isHover {
          Image(systemName: isCollapsed ? "arrow.down.to.line.compact" : "arrow.up.to.line.compact").foregroundColor(.gray)
        }
        Spacer()
      }
      if !isCollapsed, let mainPhoto = post.mainPhoto {
        AsyncImage(url: mainPhoto) { image in
          image.resizable().scaledToFit()
        } placeholder: {
          ProgressView()
        }
      }
      
      if !isCollapsed, !post.imageURLs.isEmpty {
        HStack {
          ForEach(post.imageURLs, id: \.self) { imageURL in
            AsyncImage(url: imageURL) { image in
              image.resizable().scaledToFit()
            } placeholder: {
              ProgressView()
            }
          }
        }
      }
      
      Text(htmlToAttributedString(post.html, isCollapsed))
        .minimumScaleFactor(0.5)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
      
      if isCollapsed {
        Image(systemName: "ellipsis").padding(.top, 2)
      }
      
      if !isCollapsed, let preview = post.preview, let imageURL = preview.imageURL {
        AsyncImage(url: imageURL) { image in
          image.resizable().scaledToFit().onTapGesture {
            openURL(preview.href)
          }
        } placeholder: {
          ProgressView()
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

extension Date {
  func timeAgoDisplay() -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: self, relativeTo: Date())
  }
}

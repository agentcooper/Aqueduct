//
//  Post.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 25/06/2022.
//

import Foundation
import SwiftSoup

struct Preview: Hashable {
  let imageURL: URL?
  let href: URL
}

struct Post: Identifiable, Hashable, Equatable {
  let id: String
  let date: Date
  let body: Element
  let userPhotoURL: URL?
  let ownerName: String
  let channelId: Channel.ID
  let photoURLs: [URL]
  let preview: Preview?
  let mainPhotoURL: URL?
  let videoURL: URL?
  
  var webURL: URL {
    URL(string: "https://t.me/\(id)")!
  }
}

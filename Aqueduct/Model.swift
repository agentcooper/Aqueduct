//
//  Store.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 01/06/2022.
//

import Foundation
import Combine
import SwiftUI

@MainActor class Model: ObservableObject {
  let telegram = TelegramAPI()
  let collapseState = PassthroughSubject<Bool, Never>()
  
  @Published var channels: [Channel] = []
  @Published var posts: [Post] = []
  @Published var isLoading = false
  
  @AppStorage("removeForeignAgentText") public var removeForeignAgentText = true
  @AppStorage("defaultCategory") public var defaultCategory = "Feed"
  
  func tagNames() -> [String] {
    Set(channels.flatMap { $0.tags }).sorted()
  }
  
  func refresh() async {
    defer {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.isLoading = false
      }
    }
    
    do {
      isLoading = true
      let allPosts = try await telegram.fetchChannels(channels: channels)
      
      
      for post in allPosts {
        setChannelTitle(channelId: post.channelId, title: post.ownerName)
      }
      
      posts = allPosts
      //      posts = Array(allPosts[0 ..< 1])
      //      posts = allPosts.filter { $0.id == "backtracking/1747" }
      
      save()
    } catch {
      print("Error")
    }
  }
  
  func removeChannel(_ channel: Channel) {
    guard let index = channels.firstIndex(of: channel) else {
      return
    }
    channels.remove(at: index)
  }
  
  func setChannelTitle(channelId: Channel.ID, title: String) {
    guard let index = channels.firstIndex(where: { $0.id == channelId }) else {
      return
    }
    channels[index].title = title
  }
  
  func addChannel(_ channel: Channel) {
    let existingIds = Set(channels.map { $0.id })
    if !existingIds.contains(channel.id) {
      channels.append(channel)
    }
  }
  
  func fileURL() throws -> URL {
    try FileManager.default.url(for: .documentDirectory,
                                in: .userDomainMask,
                                appropriateFor: nil,
                                create: false)
    .appendingPathComponent("data.json")
  }
  
  func load() {
    do {
      let fileURL = try fileURL()
      print(fileURL)
      guard let file = try? FileHandle(forReadingFrom: fileURL) else {
        return
      }
      
      let channels = try JSONDecoder().decode([Channel].self, from: file.availableData)
      
      self.channels = channels
    } catch {
      print(error)
      return
    }
  }
  
  func save() {
    do {
      let data = try JSONEncoder().encode(channels)
      let outfile = try fileURL()
      try data.write(to: outfile)
      print("Saved", outfile)
    } catch {
      print(error)
    }
  }
  
  func markdownExport(exportTags: Bool) -> String {
    var result = "";
    for (index, channel) in channels.enumerated() {
      let tags = channel.tags.map { "#\($0)" }.joined(separator: " ")
      
      let line = "\(index + 1). \(markdownLink(channel.label, channel.getTelegramWebURL().absoluteString)) \(exportTags ? tags : "")".trimmingCharacters(in: .whitespaces)
      
      result += "\(line)\n"
    }
    return result.trimmingCharacters(in: .whitespaces)
  }
}

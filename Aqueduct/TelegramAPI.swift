//
//  Telegram.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 01/06/2022.
//

import Foundation
import SwiftSoup

struct TelegramAPI {
  func getEmptyMessage() -> Element {
    return Element(Tag("div"), "")
  }
  
  func extractImageURL(style: String?) -> URL? {
    guard let style = style else {
      return nil
    }
    
    let urls = checkForUrls(text: style)
    
    return urls.first
  }
  
  func parseUserPhotoURL(_ message: Element) throws -> URL? {
    guard let userPhotoNode = try message.getElementsByClass("tgme_widget_message_user_photo").first() else {
      return nil
    }
    
    guard let userPhotoImage = try userPhotoNode.getElementsByTag("img").first() else {
      return nil
    }
    
    return URL(string: try userPhotoImage.attr("src"))
  }
  
  func parsePreview(_ message: Element) throws -> Preview? {
    let previewElement = try message.getElementsByClass("tgme_widget_message_link_preview").first()
    
    if let previewElement = previewElement {
      var foundPreviewURL: URL? = nil
      let href = try previewElement.attr("href")
      
      let previewImages = try previewElement.select(".link_preview_image,.link_preview_right_image")
      
      for previewImage in previewImages.array() {
        let content = try previewImage.attr("style")
        
        let urls = checkForUrls(text: content)
        
        if let first = urls.first {
          foundPreviewURL = first
        }
      }
      
      return Preview(imageURL: foundPreviewURL, href: URL(string: href)!)
    }
    
    return nil
  }
  
  func parseHTML(_ html: String, channel: Channel) -> [Post] {
    var result = [Post]()
    
    do {
      let doc: Document = try SwiftSoup.parse(html)
      
      let messages: Elements = try doc.getElementsByClass("js-widget_message")
      
      for message in messages.array() {
        var photoURLs = [URL]()
        let photos = try message.getElementsByClass("js-message_photo")
        for photo in photos.array() {
          let style = try photo.attr("style")
          
          for url in checkForUrls(text: style) {
            photoURLs.append(url)
          }
        }
        
        guard let ownerName = try message.getElementsByClass("tgme_widget_message_owner_name").first() else {
          continue
        }
        
        let id = try message.attr("data-post")
        
        let messageText = try message.getElementsByClass("js-message_text").first() ?? getEmptyMessage()
        
        let mainPhoto = extractImageURL(style: try message.getElementsByClass("tgme_widget_message_photo_wrap").first()?.attr("style"))

        let videoSrc = try message.select(".js-message_video_player video").first()?.attr("src")
        let videoURL: URL? = videoSrc.map { URL(string: $0)! }
        
        guard let time = try message.getElementsByClass("time").first() else {
          print("NOT FOUND time for \(id)")
          continue
        }
        
        let datetime = try time.attr("datetime")
        
        let newFormatter = ISO8601DateFormatter()
        guard let date = newFormatter.date(from: datetime) else {
          print("Wrong data")
          continue
        }
        
        let post = Post(
          id: try message.attr("data-post"),
          date: date, body: messageText,
          userPhotoURL: try parseUserPhotoURL(message),
          ownerName: try ownerName.text(),
          channelId: channel.id,
          photoURLs: photoURLs,
          preview: try parsePreview(message),
          mainPhotoURL: mainPhoto,
          videoURL: videoURL
        )
        
        result.append(post)
      }
      
    } catch Exception.Error(let type, let message) {
      print(message, type)
    } catch {
      print("error")
    }
    
    return result
  }
  
  func fetchPosts(_ channel: Channel) async -> [Post]  {
    var request = URLRequest(url: URL(string: "https://t.me/s/\(channel.id)")!)
    request.httpMethod = "POST"
    request.setValue("application/json, text/javascript, */*; q=0.01", forHTTPHeaderField: "Accept")
    request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
    
    guard let (data, _) = try? await URLSession.shared.data(for: request) else {
      print("Can't fetch")
      return []
    }
    
    guard let html = String(bytes: data, encoding: String.Encoding.utf8) else {
      print("Bad data")
      return []
    }
    
    return parseHTML(html.unescaped, channel: channel)
  }
  
  func fetchChannels(channels: [Channel]) async throws -> [Post]  {
    let posts = try await withThrowingTaskGroup(of: [Post].self) { group -> [Post] in
      for channel in channels {
        group.addTask{
          let posts = await self.fetchPosts(channel)
          return posts
        }
      }
      
      var allPosts = [Post]()
      
      for try await posts in group {
        allPosts.append(contentsOf: posts)
      }
      
      return allPosts.sorted { a, b in b.date < a.date }
    }
    
    return posts
  }
}

extension String {
  var unescaped: String {
    let entities = ["\0": "\\0",
                    "\t": "\\t",
                    "\n": "\\n",
                    "\r": "\\r",
                    "\"": "\\\"",
                    "\'": "\\'",
    ]
    
    return entities
      .reduce(self) { (string, entity) in
        string.replacingOccurrences(of: entity.value, with: entity.key)
      }
      .replacingOccurrences(of: "\\\\(?!\\\\)", with: "", options: .regularExpression)
      .replacingOccurrences(of: "\\\\", with: "\\")
  }
}

func checkForUrls(text: String) -> [URL] {
  let types: NSTextCheckingResult.CheckingType = .link
  
  do {
    let detector = try NSDataDetector(types: types.rawValue)
    
    let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
    
    return matches.compactMap({$0.url})
  } catch let error {
    debugPrint(error.localizedDescription)
  }
  
  return []
}



func copyUntilFirstLineBreak(_ input: Element) -> Element {
  let copy = input.copy() as! Element
  
  guard let firstBr = try? copy.getElementsByTag("br").first() else {
    return copy
  }
  
  let parents = firstBr.parents()
  var targetIndex = firstBr.siblingIndex
  
  // go up the parent chain, inside every parent node,
  // remove children starting with targetIndex
  for parent in parents {
    for childNode in parent.getChildNodes() {
      if childNode.siblingIndex >= targetIndex {
        try? childNode.remove()
      }
    }
    targetIndex = parent.siblingIndex + 1
    
    if parent == copy {
      break;
    }
  }
  
  return copy
}

func trim(_ element: Node) -> Node {
  let copy = element.copy() as! Node
  
  for child in copy.getChildNodes() {
    if child.nodeName() == "br" {
      try? child.remove()
    }
  }
  
  return copy
}

func htmlToAttributedString(_ html: Element, _ isCollapsed: Bool, removeForeignAgentText: Bool) -> AttributedString {
  let copy = html.copy() as! Element
  
  if isCollapsed {
    let mainContent = copyUntilFirstLineBreak(copy)
    return htmlToAttributedString(mainContent, false, removeForeignAgentText: removeForeignAgentText)
  }
  
  if removeForeignAgentText {
    for child in copy.textNodes() {
      if child.text().contains("ДАННОЕ СООБЩЕНИЕ (МАТЕРИАЛ)") {
        
        if let previousSibling = child.previousSibling() {
          if previousSibling.nodeName() == "br" {
            try? previousSibling.remove()
          }
          
          if previousSibling.nodeName() == "b" {
            if let last = previousSibling.getChildNodes().last, last.nodeName() == "br" {
              try? last.remove()
            }
          }
        }
        
        if let nextSibling = child.nextSibling(), nextSibling.nodeName() == "br" {
          try? nextSibling.remove()
        }
        
        try? child.remove()
        
        break;
      }
    }
  }
  
  guard let content = try? copy.html() else {
    return AttributedString(stringLiteral: "???")
  }
  
  let data = NSString(string: content).data(using: String.Encoding.unicode.rawValue)!
  
  guard let nsAttributedString = NSAttributedString(html: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
    
    return AttributedString("Error: could not parse text!")
  }
  
  var attributedString = AttributedString(nsAttributedString)
  attributedString.font = .body
  return attributedString
}

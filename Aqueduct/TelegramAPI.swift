//
//  Telegram.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 01/06/2022.
//

import Foundation
import SwiftSoup

struct Channel: Identifiable, Hashable, Codable, Equatable {
  let id: String
  var title: String?
  var tags: [String]
  
  var label: String {
    title ?? id
  }
  
  func getTelegramWebURL() -> URL {
    return URL(string: "http://t.me/\(id)")!
  }
}

struct Preview: Hashable {
  let imageURL: URL?
  let href: URL
}

struct Post: Identifiable, Hashable, Equatable {
  let id: String
  let date: Date
  let html: Element
  let userPhotoURL: URL
  let ownerName: String
  let shortText: String
  let channelId: Channel.ID
  let imageURLs: [URL]
  let preview: Preview?
  let mainPhoto: URL?
  
  var isCollapsed: Bool
  
  var webURL: URL {
    URL(string: "https://t.me/\(id)")!
  }
}

struct TelegramAPI {
  func extractImageURL(style: String?) -> URL? {
    guard let style = style else {
      return nil
    }

    let urls = checkForUrls(text: style)
    
    return urls.first
  }
  
  func parseHTML(_ html: String, channel: Channel) -> [Post] {
    var result = [Post]()
    
    do {
      let doc: Document = try SwiftSoup.parse(html)
      
      let messages: Elements = try doc.getElementsByClass("js-widget_message")
      
      for message in messages.array() {
        
        var imageURLs = [URL]()
        let photos = try message.getElementsByClass("js-message_photo")
        for photo in photos.array() {
          let style = try photo.attr("style")
          
          for url in checkForUrls(text: style) {
            imageURLs.append(url)
          }
        }
        
        let previewElement = try message.getElementsByClass("tgme_widget_message_link_preview").first()
        
        var preview: Preview? = nil
        if let previewElement = previewElement {
          var foundPreviewURL: URL? = nil
          let href = try previewElement.attr("href")
          
          let styles = try previewElement.getElementsByAttribute("style")
          
          for style in styles.array() {
            let content = try style.attr("style")
            
            let urls = checkForUrls(text: content)
            
            if let first = urls.first {
              foundPreviewURL = first
            }
          }
          
          preview = Preview(imageURL: foundPreviewURL, href: URL(string: href)!)
        }
        
        guard let ownerName = try message.getElementsByClass("tgme_widget_message_owner_name").first() else {
          continue
        }
        
        guard let messageText = try message.getElementsByClass("js-message_text").first() else {
          print("NOT FOUND")
          continue
        }
        
        let mainPhoto = extractImageURL(style: try message.getElementsByClass("tgme_widget_message_photo_wrap").first()?.attr("style"))
        
        guard let userPhotoNode = try message.getElementsByClass("tgme_widget_message_user_photo").first() else {
          print("NOT FOUND")
          continue
        }
        
        guard let userPhotoImage = try userPhotoNode.getElementsByTag("img").first() else {
          print("Can't find photo")
          continue
        }
        
        guard let time = try message.getElementsByClass("time").first() else {
          print("NOT FOUND")
          continue
        }
        
        let datetime = try time.attr("datetime")
        
        let newFormatter = ISO8601DateFormatter()
        guard let date = newFormatter.date(from: datetime) else {
          print("Wrong data")
          continue
        }
        
        for child in messageText.textNodes() {
            if child.text().contains("ДАННОЕ СООБЩЕНИЕ (МАТЕРИАЛ)") {
              child.text("🕵️‍♀️")
            }
        }
        
        let post = Post(id: try message.attr("data-post"), date: date, html: messageText, userPhotoURL: URL(string: try userPhotoImage.attr("src"))!, ownerName: try ownerName.text(), shortText: try messageText.text(), channelId: channel.id, imageURLs: imageURLs, preview: preview, mainPhoto: mainPhoto, isCollapsed: true)
        
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



func getMainContent(html: Element) -> Element {
  var nodesUntilFirstLine = [Node]()
  
  var didFoundSomeElement = false
  
  for child in html.getChildNodes() {
    if didFoundSomeElement, child.nodeName() == "br" {
      break;
    }
    
    didFoundSomeElement = true
    nodesUntilFirstLine.append(trim(child))
  }
  
  var el = Element(Tag("div"), "")
  try? el.insertChildren(0, nodesUntilFirstLine)
  
  return el
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

func htmlToAttributedString(_ html: Element, _ isCollapsed: Bool) -> AttributedString {
  if isCollapsed {
    let mainContent = getMainContent(html: html)
    return htmlToAttributedString(mainContent, false)
  }
  
  guard let content = try? html.html() else {
    return AttributedString(stringLiteral: "???")
  }
  
  let data = NSString(string: applyFilters(html: content)).data(using: String.Encoding.unicode.rawValue)!
  
  guard let nsAttributedString = NSAttributedString(html: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
    
    return AttributedString("Error: could not parse text!")
  }
  
  var attributedString = AttributedString(nsAttributedString)
  attributedString.font = .body
  return attributedString
}

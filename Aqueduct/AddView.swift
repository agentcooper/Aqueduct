//
//  AddView.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 20/06/2022.
//

import SwiftUI

struct ParseResult: Equatable {
  let channelId: String
  let tags: [String]
}

struct AddView: View {
  @EnvironmentObject var model: Model
  
  @Environment(\.openURL) var openURL
  @Environment(\.dismiss) var dismiss
  
  @State private var fullText: String = ""
  @State private var isAdding = false
  
  func extractURLs(text: String) -> [(URL, NSRange)] {
    let types: NSTextCheckingResult.CheckingType = .link
    
    do {
      let detector = try NSDataDetector(types: types.rawValue)
      
      let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
      
      return matches.compactMap {
        if let url = $0.url {
          return (url, $0.range)
        }
        return nil
      }
    } catch let error {
      debugPrint(error.localizedDescription)
    }
    
    return []
  }
  
  func extractTags(line: String) -> [String] {
    let words = line.components(separatedBy: CharacterSet(charactersIn: ", "))
    var tags = [String]()
    for word in words {
      if word.hasPrefix("#") {
        let tag = word.dropFirst()
        tags.append(String(tag))
      }
    }
    return tags
  }
  
  func parseSources(input: String) -> [ParseResult] {
    var result = [ParseResult]()
    let lines = input.split(whereSeparator: \.isNewline)
    for line in lines {
      let line = String(line)
      let urls = extractURLs(text: line)
      guard let (url, range) = urls.first else {
        if line.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil {
          result.append(ParseResult(channelId: line, tags: []))
        }
        continue
      }
      let startIndex = line.index(line.startIndex, offsetBy: range.upperBound)
      let lineAfterURL = String(line[startIndex..<line.endIndex])
      let tags = extractTags(line: lineAfterURL)
      
      if let channelId = url.pathComponents[safe: 1] {
        if channelId == "s", let actualChannelId = url.pathComponents[safe: 2] {
          result.append(ParseResult(channelId: actualChannelId, tags: tags))
        } else {
          result.append(ParseResult(channelId: channelId, tags: tags))
        }
      }
    }
    return result
  }
  
  func addChannels() async {
    defer {
      isAdding = false
    }
    isAdding = true
    
    for parseResult in parseSources(input: fullText) {
      model.addChannel(Channel(id: parseResult.channelId, title: nil, tags: parseResult.tags))
    }
    
    model.save()
    
    dismiss()
    
    await model.refresh()
  }
  
  var body: some View {
    VStack {
      Text("Channel ID or Channel URL, separated by newlines:")
        .frame(maxWidth: .infinity)
      TextEditor(text: $fullText)
        .font(Font.system(.body, design: .monospaced))
      Button(action: {
        Task {
          await addChannels()
        }
      }) {
        Text("Add channels")
      }.keyboardShortcut(.return, modifiers: [.command])
    }
    .opacity(isAdding ? 0.3 : 1)
    .overlay(alignment: .center) {
      if isAdding {
        ProgressView()
      } else {
        EmptyView()
      }
    }
    .padding()
    .frame(minWidth: 400, minHeight: 400)
    .onExitCommand {
      dismiss()
    }
  }
}

extension Array {
  subscript(safe index: Int) -> Element? {
    guard index < endIndex, index >= startIndex else { return nil}
    return self[index]
  }
}

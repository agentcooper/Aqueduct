//
//  AqueductTests.swift
//  AqueductTests
//
//  Created by Artem Tyurin on 14/06/2022.
//

import XCTest
@testable import Aqueduct

import SwiftSoup

let testChannel = Channel(id: "test", title: "test", tags: [])

class AqueductTests: XCTestCase {
  func getTestHTML(fileName: String) throws -> String {
    let testBundle = Bundle(for: type(of: self))
    let url = testBundle.url(forResource: fileName, withExtension: "html")!
    let html = try String(contentsOf: url)
    return html
  }
  
  func testParseResults() throws {
    let addView = AddView()
    
    let input = """
meduzalive
https://t.me/mediazzzona
https://t.me/redakciya_channel/9443
https://t.me/s/nplusone
https://t.me/s/anton_dolin/123
"""
    
    let sources = addView.parseSources(input: input)
    
    XCTAssertEqual(sources.map { $0.channelId }, [
      "meduzalive",
      "mediazzzona",
      "redakciya_channel",
      "nplusone",
      "anton_dolin"
    ])
  }
  
  func testExample() throws {
    let telegramAPI = TelegramAPI()
    let testHTML = try getTestHTML(fileName: "response")
    
    let posts = telegramAPI.parseHTML(testHTML, channel: testChannel)
    XCTAssertEqual(posts.count, 20)
  }
  
  func testVideoPost() throws {
    let telegramAPI = TelegramAPI()
    let testHTML = try getTestHTML(fileName: "video-post")
    
    let posts = telegramAPI.parseHTML(testHTML, channel: testChannel)
    
    XCTAssertEqual(
      posts.first?.preview,
      Preview(
        imageURL: URL(string: "https://cdn4.telegram-cdn.org/file/FirAuSJHMwGY2xYXWPMdPsx36OEJpiIsfK-6LnFoezsKDuk5qSKivqSd2f1rCD6F3ugLMfrTn8Nm6Hwm7G6GRXwKOKvekYfOhEabfoILhAngPwYL643hL3AS6iDhLAdU3LSDLls8Gn-1ED93k61UIEhzrVpCKzeoCNe7ZPhA6dU8g43cmYgOEYGiiNQ9NtHJWgWBb_UOpVNg2EsqHQ5PY5jJ0AKX81PflgS6PTM82EF3dQ3iEeQTNm8SBQX-wKCLHfi_svFKMcw9AehvWGxsd5JB8pYgBul031EthuULTbSwnDJ_aY1jyordKrh1EUkXu4H95-9jQOh2kZj-t4PzWA")!,
        href: URL(string: "https://t.me/sotaproject/41946")!
      )
    )
  }
  
  func testCut() throws {
    do {
      let cases = [
        (
          "<div>Hello<br>goodbye</div>",
          "<div>Hello</div>"
        ),
        (
          "<div>Hello<b>Batman</b><br>Nice</div>",
          "<div>Hello<b>Batman</b></div>"
        ),
        (
          "<div><b>Hello<br></b> darkness</div>",
          "<div><b>Hello</b></div>"
        )
      ]
      
      for testCase in cases {
        let (input, expected) = testCase
        
        let doc: Document = try SwiftSoup.parse(input)
        // now: <p><a href="http://example.com/" rel="nofollow">Link</a></p>
        
        guard let message = try doc.getElementsByTag("div").first() else {
          return
        }
        
        let main = copyUntilFirstLineBreak(message)
        
        let s = try main.outerHtml()
        let output = String(s.filter { !$0.isWhitespace })
        
        XCTAssertEqual(output, expected)
        
      }
    } catch Exception.Error(_, let message) {
      print(message)
    } catch {
      print("error")
    }
  }
}

func childNodesUntil(_ el: Element, after: Int) -> Element {
  let copy = el.copy() as! Element
  
  for childNode in copy.getChildNodes() {
    if childNode.siblingIndex >= after {
      try? childNode.remove()
    }
  }
  
  return copy
}

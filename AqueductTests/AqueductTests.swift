//
//  AqueductTests.swift
//  AqueductTests
//
//  Created by Artem Tyurin on 14/06/2022.
//

import XCTest
@testable import Aqueduct

let testChannel = Channel(id: "test", title: "test", tags: [])

class AqueductTests: XCTestCase {
  func getTestHTML(fileName: String) throws -> String {
    let testBundle = Bundle(for: type(of: self))
    let url = testBundle.url(forResource: fileName, withExtension: "html")!
    let html = try String(contentsOf: url)
    return html
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
}

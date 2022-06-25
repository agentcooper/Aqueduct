//
//  Channel.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 25/06/2022.
//

import Foundation

struct Channel: Identifiable, Hashable, Codable, Equatable, Comparable {
  static func < (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.label.compare(rhs.label, options: .caseInsensitive) == .orderedAscending
  }
  
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

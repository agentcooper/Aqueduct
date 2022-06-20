//
//  Filter.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 03/06/2022.
//

import Foundation

let foreignAgentText = """
ДАННОЕ СООБЩЕНИЕ (МАТЕРИАЛ) СОЗДАНО И (ИЛИ)
"""
  .trimmingCharacters(in: .whitespacesAndNewlines)
  .replacingOccurrences(of: "(", with: "\\(")
  .replacingOccurrences(of: ")", with: "\\)")
  .components(separatedBy: .whitespaces)
  .joined(separator: "\\s+")

func applyFilters(html: String) -> String {
//  print(html, foreignAgentText)
//  let filteredHTML = html.replacingOccurrences(of: foreignAgentText, with: "🕵️‍♀️", options: .regularExpression)
  return html
}

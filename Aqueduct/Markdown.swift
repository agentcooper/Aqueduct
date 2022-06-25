//
//  Markdown.swift
//  Aqueduct
//
//  Created by Artem Tyurin on 20/06/2022.
//

import Foundation

func markdownLink(_ text: String, _ url: String) -> String {
  return "[\(text)](\(url))"
}

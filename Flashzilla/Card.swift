//
//  Card.swift
//  Flashzilla
//
//  Created by Maks Winters on 28.02.2024.
//

import Foundation

struct Card: Hashable, Codable, Identifiable {
    var id = UUID()
    let prompt: String
    let answer: String
    
    static let example = Card(prompt: "In which year was SwiftUI released?", answer: "2019")
}

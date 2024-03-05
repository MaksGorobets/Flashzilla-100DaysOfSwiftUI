//
//  CardsManager.swift
//  Flashzilla
//
//  Created by Maks Winters on 06.03.2024.
//

import Foundation

@Observable
class CardsManager {
    static let shared = CardsManager()
    
    var cards = [Card]()
    let url = URL.documentsDirectory.appending(path: "cards.json")
    
    func saveData() {
        do {
            let encoded = try JSONEncoder().encode(cards)
            try encoded.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadData() {
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Card].self, from: data)
            cards = decoded
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeCard(card: Card) {
        cards.removeAll { arrayCard in
            arrayCard == card
        }
    }
    
    func readdCard(card: Card) {
        removeCard(card: card)
        var newCard = card
        newCard.id = UUID()
        cards.insert(newCard, at: 0)
    }
    
    init() {
        loadData()
    }
}

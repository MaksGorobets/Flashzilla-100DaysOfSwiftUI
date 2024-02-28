//
//  EditCards.swift
//  Flashzilla
//
//  Created by Maks Winters on 28.02.2024.
//

import SwiftUI

struct EditCards: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var cards = [Card]()
    @State private var prompt = ""
    @State private var answer = ""
    
    
    var body: some View {
        NavigationStack {
            List {
                Section("Add new card") {
                    TextField("Enter a prompt", text: $prompt)
                    TextField("Enter the answer", text: $answer)
                    Button("Add", action: addCard)
                }
                
                Section("Saved cards") {
                    ForEach(cards, id: \.self) { card in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(card.prompt)
                                    .font(.headline)
                                Text(card.answer)
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                    }
                    .onDelete(perform: removeCards)
                }
            }
            .navigationTitle("Edit cards")
            .toolbar {
                Button("Done", action: done)
            }
            .onAppear(perform: loadData)
        }
    }
    
    func done() {
        dismiss()
    }
    
    func addCard() {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespaces)
        guard !trimmedPrompt.isEmpty && !trimmedAnswer.isEmpty else { return }
        let finalCard = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
        cards.insert(finalCard, at: 0)
        saveData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }
    
    func saveData() {
        if let encoded = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.setValue(encoded, forKey: "Cards")
        }
    }
    
    func removeCards(at offSets: IndexSet) {
        cards.remove(atOffsets: offSets)
        saveData()
    }
    
}

#Preview {
    EditCards()
}

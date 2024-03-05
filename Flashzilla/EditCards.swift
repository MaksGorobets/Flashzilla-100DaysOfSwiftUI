//
//  EditCards.swift
//  Flashzilla
//
//  Created by Maks Winters on 28.02.2024.
//

import SwiftUI

struct EditCards: View {
    @Environment(\.dismiss) var dismiss
    
    let cardsManager = CardsManager()
    
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
                    ForEach(cardsManager.cards, id: \.self) { card in
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
            .onAppear(perform: cardsManager.loadData)
        }
    }
    
    func done() {
        dismiss()
    }
    
    func clearTxt() {
        prompt = ""
        answer = ""
    }
    
    func addCard() {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespaces)
        guard !trimmedPrompt.isEmpty && !trimmedAnswer.isEmpty else { return }
        let finalCard = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
        cardsManager.cards.insert(finalCard, at: 0)
        cardsManager.saveData()
        clearTxt()
    }
    
    func removeCards(at offSets: IndexSet) {
        cardsManager.cards.remove(atOffsets: offSets)
        cardsManager.saveData()
    }
    
}

#Preview {
    EditCards()
}

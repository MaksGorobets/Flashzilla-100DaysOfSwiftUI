//
//  ContentView.swift
//  Flashzilla
//
//  Created by Maks Winters on 25.02.2024.
//
// https://stackoverflow.com/questions/57244713/get-index-in-foreach-in-swiftui
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    
    @State private var timeRemaining = 100
    @State private var isActive = true
    @State private var isShowingEditingScreen = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let cardsManager = CardsManager.shared
    
    var body: some View {
        ZStack {
            Image(decorative: getBackground())
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            VStack {
                Text(timeRemaining.formatted())
                    .padding()
                    .font(
                        .system(size: 34)
                        .weight(.heavy)
                        
                    )
                    .foregroundStyle(
                        timeRemaining > 70 ? .green
                        : timeRemaining > 50 ? .yellow
                        : .red
                    )
                    .contentTransition(.numericText())
                    .background(
                        Capsule()
                            .frame(width: 100, height: 50)
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                    )
                    .accessibilityLabel("Timer")
                    .accessibilityHint(timeRemaining.formatted())
                ZStack {
                    ForEach(Array(cardsManager.cards.enumerated()), id: \.element.id) { index, card in
                        CardView(card: card) { isRight in
                            if isRight {
                                withAnimation {
                                    cardsManager.removeCard(card: card)
                                }
                            } else {
                                withAnimation {
                                    cardsManager.readdCard(card: card)
                                }
                            }
                        }
                        .stacked(at: index, in: cardsManager.cards.count)
                        .allowsHitTesting(index == cardsManager.cards.count - 1)
                        .accessibilityHidden(index < cardsManager.cards.count - 1)
                    }
                    if cardsManager.cards.isEmpty {
                        VStack {
                            Text("NO CARDS LEFT")
                                .bold()
                            Button("Start again", action: resetCards)
                                .buttonStyle(.bordered)
                                .clipShape(.capsule)
                                .padding()
                        }
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
            }
            .onReceive(timer) { time in
                updateTimer()
            }
            .onChange(of: scenePhase) {
                switch scenePhase {
                case .active:
                    isActive = true
                case .inactive:
                    isActive = false
                default:
                    isActive = false
                }
            }
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isShowingEditingScreen.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(.circle)
                    }
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .font(.largeTitle)
            .padding()
            .sheet(isPresented: $isShowingEditingScreen, onDismiss: resetCards, content: EditCards.init)
            .onAppear(perform: resetCards)
            if accessibilityVoiceOverEnabled {
                HStack {
                    Button {
                        guard !cardsManager.cards.isEmpty else { return }
                        cardsManager.readdCard(card: cardsManager.cards.last!)
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .accessibilityLabel("Mark wrong")
                    Spacer()
                    Button {
                        guard !cardsManager.cards.isEmpty else { return }
                        cardsManager.removeCard(card: cardsManager.cards.last!)
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                    .accessibilityLabel("Mark right")
                }
                .font(.system(size: 70))
            }
        }
    }
    
    func resetCards() {
        withAnimation {
            timeRemaining = 100
            cardsManager.loadData()
        }
        isActive = true
    }
    
    func updateTimer() {
        guard isActive else { return }
        guard !cardsManager.cards.isEmpty else { return }
        withAnimation {
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
    
    func getBackground() -> String {
        colorScheme == .dark ? "Drowning Duck Dark" : "Drowning Duck"
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

#Preview {
    ContentView()
}

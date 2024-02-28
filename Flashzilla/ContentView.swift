//
//  ContentView.swift
//  Flashzilla
//
//  Created by Maks Winters on 25.02.2024.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    @Environment(\.colorScheme) var colorScheme
    @State private var cards = [Card]()
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
    @State private var isShowingEditingScreen = false
    
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
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index]) {
                            withAnimation {
                                removeCard(at: index)
                            }
                        }
                        .stacked(at: index, in: cards.count)
                        .allowsHitTesting(index == cards.count - 1)
                        .accessibilityHidden(index < cards.count - 1)
                    }
                    if cards.isEmpty {
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
                        removeCard(at: cards.count - 1)
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .accessibilityLabel("Mark wrong")
                    Spacer()
                    Button {
                        removeCard(at: cards.count - 1)
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
            loadData()
        }
        isActive = true
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }
    
    func updateTimer() {
        guard isActive else { return }
        guard !cards.isEmpty else { return }
        withAnimation {
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
    
    func removeCard(at index: Int) {
        print(index)
        guard index >= 0 else { return }
        cards.remove(at: index)
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

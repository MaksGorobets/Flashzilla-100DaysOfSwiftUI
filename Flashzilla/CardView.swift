//
//  CardView.swift
//  Flashzilla
//
//  Created by Maks Winters on 28.02.2024.
//

import SwiftUI

struct CardView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    
    let card: Card
    @State private var isShowingAnswer = false
    @State private var rotation = 0.0
    @State private var isDragging = false
    @State private var currentDrag = CGSize.zero
    
    var removal: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            if isDragging && !accessibilityVoiceOverEnabled {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                }
                .font(.system(size: 25 * abs(currentDrag.width / 100)))
                .padding()
            }
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        .white
                            .opacity(4 - Double(abs(currentDrag.width / 50)))
                    )
                    .shadow(radius: 10)
                    .opacity(2 - Double(abs(currentDrag.width / 100)))
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                accessibilityDifferentiateWithoutColor
                                ? .white
                                : currentDrag.width == 0 ? .blue : currentDrag.width > 0 ? .green : .red
                            )
                    )
                if isShowingAnswer {
                    Text(card.answer)
                        .font(.title)
                        .foregroundStyle(.gray)
                } else {
                    Text(card.prompt)
                        .font(.title)
                        .foregroundStyle(.black)
                }
            }
            .frame(width: 450, height: 250)
            .offset(x: currentDrag.width)
            .scaleEffect(isDragging ? 0.8 : 1)
            .opacity(5 - Double(abs(currentDrag.width / 50)))
            .rotationEffect(Angle(degrees: currentDrag.width) / 50)
            .animation(.default, value: isDragging)
            .onTapGesture {
                withAnimation {
                    isShowingAnswer.toggle()
                    rotation = 180
                }
                rotation = 0
            }
            .rotation3DEffect(
                Angle(degrees: rotation), axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .gesture(
                DragGesture()
                    .onChanged { drag in
                        isDragging = true
                        currentDrag = drag.translation
                    }
                    .onEnded { drag in
                        isDragging = false
                        if abs(currentDrag.width) > 200 {
                            removal?()
                        } else {
                            withAnimation {
                                currentDrag = .zero
                            }
                        }
                    }
            )
            .accessibilityAddTraits(.isButton)
        }
    }
}

#Preview {
    CardView(card: .example)
}

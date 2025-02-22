//
//  TextWriter.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 19/02/25.
//

import SwiftUI

// view that writes the text with pink blur background
struct TextWriter: View {
    let text: String
    let writingDuration: Double
    let onCompletion: () -> Void

    @State private var displayedText = ""
    
    var body: some View {
        Text(displayedText)
            .padding()
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(.white)
            .glassy()
            .padding()
            .onAppear {
                withAnimation(.easeInOut(duration: writingDuration).repeatForever(autoreverses: false)) {
                    typeText()
                }
            }
    }
        
    // adds a letter at a time
    private func typeText() {
        displayedText = ""
        let letterCount = text.count
        for (index, letter) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * writingDuration) {
                displayedText.append(letter)
                if index == letterCount - 1 {
                    onCompletion()
                }
            }
        }
    }
}


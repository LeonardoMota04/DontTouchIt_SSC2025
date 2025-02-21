//
//  AlertCardView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 19/02/25.
//


import SwiftUI
 
struct AlertCardView: View {
    let phase: AlertsCardsPhases
    let onTap: () -> Void

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let cardWidth = width / 4
            
            ZStack {
                VStack {
                    Text(phase.title)
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    phase.image
                        .resizable()
                        .scaledToFit()
                    
                    Spacer()

                    Text(phase.description)
                        .foregroundStyle(.white)
                        .font(.headline)
                        .padding(.bottom)
                }
                .padding()
                
            }
            .frame(width: cardWidth, height: height / 1.5)
            .glassy()
            .scaleEffect(0.8)
            .position(
                x: phase == .onlyOneHead || phase == .enoughLight ? cardWidth / 1.8 : width - cardWidth / 1.8,
                 y: height / 2
             )
            .padding(.horizontal, phase == .onlyOneHead || phase == .enoughLight ? 100 : -100)
            .rotation3DEffect(
                .degrees(phase == .onlyOneHead || phase == .enoughLight ? 45 : -45),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottomTrailing) {
            // MARK: - BOTÃO
            CustomButton(icon: "arrow.right") {
                withAnimation { onTap() }
            }
            .padding(50)
            .ignoresSafeArea()
        }
    }
}



#Preview {
    struct AlertCardPreview: View {
        @State private var phase: AlertsCardsPhases = .onlyOneHead
        
        var body: some View {
            VStack {
                AlertCardView(phase: phase) {
                    withAnimation { // Aplica a animação na troca do estado
                        switch phase {
                        case .onlyOneHead:
                            phase = .distanceToTheScreen
                        case .distanceToTheScreen:
                            phase = .enoughLight
                        case .enoughLight:
                            phase = .handsVisible
                        case .handsVisible:
                            phase = .onlyOneHead
                        }
                    }
                }
                
            }
        }
    }
    
    return AlertCardPreview()
}

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
            
            VStack {
                phase.image
                    .resizable()
                    .scaledToFit()
                    .padding([.top, .horizontal])
                    .frame(maxHeight: .infinity)
                                
                VStack (alignment: .leading, spacing: 10) {
                    Text(phase.title)
                        .frame(maxHeight: .infinity)
                        .foregroundStyle(.white)
                        .font(.system(size: 45))
                        .fontWeight(.semibold)
                    
                    Text(phase.description)
                        .foregroundStyle(.white)
                        .font(.footnote)
                        .padding(.bottom)
                }
                .padding(15)
            }
            .frame(width: cardWidth, height: height / 1.6)
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
            // MARK: - BUTTON
            CustomButton(icon: "arrow.right") {
                withAnimation { onTap() }
            }
            .padding(50)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    AlertCardView(phase: .handsVisible) {
        
    }
}

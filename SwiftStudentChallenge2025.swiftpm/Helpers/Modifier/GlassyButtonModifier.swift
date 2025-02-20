//
//  GlassyButtonModifier.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 19/02/25.
//

import SwiftUI

struct CustomButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 80
    var iconColor: Color = .white.opacity(0.7)
    var backgroundColor: Color = .clear
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                        .font(.largeTitle)
                        .shadow(radius: 5)
                }
                .glassy() // Aplica o efeito "glassy"
        }
        .buttonStyle(PlainButtonStyle()) // Remove o estilo padrão do botão
    }
}

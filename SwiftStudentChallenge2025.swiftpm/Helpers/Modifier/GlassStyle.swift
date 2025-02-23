//
//  GlassStyle.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 19/02/25.
//

import SwiftUI

// glass style background with pink theme
struct GlassStyle<S: Shape>: ViewModifier {
    
    private let shape: S
    private let gradientColors = [
        Color(hex: "BD80D4"),
        Color(hex: "62436E"),
        Color(hex: "A973BE")
    ]
    
    init(shape: S = Rectangle()) {
        self.shape = shape
    }
    
    func body(content: Content) -> some View {
        let baseColor = Color.accentColor
        let bgGradientColor: Gradient = Gradient(colors: [baseColor.opacity(0.15), Color.clear])
        
        content
            .foregroundStyle(.clear)
            .background {
                ZStack {
                    BlurView(style: .systemUltraThinMaterialDark)
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "BD80D4").opacity(0.05), location: 0.12),
                            .init(color: Color(hex: "62436E").opacity(0.05), location: 0.38),
                            .init(color: Color(hex: "A973BE").opacity(0.05), location: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    RadialGradient(
                        gradient: bgGradientColor,
                        center: UnitPoint(x: 0.3, y: 0.24),
                        startRadius: 0,
                        endRadius: 400
                    )
                    
                    RadialGradient(
                        gradient: bgGradientColor,
                        center: UnitPoint(x: 0.7, y: 0.4),
                        startRadius: 5,
                        endRadius: 70
                    )
                    
                    RadialGradient(
                        gradient: bgGradientColor,
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                    .blendMode(.screen)
                    
                    RadialGradient(
                        gradient: bgGradientColor,
                        center: .bottom,
                        startRadius: 10,
                        endRadius: 300
                    )

                }
            }
            .clipShape(shape)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 8)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 3)
            .overlay {
                shape
                    .stroke(LinearGradient(colors: gradientColors,
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing), lineWidth: 4)
                RadialGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.15), .clear]),
                    center: .center,
                    startRadius: 20,
                    endRadius: 100
                )
                .offset(x: -3, y: 45)
                .blur(radius: 20)
            }
    }
}

//
//  GlassyButtonModifier.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 19/02/25.
//

import SwiftUI

struct CustomButton: View {
    @EnvironmentObject private var cameraVM: CameraViewModel

    let icon: String
    let action: () -> Void
    var size: CGFloat
    var iconColor: Color = .white.opacity(0.7)
    var backgroundColor: Color = .clear

    init(icon: String, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        self.size = isPad ? 80 : 50
    }

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                        .font(.system(size: size * 0.4))
                        .shadow(radius: 5)
                }
                .glassy()
        }
        .buttonStyle(PlainButtonStyle())
    }
}



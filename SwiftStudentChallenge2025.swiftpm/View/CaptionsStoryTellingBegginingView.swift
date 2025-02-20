//
//  CaptionsStoryTellingBegginingView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 19/02/25.
//

import SwiftUI

struct CaptionsStoryTellingBegginingView: View {
    let phase: StoryTellingBegginigPhases
    let onFinish: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            TextWriter(text: phase.text, writingDuration: 0.05) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 3)) {
                        onFinish()
                    }
                }
            }
            .position(x: geo.size.width / 2, y: geo.size.height - 50)
            .offset(y: phase.hasOffset ? -geo.size.height + 100 : 0)
        }
    }
}

#Preview {
    CaptionsStoryTellingBegginingView(phase: .first) {}
}

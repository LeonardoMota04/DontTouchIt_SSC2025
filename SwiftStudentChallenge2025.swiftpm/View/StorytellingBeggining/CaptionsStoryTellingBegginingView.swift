//
//  CaptionsStoryTellingBegginingView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 19/02/25.
//

import SwiftUI

struct CaptionsStoryTellingBegginingView: View {
    @EnvironmentObject private var cameraVM: CameraViewModel

    let phase: StoryTellingBegginigPhases
    let onFinish: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            TextWriter(text: phase.text, writingDuration: 0.06) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 3)) {
                        if cameraVM.currentAppState != .home {
                            onFinish()
                        }
                    }
                }
            }
            .position(x: geo.size.width / 2, y: geo.size.height - 50)
            .offset(y: phase.hasOffset ? -geo.size.height + 100 : 0)
        }
    }
}

//#Preview {
//    
//    @Previewable @State var phase: StoryTellingBegginigPhases = .third
//    
//    
//    CaptionsStoryTellingBegginingView(phase: phase) {
//        switch phase {
//        case .first:
//            phase =  .second
//        case .second:
//            
//            phase = .third
//
//        case .third:
//            phase = .fourth
//
//        case .fourth:
//            phase = .fifth
//
//        case .fifth:
//            phase = .sixth
//
//        case .sixth:
//            phase = .first
//        }
//    }
//    .id(phase)
//}

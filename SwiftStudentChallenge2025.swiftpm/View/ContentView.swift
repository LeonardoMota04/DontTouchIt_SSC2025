//
//  ContentView 2.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 23/01/25.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @EnvironmentObject private var cameraVM: CameraViewModel
    
    /// overlay views
    @State private var showPreview: Bool = false
    @State private var showInfoView: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            CubeView(viewController: cameraVM.viewController).ignoresSafeArea()
            
            switch cameraVM.currentAppState {
            case .home:
                HomeView()
            
            // LEGENDAS
            case .storyTellingBegginig(let phase):
                CaptionsStoryTellingBegginingView(phase: phase) {
                    switch phase {
                    case .first:
                        cameraVM.currentAppState = .storyTellingBegginig(.second)
                        
                    case .second:
                        
                        cameraVM.currentAppState = .storyTellingBegginig(.third)

                    case .third:
                        cameraVM.currentAppState = .storyTellingBegginig(.fourth)

                    case .fourth:
                        cameraVM.currentAppState = .storyTellingBegginig(.fifth)

                    case .fifth:
                        cameraVM.currentAppState = .storyTellingBegginig(.sixth)

                    case .sixth:
                        cameraVM.currentAppState = .alertsCards(.onlyOneHead)
                    }
                }
                .id(phase)
                
            // CARDS ALERTA
            case .alertsCards(let phase):
                AlertCardView(phase: phase) {
                    switch phase {
                    case .onlyOneHead:
                        cameraVM.currentAppState = .alertsCards(.distanceToTheScreen)

                    case .distanceToTheScreen:
                        cameraVM.currentAppState = .alertsCards(.enoughLight)

                    case .enoughLight:
                        cameraVM.currentAppState = .alertsCards(.handsVisible)

                    case .handsVisible:
                        cameraVM.currentAppState = .sceneTutorial(.intro)
                    }
                }
                
            case .sceneTutorial(let phase):
                SceneTutorialView(
                    phase: phase,
                    onTap: {
                        switch phase {
                        case .intro:
                            cameraVM.currentAppState = .sceneTutorial(.headCameraTracking)
                        case .headCameraTracking:
                            cameraVM.currentAppState = .sceneTutorial(.handActionCameraRotation)
                        case .handActionCameraRotation:
                            cameraVM.currentAppState = .sceneTutorial(.handActionCubeRightSideRotation)
                        case .handActionCubeRightSideRotation:
                            cameraVM.currentAppState = .home
                        }
                    },
                    onTapPhase: { newPhase in
                        cameraVM.currentAppState = .sceneTutorial(newPhase)
                    }
                )

            case .freeMode:
                FreeModeView()
            }
            
            if showPreview {
                CameraViewRepresentable(captureSession: cameraVM.getCaptureSession())
                    .allowsHitTesting(false)
            }
            
            HUDView(onHomeTap: {
                cameraVM.currentAppState = .home
            }, onCameraTap: {
                withAnimation(.smooth) { showPreview.toggle() }
            }, onInfoTap: {
                withAnimation(.smooth) { showInfoView.toggle() }
            })

            if showInfoView {
                CardInfoView(showInfoView: $showInfoView)
            }
        }
        .onDisappear { cameraVM.stopCameraSession() }

    }
}

#Preview {
    ContentView()
        .environmentObject(CameraViewModel())
}

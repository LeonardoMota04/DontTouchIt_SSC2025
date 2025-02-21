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
    @State private var showPreview: Bool = false
    
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
            })

        
        }
        .onDisappear { cameraVM.stopCameraSession() }

    }
}

import SwiftUI

struct FreeModeView: View {
    @State private var phase = SceneTutorialPhases.handActionCubeRightSideRotation

    var body: some View {
        SceneTutorialView(phase: phase, isFreeMode: true, onTap: {
            
        }, onTapPhase: { new in
            phase = new
        })
    }
}

import SwiftUI

struct HUDView: View {
    @EnvironmentObject private var cameraVM: CameraViewModel

    var onHomeTap: () -> Void
    var onCameraTap: () -> Void
    
    var body: some View {
        VStack {
            if cameraVM.currentAppState != .home {
                CustomButton(icon: "house.fill") {
                    onHomeTap()
                }
            }
                        
            CustomButton(icon: "eye.fill") {
                onCameraTap()
            }
            .padding(.top, 8)
        
        }
        .animation(.easeInOut, value: cameraVM.currentAppState)
        .padding(50)
        .ignoresSafeArea()
    }
}


#Preview {
    @Previewable @StateObject var cameraVM: CameraViewModel = .init()
    ContentView()
        .environmentObject(cameraVM)
}


enum AppState: Hashable {
    case home
    case storyTellingBegginig(StoryTellingBegginigPhases)
    case alertsCards(AlertsCardsPhases)
    case sceneTutorial(SceneTutorialPhases)
    case freeMode
}

struct Home {
    var title: String { return "DO NOT TOUCH IT" }
    var image: Image { return Image("tiltYourHead") } // Forma antiga de carregar imagens
    var description: String { return "LEFT to full experience and RIGHT to free mode" }
}

enum StoryTellingBegginigPhases {
    case first
    case second
    case third
    case fourth
    case fifth
    case sixth
    
    var text: String {
        switch self {
        case .first:
            return "O mundo está mudando... Cada vez mais próximo, mais conectado..."
        case .second:
            return "Tudo é muito rápido. A tecnologia avança. A sociedade evolui."
        case .third:
            return "Mas, às vezes, no meio de tanta correria... estamos longe do que é real."
        case .fourth:
            return "E se não precisássemos dessa distância?"
        case .fifth:
            return "Não precisamos. Já vivemos na era dos gestos, do toque mínimo, da presença máxima."
        case .sixth:
            return "E se pudéssemos unir o real e o virtual?"
        }
    }
    
    var hasOffset: Bool {
        switch self {
        case .first, .second, .third:
            return false
        default:
            return true
        }
    }
}

enum AlertsCardsPhases {
    case onlyOneHead
    case distanceToTheScreen
    case enoughLight
    case handsVisible
    
    var title: String {
        switch self {
        case .onlyOneHead:
            return "One head at a time"
        case .distanceToTheScreen:
            return "Nice distance"
        case .enoughLight:
            return "Lights good"
        case .handsVisible:
            return "Hands ok tbm"
        }
    }
    
    var image: Image {
        switch self {
        case .onlyOneHead:
            return Image("twoHead")
        case .distanceToTheScreen:
            return Image("twoHead")
        case .enoughLight:
            return Image("twoHead")
        case .handsVisible:
            return Image("twoHead")
        }
    }
    
    var description: String {
        return "Aqui mostre apenas uma cabeça, aqui mostre apenas uma cabeça..."
    }
}

enum SceneTutorialPhases: CaseIterable {
    case intro
    case headCameraTracking
    case handActionCameraRotation
    case handActionCubeRightSideRotation
    
    var title: String {
        switch self {
        case .intro:
            return "You're all set."
        case .headCameraTracking:
            return "Camera - Head tracking"
        case .handActionCameraRotation:
            return "Camera - Hand rotation"
        case .handActionCubeRightSideRotation:
            return "Cube - Hand action"
        }
    }
    
    var image: Image? {
        switch self {
        case .intro:
            return nil
        case .headCameraTracking:
            return Image("sceneTutorialHead")
        case .handActionCameraRotation:
            return Image("sceneTutorialHandCameraRotation")
        case .handActionCubeRightSideRotation:
            return Image("sceneTutorialHandCubeSideRotation")
        }
    }
    
    var description: String {
        switch self {
        case .intro:
            return "Let's get started. We are in the touchless era."
        case .headCameraTracking:
            return "You can track your head movement to rotate the camera"
        case .handActionCameraRotation:
            return "You can rotate your hand like this to rotate the camera"
        case .handActionCubeRightSideRotation:
            return "You can do this movement to rotate the right side of the cube"
        }
    }
}

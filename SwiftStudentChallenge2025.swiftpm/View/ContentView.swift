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
   
    var body: some View {
        ZStack {
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
                            cameraVM.currentAppState = .sceneTutorial(.intro)
                        }
                    },
                    onTapPhase: { newPhase in
                        cameraVM.currentAppState = .sceneTutorial(newPhase)
                    }
                )
            }
            
            CameraViewRepresentable(captureSession: cameraVM.getCaptureSession())
                .allowsHitTesting(false)
            //HUDView()
        }
        .onDisappear { cameraVM.stopCameraSession() }
    }
}


struct SceneTutorialView: View {
    let phase: SceneTutorialPhases
    var onTap: () -> Void
    var onTapPhase: (SceneTutorialPhases) -> Void

    @State private var isInteractingWithTheCube: Bool = false
    @State private var previousPhases: [SceneTutorialPhases] = []
    @State private var isButtonDisabled: Bool = false

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width

            ZStack(alignment: .topLeading) {
                // 🔹 Renderiza os outros cards e os torna clicáveis
                HStack(spacing: 0) {
                    ForEach(SceneTutorialPhases.allCases.filter { ($0 != phase && $0 != .intro) }, id: \.self) { phaseItem in
                        CardView(phase: phaseItem, geo: geo, isInteracting: true, isMainCard: false)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                            .onTapGesture {
                                withAnimation(.smooth) {
                                    isInteractingWithTheCube = false
                                    print("tapei no \(phaseItem)")
                                    onTapPhase(phaseItem)
                                }
                            }
                            .opacity(!isInteractingWithTheCube ? 0 : 1.0)
                    }
                }
                .padding(.leading, isInteractingWithTheCube ? (width / 8 + 50) : 0)

                // 🔹 Renderiza o card principal
                CardView(phase: phase, geo: geo, isInteracting: isInteractingWithTheCube, isMainCard: true)
                    .onTapGesture {
                        if previousPhases.contains(phase) {
                            withAnimation(.smooth) {
                                isInteractingWithTheCube.toggle()
                            }
                        }
                    }
            }
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottomTrailing) {
            // MARK: - BOTÃO
            CustomButton(icon: "arrow.right") {
                guard !isButtonDisabled else { return }

                if phase == .intro {
                    withAnimation(.bouncy) { onTap() }
                    return
                }

                if isInteractingWithTheCube {
                    withAnimation(.smooth) {
                        isInteractingWithTheCube = false
                        isButtonDisabled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            onTap()
                            isButtonDisabled = false
                        }
                    }
                } else {
                    withAnimation(.smooth) {
                        if previousPhases.contains(phase) {
                            onTap()
                        } else {
                            previousPhases.append(phase)
                            isInteractingWithTheCube = true
                        }
                    }
                }
            }
            .disabled(isButtonDisabled)
            .padding(40)
        }
    }
}


// 🔹 Componente para os cards, simplificando o código principal
struct CardView: View {
    let phase: SceneTutorialPhases
    let geo: GeometryProxy
    let isInteracting: Bool
    let isMainCard: Bool
    
    var body: some View {
        let cardWidth = isInteracting ? geo.size.width / 8 : geo.size.width / 1.5
        let cardHeight = isInteracting ? geo.size.height / 8 : geo.size.height / 2

        return ZStack {
            RoundedRectangle(cornerRadius: 16)
            
            if phase == .intro {
                VStack {
                    Text(phase.title)
                        .foregroundStyle(.white)
                        .font(.system(size: 50))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(phase.description)
                        .foregroundStyle(.white)
                        .font(.body)
                }
                .padding(40)
            } else {
                VStack(alignment: .leading) {
                    if !isInteracting {
                        Text(phase.title)
                            .foregroundStyle(.white)
                            .font(.system(size: 50))
                            .fontWeight(.bold)
                            .padding(.leading, 50)
                    }
                    
                    HStack {
                        if let image = phase.image {
                            Image(image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: isInteracting ? 87.5 : 350)
                        }
                        
                        if !isInteracting {
                            Spacer()
                            
                            Text(phase.description)
                                .foregroundStyle(.white)
                                .font(.body)
                                .fontWeight(.medium)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .glassy()
        .padding([.leading, .top], (isMainCard && !isInteracting) ? 0 : 50)
        .frame(maxWidth: (isMainCard  && !isInteracting) ? .infinity : nil,
               maxHeight: (isMainCard  && !isInteracting) ? .infinity : nil, alignment: .center)
    }
}





#Preview {
    struct scenetutorialviewPreview: View {
        @State private var phase: SceneTutorialPhases = .intro

        var body: some View {
            SceneTutorialView(phase: phase) {
                switch phase {
                case .intro:
                    phase = .headCameraTracking
                case .headCameraTracking:
                    phase = .handActionCameraRotation
                case .handActionCameraRotation:
                    phase = .handActionCubeRightSideRotation
                case .handActionCubeRightSideRotation:
                    phase = .intro
                }
            } onTapPhase: { newPhase in
                phase = newPhase
            }
        }
    }
    return scenetutorialviewPreview()
}
struct HUDView: View {
    var body: some View {
        ZStack {
            //            Image(.twoHead)
            //                .rotation3DEffect(
            //                    .degrees(45),
            //                    axis: (x: 0, y: 1, z: 0) // Inclinação no eixo X
            //                )
            //                .scaleEffect(1.1)
            
            //            Text("Texto bem do legal aqui")
            //                .font(.caption)
            //                .bold()
            //                .padding()
            //                .background(.ultraThinMaterial)
            //                .foregroundColor(.white)
            //                .cornerRadius(10)
            //                .opacity(1)
            //                .animation(.easeInOut, value: true)
            //                .shadow(radius: 10)
        }
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
}



enum Home {
    var title: String { return "DO NOT TOUCH IT" }
    var image: Image { return Image(.tiltYourHead) }
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
    
    var image: ImageResource {
        switch self {
        case .onlyOneHead:
            return ImageResource.twoHead
            
        case .distanceToTheScreen:
            return ImageResource.twoHead

        case .enoughLight:
            return ImageResource.twoHead

        case .handsVisible:
            return ImageResource.twoHead

        }
    }
    
    var description: String {
        switch self {
        case .onlyOneHead:
            return "aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca"
            
        case .distanceToTheScreen:
            return "aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca"
            
        case .enoughLight:
            return "aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca"
            
        case .handsVisible:
            return "aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca, aqui mostre apenas uma cabeca"
        }
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
    
    var image: ImageResource? {
        switch self {
        case .intro:
            return nil
            
        case .headCameraTracking:
            return ImageResource.sceneTutorialHead
            
        case .handActionCameraRotation:
            return ImageResource.sceneTutorialHandCameraRotation

        case .handActionCubeRightSideRotation:
            return ImageResource.sceneTutorialHandCubeSideRotation
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

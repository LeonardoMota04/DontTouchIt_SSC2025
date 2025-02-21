//
//  SceneTutorialView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 20/02/25.
//

import SwiftUI

struct SceneTutorialView: View {
    @EnvironmentObject private var cameraVM: CameraViewModel

    // phase information
    let phase: SceneTutorialPhases
    var isFreeMode: Bool = false
    
    // taps closures
    var onTap: () -> Void
    var onTapPhase: (SceneTutorialPhases) -> Void
    
    private var hasCompletedAllSteps: Bool {
        return((previousPhases.count == SceneTutorialPhases.allCases.dropFirst().count) || isFreeMode)
    }
    
    // view state
    @State private var isInteractingWithTheCube: Bool = false {
        willSet {
            if newValue {
                guard phase != .intro, phase != .headCameraTracking else { return }
                self.isButtonVisible = false
                startTimer() 
            }
        }
    }
    @State private var previousPhases: [SceneTutorialPhases] = []
    @State private var isButtonDisabled: Bool = false
    @State private var isButtonVisible: Bool = true
    @State private var remainingTime: Int = 8 // Tempo do timer em segundos
    @State private var timer: Timer? // Referência do temporizador
    
    private func startTimer() {
        remainingTime = 8 // Define o tempo inicial do temporizador
        timer?.invalidate() // Para qualquer temporizador anterior, caso exista
        
        // Inicia o temporizador
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate() // Para o temporizador quando chegar a 0
                isButtonVisible = true // Torna o botão visível quando o tempo acabar
            }
        }
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            
            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    ForEach(SceneTutorialPhases.allCases.filter { ($0 != phase && $0 != .intro) }, id: \.self) { phaseItem in
                        CardView(phase: phaseItem, geo: geo, isInteracting: true, isMainCard: false)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                            .onTapGesture {
                                withAnimation(.bouncy) {
                                    isInteractingWithTheCube.toggle()
                                    
                                    if isInteractingWithTheCube {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation(.bouncy(duration: 0.5)) {
                                                isInteractingWithTheCube = false
                                            }
                                        }
                                    }
                                    
                                    onTapPhase(phaseItem)
                                }
                            }
                            .opacity(hasCompletedAllSteps ? 0.5 : 0)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.leading, isInteractingWithTheCube ? (width / 8 + 50) : 0)
                CardView(phase: phase, geo: geo, isInteracting: isInteractingWithTheCube, isMainCard: true)
                    .onTapGesture {
                        if (previousPhases.contains(phase) || isFreeMode) {
                            withAnimation(.bouncy) { onTap() }
                            return
                        }
                    }
                    .opacity((isFreeMode && isInteractingWithTheCube) ? 0.5 : 1)
            }
        }
        .onAppear { if isFreeMode { isInteractingWithTheCube = true } }
        .ignoresSafeArea()
        .overlay(alignment: .bottomLeading) {
            // MARK: - Circular Progress
            if !isButtonVisible && !isFreeMode {
                CircularProgressView(progress: CGFloat(remainingTime) / 8.0)
                    .frame(width: 50, height: 50)
                    .padding(50)
                    .ignoresSafeArea()
            }
        }
        .overlay(alignment: .bottomTrailing) {
            // MARK: - BOTÃO
            CustomButton(icon: "arrow.right") {
                if phase == .intro {
                    withAnimation(.bouncy) { onTap() }
                    return
                }

                if isInteractingWithTheCube {
                    if phase == .handActionCubeRightSideRotation {
                        withAnimation(.bouncy) { onTap() }
                        return
                    }
                    
                    withAnimation(.bouncy) {
                        isInteractingWithTheCube = false
                        isButtonDisabled = true
                    }
                    
                    // after 1 sec, step changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.bouncy) {
                            onTap()
                            isButtonDisabled = false
                        }
                    }
                } else {
                    withAnimation(.bouncy) {
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
            .padding(50)
            .opacity(isFreeMode ? 0 : isButtonVisible ? 1 : 0)
            .ignoresSafeArea()
        }
    }
}





#Preview {
    ContentView()
        .environmentObject(CameraViewModel())
}

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
                            image
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

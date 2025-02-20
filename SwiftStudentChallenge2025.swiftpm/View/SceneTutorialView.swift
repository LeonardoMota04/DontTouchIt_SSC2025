//
//  SceneTutorialView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 20/02/25.
//

import SwiftUI

struct SceneTutorialView: View {
    let phase: SceneTutorialPhases
    var onTap: () -> Void
    var onTapPhase: (SceneTutorialPhases) -> Void
    
    private var hasCompletedAllSteps: Bool {
        return previousPhases.count == SceneTutorialPhases.allCases.dropFirst().count
    }
    
    @State private var isInteractingWithTheCube: Bool = false
    @State private var previousPhases: [SceneTutorialPhases] = []
    @State private var isButtonDisabled: Bool = false


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
                        if previousPhases.contains(phase) {
                            withAnimation(.bouncy) {
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
            //.disabled(isButtonDisabled)
            .padding(40)
            //.opacity(hasCompletedAllSteps ? 0 : 1)
        }
       // .onChange(of: p)
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

//
//  SceneTutorialView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 20/02/25.
//

import SwiftUI

struct SceneTutorialView: View {
    
    // MARK: - VARIABLES
    @EnvironmentObject private var cameraVM: CameraViewModel

    let phase: SceneTutorialPhases
    var isFreeMode: Bool = false
    
    var onTap: () -> Void
    var onTapPhase: (SceneTutorialPhases) -> Void
    
    @State private var isInteractingWithTheCube: Bool = false {
        willSet {
            handleInteractionStateChange(newValue)
        }
    }
    @State private var previousPhases: [SceneTutorialPhases] = []
    @State private var isButtonDisabled: Bool = false
    @State private var isButtonVisible: Bool = true
    
    @StateObject private var timerManager = TimerManager()
    
    private var hasCompletedAllSteps: Bool {
        return (previousPhases.count == SceneTutorialPhases.allCases.dropFirst().count) || isFreeMode
    }
    
    // MARK: - VIEW
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            
            ZStack(alignment: .topLeading) {
                phaseBackgroundCards(geo: geo, width: width)
                mainPhaseCard(geo: geo)
            }
        }
        .onAppear { if isFreeMode { isInteractingWithTheCube = true } }
        .ignoresSafeArea()
        .overlay(alignment: .bottomTrailing) { circularProgressOverlay() }
        .overlay(alignment: .bottomTrailing) { actionButton() }
        .onChange(of: cameraVM.predictedAction) { _, _ in handlePredictedActionChange() }
    }
    
    // MARK: - SUBVIESW
    @ViewBuilder
    private func phaseBackgroundCards(geo: GeometryProxy, width: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(SceneTutorialPhases.allCases.filter { ($0 != phase && $0 != .intro) }, id: \ .self) { phaseItem in
                CardView(phase: phaseItem, geo: geo, isInteracting: true, isMainCard: false)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .onTapGesture { handlePhaseTap(phaseItem) }
                    .opacity(hasCompletedAllSteps ? 0.5 : 0)
                    .contentShape(Rectangle())
            }
        }
        .padding(.leading, isInteractingWithTheCube ? (width / 8 + 50) : 0)
    }
    
    @ViewBuilder
    private func mainPhaseCard(geo: GeometryProxy) -> some View {
        CardView(phase: phase, geo: geo, isInteracting: isInteractingWithTheCube, isMainCard: true)
            .onTapGesture { handleMainCardTap() }
            .opacity((isFreeMode && isInteractingWithTheCube) ? 0.5 : 1)
            .allowsHitTesting(true)
    }
    
    @ViewBuilder
    private func circularProgressOverlay() -> some View {
        if !isButtonVisible {
            CircularProgressView(progress: CGFloat(timerManager.remainingTime) / 8.0)
                .frame(width: 50, height: 50)
                .padding(50)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private func actionButton() -> some View {
        CustomButton(icon: "arrow.right") { handleButtonTap() }
            .disabled(isButtonDisabled)
            .padding(50)
            .opacity(isFreeMode ? 0 : (hasCompletedAllSteps ? 0 : (isButtonVisible ? 1 : 0)))
            .ignoresSafeArea()
    }
    
    
    // MARK: - FUNCTIONS
    
    private func handleInteractionStateChange(_ newValue: Bool) {
        guard newValue, phase != .intro, phase != .headCameraTracking, phase != .handActionCubeRightSideRotation, !isFreeMode else { return }
        
        if !timerManager.phasesWithTimerActivated.contains(phase) {
            isButtonVisible = false
            timerManager.startTimer { isButtonVisible = true }
            timerManager.phasesWithTimerActivated.insert(phase)
        }
    }
    
    /// PHASE TAP
    @MainActor
    private func handlePhaseTap(_ phaseItem: SceneTutorialPhases) {
        withAnimation(.bouncy) {
            isInteractingWithTheCube.toggle()
            
            if isInteractingWithTheCube {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.bouncy(duration: 0.5)) { isInteractingWithTheCube = false }
                }
            }
            onTapPhase(phaseItem)
        }
    }
    
    /// MAIN CARD TAP
    @MainActor
    private func handleMainCardTap() {
        if previousPhases.contains(phase) || isFreeMode {
            withAnimation(.bouncy) { isInteractingWithTheCube.toggle() }
        }
    }
    
    /// BOTTOM TRAILING BUTTON  TAP
    private func handleButtonTap() {
        if phase == .intro {
            withAnimation(.bouncy) { onTap() }
            return
        }
        
        if isInteractingWithTheCube {
            // LAST PHASE
            if phase == .handActionCubeRightSideRotation {
                withAnimation(.bouncy) { onTap() }
                return
            }
        
            withAnimation(.bouncy) {
                isInteractingWithTheCube = false
                isButtonDisabled = true
            }
            
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
    
    /// CHANGE OF COREML HAND ACTION
    private func handlePredictedActionChange() {
        guard phase != .headCameraTracking, phase != .intro, !isButtonVisible else { return }
        
        switch phase {
        case .handActionCameraRotation:
            isButtonVisible = cameraVM.predictedAction == .rotateCamera(.clockwise) ||
                              cameraVM.predictedAction == .rotateCamera(.counterclockwise)
        case .handActionCubeRightSideRotation:
            isButtonVisible = !(cameraVM.predictedAction == HandAction.none || cameraVM.predictedAction == .rotateCamera(.clockwise) || cameraVM.predictedAction == .rotateCamera(.counterclockwise))
        default:
            return
        }
    }
}


#Preview {
    struct scenetutorialviewPreview: View {
//        @State private var phase: AppState = .freeMode
        @State private var phase: SceneTutorialPhases = .intro

        var body: some View {
//            SceneTutorialView(phase: .handActionCubeRightSideRotation, isFreeMode: true) {
//                
//            } onTapPhase: { newPhase in
//                
//            }
            SceneTutorialView(phase: phase, isFreeMode: false) {
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
        .environmentObject(CameraViewModel())
}

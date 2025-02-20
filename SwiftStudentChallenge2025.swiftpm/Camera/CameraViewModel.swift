//
//  CameraViewModel.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 30/01/25.
//

import Combine
import AVFoundation
import UIKit

class CameraViewModel: ObservableObject {
    private let cameraManager = CameraManager()
    private let handPoseManager = HandPoseManager()
    private let faceManager = FaceManager()
    let viewController = CubeViewController()

    @Published var predictedAction: HandAction?
    @Published var headInclination: HeadInclination?
    @Published var distanceFromCenter: HeadDistanceFromCenter?
    @Published var currentAppState: AppState = .home

    private var stateAction: AppStateAction?

    init() {
        cameraManager.delegate = self
        cameraManager.startSession()

        handPoseManager.onPredictionUpdate = { [weak self] action in
            self?.predictedAction = action
            self?.viewController.handAction = action
            self?.stateAction?.handleHandAction(action)
        }

        faceManager.onFaceDataUpdate = { [weak self] inclination, distance in
            self?.headInclination = inclination
            self?.distanceFromCenter = distance
            self?.viewController.headDistanceFromCenter = distance
            self?.stateAction?.handleHeadDistance(distance)
        }
    }
    
    func stopCameraSession() {
        cameraManager.stopSession()
    }

    func getCaptureSession() -> AVCaptureSession {
        return cameraManager.captureSession
    }
}


extension CameraViewModel: CameraManagerDelegate {
    func cameraManager(_ manager: CameraManager, didCapture sampleBuffer: CMSampleBuffer) {
        handPoseManager.processHandPose(from: sampleBuffer)
        faceManager.processFace(from: sampleBuffer)
    }
}




protocol AppStateAction {
    func handleHeadDistance(_ distance: HeadDistanceFromCenter)
    func handleHandAction(_ action: HandAction)
    func getStateDescription() -> String
}

class HomeStateAction: AppStateAction {
    func handleHeadDistance(_ distance: HeadDistanceFromCenter) {
//        if distance.horizontal < 20 {
//            print("Home state: Head close to esqerda detected")
//        } else if distance.horizontal > 80 {
//            print("Home state: Head close to dureuata detected")
//        }
    }

    func handleHandAction(_ action: HandAction) {
        // Lógica para reações a ações das mãos no estado Home
//        switch action {
//        case .swipeLeft:
//            print("Home state: Swipe left detected")
//        case .swipeRight:
//            print("Home state: Swipe right detected")
//        default:
//            break
//        }
    }

    func getStateDescription() -> String {
        return "State: Home"
    }
}

class StoryTellingStateAction: AppStateAction {
    func handleHeadDistance(_ distance: HeadDistanceFromCenter) {
        // Lógica para Storytelling: altere conforme a necessidade
    }

    func handleHandAction(_ action: HandAction) {
        // Lógica para ações das mãos em Storytelling
    }

    func getStateDescription() -> String {
        return "State: Story Telling"
    }
}

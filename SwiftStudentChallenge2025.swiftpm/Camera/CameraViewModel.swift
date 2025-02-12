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

    init() {
        cameraManager.delegate = self
        cameraManager.startSession()

        // Managers closures
        handPoseManager.onPredictionUpdate = { [weak self] action in
            self?.predictedAction = action
            self?.viewController.handAction = action
        }
        faceManager.onFaceDataUpdate = { [weak self] inclination, distance in
            self?.headInclination = inclination
            self?.distanceFromCenter = distance
            self?.viewController.headDistanceFromCenter = distance
        }
    }
    
    func stopCameraSession() {
        cameraManager.stopSession()
    }
    
    // getter to the viewRepresentable
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

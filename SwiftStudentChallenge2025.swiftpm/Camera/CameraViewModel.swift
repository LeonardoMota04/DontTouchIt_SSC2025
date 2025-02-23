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
    // MARK: - MANAGERS
    private let cameraManager = CameraManager()
    private let handPoseManager = HandPoseManager()
    private let faceManager = FaceManager()
    let viewController = CubeViewController()

    // MARK: - PUBLISHERS VARIABLES
    @Published var showPermissionAlert: Bool = false

    @Published var predictedAction: HandAction?
    @Published var distanceFromCenter: HeadDistanceFromCenter?
    @Published var currentAppState: AppState = .home {
        didSet { viewController.updateAppState(currentAppState) }
    }

    init() {
        cameraManager.delegate = self
        setupManagers()
    }
    
    // MANAGERS
    private func setupManagers() {
        // HAND ACTIONS RESULTS
        handPoseManager.onPredictionUpdate = { [weak self] action in
            self?.predictedAction = action
            self?.viewController.handAction = action // viewController call
        }

        // FACE RESULTS
         faceManager.onFaceDataUpdate = { [weak self] distance in
             self?.distanceFromCenter = distance
             self?.viewController.headDistanceFromCenter = distance // viewController call
         }
    }

    // CAMERA PERMISSION
    func checkCameraPermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            cameraManager.startSession()
        } else {
            showPermissionAlert = true
        }
    }
    
    func stopCameraSession() {
        cameraManager.stopSession()
    }

    func getCaptureSession() -> AVCaptureSession { // getter
        return cameraManager.captureSession
    }
}

extension CameraViewModel: CameraManagerDelegate {
    func cameraManagerDidFailWithError(_ manager: CameraManager, error: CameraManager.CameraError) {
        DispatchQueue.main.async {
            self.showPermissionAlert = true
        }
    }
    
    func cameraManager(_ manager: CameraManager, didCapture sampleBuffer: CMSampleBuffer) {
        handPoseManager.processHandPose(from: sampleBuffer)
        faceManager.processFace(from: sampleBuffer)
    }
}

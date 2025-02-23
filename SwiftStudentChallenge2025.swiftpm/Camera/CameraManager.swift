//
//  CameraManager.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 22/01/25.
//

import AVFoundation
import UIKit

protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didCapture sampleBuffer: CMSampleBuffer) // buffer capture
    func cameraManagerDidFailWithError(_ manager: CameraManager, error: CameraManager.CameraError) // camera config error
}

class CameraManager: NSObject {
    // error structure
    enum CameraError: Error {
        case permissionDenied
        case configurationFailed
        case cameraNotFound
    }

    // MARK: - VARIABLES
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    weak var delegate: CameraManagerDelegate?

    override init() {
        super.init()
        checkCameraPermission()
    }

    // MARK: - FUNCTIONS
    // MARK: CAMERA PERMISSION
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCaptureSession()
                    }
                }
            }
        case .denied, .restricted:
            delegate?.cameraManagerDidFailWithError(self, error: .permissionDenied)
        @unknown default:
            return
        }
    }

    // MARK: CAPTURE SESSION
    private func setupCaptureSession() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(input),
              captureSession.canAddOutput(videoOutput) else {
            return
        }

        captureSession.addInput(input)
        captureSession.addOutput(videoOutput)
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    }


    // MARK: START/STOP SESSION
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.cameraManager(self, didCapture: sampleBuffer)
    }
}

//
//  CameraManager.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 22/01/25.
//

import AVFoundation

protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didCapture sampleBuffer: CMSampleBuffer)
}

// CAMERA MANAGER
class CameraManager: NSObject {
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    weak var delegate: CameraManagerDelegate?
    
    override init() {
        super.init()
        checkCameraPermission()
    }
    
    // checking camera permission
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("Camera access granted")
                    self.setupCaptureSession()
                } else {
                    print("Camera access denied")
                }
            }
        default:
            print("Camera access denied")
        }
    }


    private func setupCaptureSession() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Erro: Dispositivo de câmera não encontrado.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                print("Erro: Não foi possível adicionar o input da câmera.")
                return
            }

            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            } else {
                print("Erro: Não foi possível adicionar o output de vídeo.")
                return
            }

            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        } catch {
            print("Erro ao configurar a câmera: \(error.localizedDescription)")
        }
    }
    
    func startSession() {
        if !captureSession.isRunning {
            DispatchQueue.main.async {
                self.captureSession.startRunning()
                print("Capture session iniciada.")
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .background).async {
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

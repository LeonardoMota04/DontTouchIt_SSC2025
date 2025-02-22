//
//  CameraViewRepresentable.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 23/01/25.
//

import SwiftUI
import AVFoundation

// camera preview to swiftui
struct CameraViewRepresentable: UIViewRepresentable {
    let captureSession: AVCaptureSession
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewWidth = UIScreen.main.bounds.width * 0.2
        let previewHeight = previewWidth * (9 / 16)
        let padding: CGFloat = 50
        
        let previewFrame = CGRect(
            x: UIScreen.main.bounds.width - previewWidth - padding - 100,
            y: padding,
            width: previewWidth,
            height: previewHeight
        )
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = previewFrame
        previewLayer.borderWidth = 2
        previewLayer.borderColor = UIColor.purple.cgColor
        previewLayer.cornerRadius = 15
        
        if let connection = previewLayer.connection {
            connection.videoRotationAngle = 180
        }

        view.layer.addSublayer(previewLayer)
        
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            
            let previewWidth = UIScreen.main.bounds.width * 0.2
            let previewHeight = previewWidth * (9 / 16)
            let padding: CGFloat = 50
            
            let previewFrame = CGRect(
                x: UIScreen.main.bounds.width - previewWidth - padding - 100,
                y: padding,
                width: previewWidth,
                height: previewHeight
            )
            previewLayer.frame = previewFrame
            
            previewLayer.borderWidth = 2
            previewLayer.borderColor = UIColor.purple.cgColor
            previewLayer.cornerRadius = 15
            
            if let connection = previewLayer.connection {
                connection.videoRotationAngle = 180
            }
        }
    }
}



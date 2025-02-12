//
//  CameraViewRepresentable.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 23/01/25.
//

import SwiftUI
import AVFoundation

struct CameraViewRepresentable: UIViewRepresentable {
    let captureSession: AVCaptureSession
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        // configuration of the camera preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        
        // video rotation angle (landscape right)
        if let connection = previewLayer.connection {
            connection.videoRotationAngle = 0
        }

        view.layer.addSublayer(previewLayer)
        
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = UIScreen.main.bounds
            if let connection = previewLayer.connection {
                connection.videoRotationAngle = 0
            }
        }
    }
}


// UIViewController Representable to bring the View Controller to SwiftUI
struct CubeView: UIViewControllerRepresentable {
    var viewController: CubeViewController

    func makeUIViewController(context: Context) -> CubeViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: CubeViewController, context: Context) {}
}

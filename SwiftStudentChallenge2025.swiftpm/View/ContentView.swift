//
//  ContentView 2.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 23/01/25.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject private var cameraVM = CameraViewModel()
    var body: some View {
        ZStack {
            CameraViewRepresentable(captureSession: cameraVM.getCaptureSession())
                .ignoresSafeArea(.all)
            CubeView(viewController: cameraVM.viewController)

            VStack {
                if let action = cameraVM.predictedAction {
                    Text("Hand Action: \(action)")
                        .font(.title)
                        .padding()
                }
                
                if let inclination = cameraVM.headInclination {
                    Text("Head Inclination: \(formatInclination(inclination))")
                        .font(.title)
                        .padding()
                }
                
                if let distance = cameraVM.distanceFromCenter {
                    if distance.horizontal > 80 {
                        Text("MT PRA ESQUERDA CABEÇUDO")
                            .font(.title)
                            .foregroundStyle(.red)
                            .padding()
                    } else if distance.horizontal < 20 {
                        Text("MT PRA DIREITA CABEÇUDO")
                            .font(.title)
                            .foregroundStyle(.red)
                            .padding()
                    } else {
                        Text(formatDistance(distance))
                            .font(.title)
                            .foregroundStyle(.red)
                            .padding()
                    }
                }
            }
        }
        .onDisappear {
            cameraVM.stopCameraSession()
        }
    }
    
    private func formatInclination(_ inclination: HeadInclination) -> String {
        let horizontal = String(format: "%.2f", inclination.horizontal)
        let vertical = String(format: "%.2f", inclination.vertical)
        return "Horizontal: \(horizontal), Vertical: \(vertical)"
    }
    
    private func formatDistance(_ distance: HeadDistanceFromCenter) -> String {
        let horizontal = String(format: "%.2f", distance.horizontal)
        let vertical = String(format: "%.2f", distance.vertical)
        return "Horizontal: \(horizontal), Vertical: \(vertical)"
    }
    
    private func rotate(_ rotation: HandAction) {
        guard cameraVM.viewController.sceneView.pointOfView != nil else { return }
        
        let adjustedRotation = cameraVM.viewController.adjustedRotation(rotation)
        
        cameraVM.viewController.rotate(adjustedRotation)
    }
}
#Preview {
    ContentView()
}




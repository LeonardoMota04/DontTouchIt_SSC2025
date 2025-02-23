//
//  FaceManager.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 30/01/25.
//

import Vision
import UIKit

class HeadDirectionDetector {
    static func calculateDistanceFromCenter(
        leftEye: CGPoint,
        rightEye: CGPoint,
        screenSize: CGSize
    ) -> HeadDistanceFromCenter {
        let cameraPositionOnIpad = UserIpadSchemaManager.getCameraPosition() // gets information about the camera position on the iPad
        
        // EYES CENTRAL POINT
        let eyeCenterX = (leftEye.x + rightEye.x) / 2
        let eyeCenterY = (leftEye.y + rightEye.y) / 2

        let horizontalDistance: CGFloat
        let verticalDistance: CGFloat

        // DEALING WITH IPAD CAMERAS IN THE SIDE
        // MARK: - 100 <---------------> 0
        
        // MARK: - TOP CAMERA
        if cameraPositionOnIpad == .top {
           let cameraOffsetX = screenSize.width * 0.15
           let logicalCenterY = screenSize.height / 2

           let minX = cameraOffsetX
           let maxX = screenSize.width - cameraOffsetX

           horizontalDistance = ((eyeCenterX - minX) / (maxX - minX)) * 100
           verticalDistance = ((eyeCenterY - logicalCenterY) / (screenSize.height / 2)) * 100
        // MARK: - SIDE CAMERA
       } else {
           horizontalDistance = ((eyeCenterX / screenSize.width) * 100)
           verticalDistance = ((eyeCenterY / screenSize.height) * 100)
       }

        return HeadDistanceFromCenter(horizontal: horizontalDistance, vertical: verticalDistance)
    }
}

class FaceManager {
    private let faceLandmarksRequest = VNDetectFaceLandmarksRequest()
    
    var onFaceDataUpdate: ((HeadDistanceFromCenter) -> Void)?

    func processFace(from sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .down)

        do {
            try requestHandler.perform([faceLandmarksRequest])
            if let results = faceLandmarksRequest.results {
                for observation in results {
                    processObservation(observation)
                }
            }
        } catch {
            print("Error processing face: \(error)")
        }
    }

    private func processObservation(_ observation: VNFaceObservation) {
        // landmarks
        guard let landmarks = observation.landmarks else { return }
        guard let leftEye = landmarks.leftEye?.normalizedPoints.first,
              let rightEye = landmarks.rightEye?.normalizedPoints.first else { return }

        let faceBoundingBox = observation.boundingBox
        let leftEyePoint = convertLandmarkPoint(leftEye, boundingBox: faceBoundingBox)
        let rightEyePoint = convertLandmarkPoint(rightEye, boundingBox: faceBoundingBox)
        
        let distance = HeadDirectionDetector.calculateDistanceFromCenter(
            leftEye: leftEyePoint,
            rightEye: rightEyePoint,
            screenSize: UIScreen.main.bounds.size
        )

        DispatchQueue.main.async {
            self.onFaceDataUpdate?(distance)
        }
    }
    
    private func convertLandmarkPoint(_ point: CGPoint, boundingBox: CGRect) -> CGPoint {
        return CGPoint(
            x: point.x * boundingBox.width * UIScreen.main.bounds.width + boundingBox.origin.x * UIScreen.main.bounds.width,
            y: point.y * boundingBox.height * UIScreen.main.bounds.height + boundingBox.origin.y * UIScreen.main.bounds.height
        )
    }
}


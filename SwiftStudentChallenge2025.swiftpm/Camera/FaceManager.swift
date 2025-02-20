//
//  FaceManager.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 30/01/25.
//

import Vision
import UIKit

class HeadDirectionDetector {
    static func calculateInclination(
        leftEye: CGPoint,
        rightEye: CGPoint,
        nose: CGPoint,
        faceBoundingBox: CGRect
    ) -> HeadInclination {
        let eyeCenterX = (leftEye.x + rightEye.x) / 2
        let eyeCenterY = (leftEye.y + rightEye.y) / 2

        let horizontalOffset = nose.x - eyeCenterX
        let verticalOffset = nose.y - eyeCenterY

        let horizontalLookPercentage = -(horizontalOffset / faceBoundingBox.width) // aumentar a tolerância
        let verticalLookPercentage = (verticalOffset / faceBoundingBox.height)

        return HeadInclination(horizontal: horizontalLookPercentage, vertical: verticalLookPercentage)
    }
    
    static func calculateDistanceFromCenter(
        leftEye: CGPoint,
        rightEye: CGPoint,
        screenSize: CGSize
    ) -> HeadDistanceFromCenter {
        
        // EYES CENTRAL POINT
        let eyeCenterX = (leftEye.x + rightEye.x) / 2
        let eyeCenterY = (leftEye.y + rightEye.y) / 2

        // DEALING WITH IPAD CAMERAS IN THE SIDE
        // MARK: - 100 <---------------> 0
        let screenSize = UIScreen.main.bounds.size
        let cameraOffsetX = screenSize.width * 0.15
        let logicalCenterY = screenSize.height / 2
        
        let minX = cameraOffsetX
        let maxX = screenSize.width - cameraOffsetX
        
        let horizontalDistance = ((eyeCenterX - minX) / (maxX - minX)) * 100
        let verticalDistance = ((eyeCenterY - logicalCenterY) / (screenSize.height / 2)) * 100

        return HeadDistanceFromCenter(horizontal: horizontalDistance, vertical: verticalDistance)
    }
}

class FaceManager {
    private let faceLandmarksRequest = VNDetectFaceLandmarksRequest()
    
    var onFaceDataUpdate: ((HeadInclination, HeadDistanceFromCenter) -> Void)?

    func processFace(from sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        // TODO: - LIDAR COM ORIENTACAO DO IPAD
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
              let rightEye = landmarks.rightEye?.normalizedPoints.first,
              let nose = landmarks.nose?.normalizedPoints.first else { return }

        let faceBoundingBox = observation.boundingBox
        let leftEyePoint = convertLandmarkPoint(leftEye, boundingBox: faceBoundingBox)
        let rightEyePoint = convertLandmarkPoint(rightEye, boundingBox: faceBoundingBox)
        let nosePoint = convertLandmarkPoint(nose, boundingBox: faceBoundingBox)

        // INCLINATION and DISTANCE FROM CENTER
        let inclination = HeadDirectionDetector.calculateInclination(
            leftEye: leftEyePoint,
            rightEye: rightEyePoint,
            nose: nosePoint,
            faceBoundingBox: faceBoundingBox
        )
        
        let distance = HeadDirectionDetector.calculateDistanceFromCenter(
            leftEye: leftEyePoint,
            rightEye: rightEyePoint,
            screenSize: UIScreen.main.bounds.size
        )

        DispatchQueue.main.async {
            self.onFaceDataUpdate?(inclination, distance)
        }
    }
    
    private func convertLandmarkPoint(_ point: CGPoint, boundingBox: CGRect) -> CGPoint {
        return CGPoint(
            x: point.x * boundingBox.width * UIScreen.main.bounds.width + boundingBox.origin.x * UIScreen.main.bounds.width,
            y: point.y * boundingBox.height * UIScreen.main.bounds.height + boundingBox.origin.y * UIScreen.main.bounds.height
        )
    }
    
    // getting ipad orientation
    func currentOrientation() -> CGImagePropertyOrientation {
        let orientation = UIDevice.current.orientation
        
        switch orientation {
        case .landscapeLeft:
            return .right
        case .landscapeRight:
            return .left
        case .portraitUpsideDown:
            return .up
        default:
            return .down
        }
    }
}


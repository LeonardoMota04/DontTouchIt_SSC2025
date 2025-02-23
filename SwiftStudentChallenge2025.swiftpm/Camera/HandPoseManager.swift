//
//  HandPoseManager.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 30/01/25.
//

import Vision
import CoreML
import UIKit

class HandPoseManager {
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private let handActionModel = try? DontTouchIt_HandActionClassifier(configuration: MLModelConfiguration())
    private let confidenceThreshold: Float = 0.85 // 85% CONFIDENCE
    private var queue: [MLMultiArray] = []
    private let queueSize = 30
    
    var onPredictionUpdate: ((HandAction) -> Void)?
    
    func processHandPose(from sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .down)
        
        do {
            try requestHandler.perform([handPoseRequest])
            
            if handPoseRequest.results?.isEmpty ?? true {
                DispatchQueue.main.async {
                    self.onPredictionUpdate?(.none)
                }
            } else {
                if let results = handPoseRequest.results {
                    for observation in results {
                        processObservation(observation)
                    }
                }
            }
        } catch {
            print("Error processing hand pose: \(error)")
        }
    }
    
    // processing hand results
    private func processObservation(_ observation: VNHumanHandPoseObservation) {
        guard let multiArray = try? observation.keypointsMultiArray() else { return }
        queue.append(multiArray)
        queue = Array(queue.suffix(queueSize))
        
        // 30 prediction window size
        if queue.count == queueSize {
            do {
                let concatenated = MLMultiArray(concatenating: queue, axis: 0, dataType: .float32)
                if let prediction = try handActionModel?.prediction(poses: concatenated),
                   let confidence = prediction.labelProbabilities[prediction.label],
                   confidence > Double(confidenceThreshold) { // confidence
                    DispatchQueue.main.async {
                        if let handRotation = HandAction(predictionLabel: prediction.label) {
                            self.onPredictionUpdate?(handRotation) // sends handaction result
                        }
                    }
                }
            } catch {
                print("Error predicting hand action: \(error)")
            }
        }
    }
}

//
//  HandPoseManager.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 30/01/25.
//

import Vision
import CoreML

class HandPoseManager {
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private let handActionModel = try? SwiftStudentChallenge2025_HandActionClassifier_3_copy(configuration: MLModelConfiguration())
    private let confidenceThreshold: Float = 0.95
    private var queue: [MLMultiArray] = []
    private let queueSize = 15
    
    var onPredictionUpdate: ((HandAction) -> Void)?
    
    func processHandPose(from sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
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
    
    private func processObservation(_ observation: VNHumanHandPoseObservation) {
        guard let multiArray = try? observation.keypointsMultiArray() else { return }
        queue.append(multiArray)
        queue = Array(queue.suffix(queueSize))
        
        if queue.count == queueSize {
            do {
                let concatenated = MLMultiArray(concatenating: queue, axis: 0, dataType: .float32)
                if let prediction = try handActionModel?.prediction(poses: concatenated),
                   let confidence = prediction.labelProbabilities[prediction.label],
                   confidence > Double(confidenceThreshold) {
                    DispatchQueue.main.async {
                        if let handRotation = HandAction(predictionLabel: prediction.label) {
                            self.onPredictionUpdate?(handRotation)
                        }
                    }
                }
            } catch {
                print("Error predicting hand action: \(error)")
            }
        }
    }
}

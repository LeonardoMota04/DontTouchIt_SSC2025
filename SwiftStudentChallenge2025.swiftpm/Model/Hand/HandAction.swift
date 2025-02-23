//
//  HandAction.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 04/02/25.
//

import Foundation
import SceneKit

enum HandAction: Equatable {
    /// cube controll
    case right(RotationType)
    case left(RotationType)
    case up(RotationType)
    case down(RotationType)
    case face(RotationType)
    case back(RotationType)
    
    // camera controll
    case rotateCamera(RotationType)
    
    case none // unknown hand action (user is just moving their hands)

    var axis: SCNVector3 {
        switch self {
        case .right, .left: return SCNVector3(1, 0, 0)  // X
        case .up, .down: return SCNVector3(0, 1, 0)     // Y
        case .face, .back: return SCNVector3(0, 0, 1)   // Z
        case .rotateCamera: return SCNVector3(0, 1, 0)  // Y
        case .none: return SCNVector3(0, 0, 0)          // none
        }
    }

    var angle: CGFloat {
        switch self {
        case .right(let type), .up(let type), .face(let type):
            return type == .clockwise ? -.pi / 2 : .pi / 2
        case .left(let type), .down(let type), .back(let type):
            return type == .clockwise ? .pi / 2 : -.pi / 2
        case .rotateCamera(let type):
            return type == .clockwise ? -.pi / 2 : .pi / 2
        case .none:
            return 0
        }
    }

    func layerPosition(for cube: Cube) -> Float {
        let offset = cube.offsetSpace()
        switch self {
        case .right, .up, .face: return offset
        case .left, .down, .back: return -offset
        default: return 0
        }
    }
}

// MARK: - HAND ACTIONS LABELS
extension HandAction {
    init?(predictionLabel: String) {
        switch predictionLabel {
        case "none":
            self = .none
        case "other":
            self = .none
        case "right_clock":
            self = .right(.clockwise)
        case "left_counter":
            self = .left(.counterclockwise)
        case "camera_clock":
            self = .rotateCamera(.counterclockwise)
        case "camera_counter":
            self = .rotateCamera(.clockwise)
        default:
            return nil
        }
    }
}

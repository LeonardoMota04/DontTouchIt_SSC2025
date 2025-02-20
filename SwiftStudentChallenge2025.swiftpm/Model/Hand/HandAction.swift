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

    /// eixo de rotação correspondente
    var axis: SCNVector3 {
        switch self {
        case .right, .left: return SCNVector3(1, 0, 0)  // X
        case .up, .down: return SCNVector3(0, 1, 0)     // Y
        case .face, .back: return SCNVector3(0, 0, 1)   // Z
        case .rotateCamera: return SCNVector3(0, 1, 0)  // Y (rotação da câmera na horizontal)
        case .none: return SCNVector3(0, 0, 0)          // none
        }
    }

    /// se a rotação é horária ou anti-horária
    var angle: CGFloat {
        switch self {
        case .right(let type), .up(let type), .face(let type):
            return type == .clockwise ? -.pi / 2 : .pi / 2
        case .left(let type), .down(let type), .back(let type):
            return type == .clockwise ? .pi / 2 : -.pi / 2
        case .rotateCamera(let type):
            return type == .clockwise ? -.pi / 2 : .pi / 2 // 90 graus para a esquerda ou direita
        case .none:
            return 0 // Nenhum ângulo
        }
    }

    /// Retorna a posição da camada com base no eixo
    func layerPosition(for cube: RubiksCube) -> Float {
        let offset = cube.cubeOffsetDistance()
        switch self {
        case .right, .up, .face: return offset
        case .left, .down, .back: return -offset
        default: return 0
        }
    }

    /// Descrição da ação para debug
    func description() -> String {
        let type = (self.angle > 0) ? "Clockwise" : "Counterclockwise"
        switch self {
        case .right: return "Right - \(type)"
        case .left: return "Left - \(type)"
        case .up: return "Up - \(type)"
        case .down: return "Down - \(type)"
        case .face: return "Face - \(type)"
        case .back: return "Back - \(type)"
        case .rotateCamera: return "Rotate Camera - \(type)"
        case .none: return "No action detected"
        }
    }
}

extension HandAction {
    init?(predictionLabel: String) {
        switch predictionLabel {
        case "NONE":
            self = .none
        case "RIGHT-clockwise":
            self = .right(.clockwise)
        case "CAMERA-clockwise":
            self = .rotateCamera(.counterclockwise)
        case "CAMERA-counterclockwise":
            self = .rotateCamera(.clockwise)
        default:
            return nil
        }
    }
}

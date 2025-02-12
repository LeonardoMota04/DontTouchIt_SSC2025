//
//  HandRotation.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 04/02/25.
//

import Foundation
import SceneKit

enum HandAction {
    case right(RotationType)
    case left(RotationType)
    case up(RotationType)
    case down(RotationType)
    case face(RotationType)
    case back(RotationType)
    case none // Caso especial para "BG"

    /// Retorna o eixo de rotação correspondente à ação
    var axis: SCNVector3 {
        switch self {
        case .right, .left: return SCNVector3(1, 0, 0)  // Eixo X
        case .up, .down: return SCNVector3(0, 1, 0)      // Eixo Y
        case .face, .back: return SCNVector3(0, 0, 1)    // Eixo Z
        case .none: return SCNVector3(0, 0, 0)           // Nenhum eixo
        }
    }

    /// Determina se a rotação é horária ou anti-horária
    var angle: CGFloat {
        switch self {
        case .right(let type), .up(let type), .face(let type):
            return type == .clockwise ? -.pi / 2 : .pi / 2
        case .left(let type), .down(let type), .back(let type):
            return type == .clockwise ? .pi / 2 : -.pi / 2
        case .none:
            return 0 // Nenhum ângulo
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
        case .none: return "No action detected"
        }
    }
}

extension HandAction {
    init?(predictionLabel: String) {
        switch predictionLabel {
        case "BG":
            self = .none // Caso especial para "BG"
        case "RIGHTHAND_ROTATION":
            self = .right(.clockwise) // Mapeia "RIGHTHAND_ROTATION" para uma rotação à direita no sentido horário
        default:
            return nil // Caso não reconhecido
        }
    }
}

//
//  Extensions.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 04/02/25.
//

import Foundation
import SceneKit

// MARK: - EXTENSIONS
extension Float {
    func isVeryClose(to: Float, withTolerance: Float) -> Bool {
        let a = self
        let absA = abs(a)
        let absB = abs(to)
        let diff = abs(a - to)
        
        if (a == to) {
            // if A and B are equal, no necessity of verifying more
            return true
        } else if (a == 0 || to == 0 || diff < Float.leastNormalMagnitude) {
            // if A or B are zero, or both are nearly equal zero, error comparison is less important here
            return diff < (withTolerance * Float.leastNormalMagnitude)
        } else {
            // use relative error
            return diff / (absA + absB) < withTolerance
        }
    }
}

// SCNVector3 equatable so I can use it inside a SWITCH - CASE
extension SCNVector3: Equatable {
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

// extract hand rotation model from coreml response
extension HandAction {
    init?(rawValue: String) {
        let components = rawValue.split(separator: "_").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        
        guard components.count == 2 else { return nil }
        
        let direction = components[0]
        let rotationType: RotationType = (components[1] == "clockwise") ? .clockwise : .counterclockwise
        
        switch direction {
        case "right":
            self = .right(rotationType)
        case "left":
            self = .left(rotationType)
        case "up":
            self = .up(rotationType)
        case "down":
            self = .down(rotationType)
        case "front":
            self = .face(rotationType)
        case "back":
            self = .back(rotationType)
        default:
            return nil
        }
    }
}

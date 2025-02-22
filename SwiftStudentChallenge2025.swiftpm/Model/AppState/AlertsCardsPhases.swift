//
//  AlertsCardsPhases.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 21/02/25.
//

import SwiftUI

enum AlertsCardsPhases {
    case onlyOneHead
    case distanceToTheScreen
    case enoughLight
    case handsVisible
    
    var title: String {
        switch self {
        case .onlyOneHead:
            return "One face at a time"
        case .distanceToTheScreen:
            return "Keep a nice distance"
        case .enoughLight:
            return "Good Lighting"
        case .handsVisible:
            return "Steady Hand"
        }
    }
    
    var image: Image {
        switch self {
        case .onlyOneHead:
            return Image("alert_twoHead")
        case .distanceToTheScreen:
            return Image("alert_distance")
        case .enoughLight:
            return Image("alert_light")
        case .handsVisible:
            return Image("alert_steadyHand")
        }
    }
    
    var description: String {
        switch self {
        case .onlyOneHead:
            return "Make sure only your face is visible. Avoid multiple faces in the frame, as this can interfere with detection."
        case .distanceToTheScreen:
            return "Position yourself about 20 inches (50 cm) from the screen. Sitting too close or too far may affect accuracy."
        case .enoughLight:
            return "Ensure your hands are well-lit and avoid strong backlight or shadows. Balanced lighting improves detection."
        case .handsVisible:
            return "When making gestures, keep only one hand visible and avoid unexpected movements to ensure proper tracking. Avoid keeping your hand off the frame between actions."
        }
    }
}

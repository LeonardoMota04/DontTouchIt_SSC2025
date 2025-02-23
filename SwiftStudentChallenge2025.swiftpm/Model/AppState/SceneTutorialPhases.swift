//
//  SceneTutorialPhases.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 21/02/25.
//

import SwiftUI

enum SceneTutorialPhases: CaseIterable {
    case intro
    case headCameraTracking
    case handActionCameraRotation
    case handActionCubeRightSideRotation
    
    var title: String {
        switch self {
        case .intro:
            return "You're all set."
        case .headCameraTracking:
            return "Camera - Head tracking"
        case .handActionCameraRotation:
            return "Camera - Hand action"
        case .handActionCubeRightSideRotation:
            return "Cube - Hand action"
        }
    }
    
    var image: Image? {
        switch self {
        case .intro:
            return nil
        case .headCameraTracking:
            return Image("sceneTutorialHead")
        case .handActionCameraRotation:
            return Image("sceneTutorialHandCameraRotation")
        case .handActionCubeRightSideRotation:
            return Image("sceneTutorialHandCubeSideRotation")
        }
    }
    
    var gifImages: [String]? {
        switch self {
            case .handActionCameraRotation:
                return ["handSwipe1", "handSwipe2", "handSwipe3"]
            case .handActionCubeRightSideRotation:
                return ["handRotation1", "handRotation2", "handRotation3"]
            default:
                return nil
        }
    }
    
    var description: String {
        switch self {
        case .intro:
            return "Let's get started. We are in the touchless era."
            
        case .headCameraTracking:
            return "You can track your head movement to rotate the camera. Keep your head inside the frame to ensure proper tracking. If you need to check your position, tap the button with the eye icon to enable the preview."
            
        case .handActionCameraRotation:
            return "To rotate the camera, use one hand positioned sideways. The required motion is similar to a swipe, sliding your hand to the left or right. You can use either hand, but only one at a time. For better control, try alternating between your left and right hand, making the movement smoothly. All movements should take around 0.5s."
            
        case .handActionCubeRightSideRotation:
            return "To rotate one face of the cube, this gesture simulates rotating one of the cube’s faces, as shown in the gif. Use your hand to perform a movement similar to turning the side face of a real cube. You can use either hand, but only one at a time. For better control, try alternating between your left and right hand, making the movement smoothly. All movements should take around 0.5s."
        }
    }
}

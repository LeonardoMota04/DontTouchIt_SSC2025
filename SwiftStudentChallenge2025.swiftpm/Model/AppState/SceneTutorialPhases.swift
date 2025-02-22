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
            return "Camera - Hand rotation"
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
    
    var description: String {
        switch self {
        case .intro:
            return "Let's get started. We are in the touchless era."
        case .headCameraTracking:
            return "You can track your head movement to rotate the camera"
        case .handActionCameraRotation:
            return "You can rotate your hand like this to rotate the camera"
        case .handActionCubeRightSideRotation:
            return "You can do this movement to rotate the right side of the cube"
        }
    }
}

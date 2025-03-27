//
//  UserIpadSchemaManager.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 21/02/25.
//

import Foundation
import UIKit

// dealing with different camera positions on newest iPad models
class UserIpadSchemaManager {
    private static let cameraPositionKey = "cameraPosition"

    static func saveCameraPosition(_ position: CameraPositionOnRealIpad) {
        UserDefaults.standard.set(position.rawValue, forKey: cameraPositionKey)
    }

    static func getCameraPosition() -> CameraPositionOnRealIpad {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        if isPad {
            if let savedValue = UserDefaults.standard.string(forKey: cameraPositionKey),
               let position = CameraPositionOnRealIpad(rawValue: savedValue) {
                return position
            }
        }
        
        return .top
    }
}

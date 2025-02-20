//
//  SwiftStudentChallenge2025App.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 20/01/25.
//

import SwiftUI

@main
struct SwiftStudentChallenge2025App: App {
    @StateObject private var cameraVM: CameraViewModel = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cameraVM)
        }
    }
}


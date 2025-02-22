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
    @State private var showSelectionScreen = UserIpadSchemaManager.getCameraPosition() == nil

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cameraVM)
                .overlay {
                    if showSelectionScreen {
                        CardInfoView(showInfoView: $showSelectionScreen)
                    }
                }
        }
    }
}

import SwiftUI

struct CameraPositionSelectionView: View {
    @Binding var showSelectionScreen: Bool

    var body: some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 15)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassy()

            .overlay {
                VStack {
                    Text("Onde fica a câmera no seu iPad?")
                        .font(.title2)
                        .bold()
                    
                    VStack (spacing: 20) {
                        
                        // top
                        HStack {
                            CustomButton(icon: "ipad.gen1.landscape") {
                                saveAndProceed(position: .top)
                            }
                            Text("TOP").bold()
                        }
                        
                        // side
                        HStack {
                            CustomButton(icon: "ipad.gen1.landscape") {
                                saveAndProceed(position: .side)
                            }
                            Text("SIDE").bold()
                        }
                        
                    }
                    
                }
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 400, height: 200)
            }

            .ignoresSafeArea()
        }
    }

    private func saveAndProceed(position: CameraPositionOnRealIpad) {
         UserIpadSchemaManager.saveCameraPosition(position)
         showSelectionScreen = false
     }
}
#Preview {
    CameraPositionSelectionView(showSelectionScreen: .constant(true))
}

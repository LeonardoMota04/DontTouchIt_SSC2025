//
//  HUDView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 21/02/25.
//

import SwiftUI

struct HUDView: View {
    @EnvironmentObject private var cameraVM: CameraViewModel

    var onHomeTap: () -> Void
    var onCameraTap: () -> Void
    var onInfoTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            
            // CREDITS / INFO BUTTON
            if cameraVM.currentAppState == .home {
                CustomButton(icon: "info") {
                    onInfoTap()
                }
            }
            
            Spacer()
            
            VStack {
                if cameraVM.currentAppState != .home {
                    // HOME BUTTON
                    CustomButton(icon: "house.fill") {
                        onHomeTap()
                    }
                }
                // CAMERA PREVIEW BUTTON
                CustomButton(icon: "eye.fill") {
                    onCameraTap()
                }
                .padding(.top, 8)
            
            }

        }
        .animation(.easeInOut, value: cameraVM.currentAppState)
        .padding(50)
        .ignoresSafeArea()

    }
}

#Preview {
    HUDView {
        
    } onCameraTap: {
        
    } onInfoTap: {
        
    }
    .environmentObject(CameraViewModel())

}


// CARD INFO VIEW
struct CardInfoView: View {
    @State private var itemsOffset: CGFloat = 300
    @Binding var showInfoView: Bool
    @State private var selectedPosition: CameraPositionOnRealIpad?

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                TitleView(itemsOffset: $itemsOffset)
                Text("A Swift Student Challenge 2025 submission. \nBy: Leonardo Pereira Mota.")
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .trailing) {
                Text("It is strongly recommended to be in a well-lit place.")
                Text("All image assets were made by me.")
            }
            .foregroundStyle(.white)
            .font(.body)
            .fontWeight(.medium)
        }
        .shadow(radius: 10)
        .padding(50)
        .glassy()
        .onAppear {
            withAnimation(Animation.bouncy(duration: 1.5).delay(0.5)) {
                itemsOffset = 0
                if UserIpadSchemaManager.getCameraPosition() == nil {
                    selectedPosition = .top
                } else {
                    selectedPosition = UserIpadSchemaManager.getCameraPosition()
                }
            }
        }
        // X BUTTON
        .overlay(alignment: .topTrailing) {
            CustomButton(icon: "xmark") {
                withAnimation { showInfoView = false }
            }
            .padding([.top, .trailing], -40)
        }
        // iPad buttons
        .overlay(alignment: .bottomTrailing) {
            VStack {
                Text("Where is your iPad's front camera?")
                    .multilineTextAlignment(.center)
                    .font(.callout)
                HStack(spacing: 70) {
                    VStack {
                        Image("topCamera_info")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .onTapGesture {
                                saveAndProceed(position: .top)
                            }
                        Text("TOP").bold().foregroundStyle(.white.opacity(0.8))
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(selectedPosition == .top ? Color.purple.opacity(0.5) : Color.clear, lineWidth: 8)
                            )
                    }
                    
                    VStack {
                        Image("sideCamera_info")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .onTapGesture {
                                saveAndProceed(position: .side)
                            }
                        Text("SIDE").bold().foregroundStyle(.white.opacity(0.8))

                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(selectedPosition == .side ? Color.purple.opacity(0.5) : Color.clear, lineWidth: 8)
                            )
                    }
                }
            }
            .frame(width: 300)
            .foregroundStyle(.white.opacity(0.8))
            .padding(50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background {
            Color.black.opacity(0.9).blur(radius: 5).ignoresSafeArea()
        }
    }

    private func saveAndProceed(position: CameraPositionOnRealIpad) {
        selectedPosition = position
        UserIpadSchemaManager.saveCameraPosition(position)
    }
}



#Preview {
    CardInfoView(showInfoView: .constant(true))
}

//
//  HUDView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 21/02/25.
//

import SwiftUI
import AVFoundation

struct HUDView: View {
    @EnvironmentObject private var cameraVM: CameraViewModel

    var onHomeTap: () -> Void
    var onCameraTap: () -> Void
    var onInfoTap: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let paddingValue = max(width * 0.02, 30)

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
            .padding(paddingValue)
            .ignoresSafeArea()
        }

    }
}


// CARD INFO VIEW
struct CardInfoView: View {
    @EnvironmentObject private var cameraVM: CameraViewModel

    @State private var itemsOffset: CGFloat = 300
    @State private var selectedPosition: CameraPositionOnRealIpad? = nil
    
    @Binding var showInfoView: Bool
    @State private var showAlert = false 

    var body: some View {
        GeometryReader { geo in
            let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
            let fontSize: CGFloat = isPad ? 100 : 50

            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    // SCENE TITLE
                    VStack(alignment: .leading, spacing: -fontSize * 0.3) {
                           Text("DON'T")
                               .foregroundStyle(.white)
                           Text("TOUCH")
                               .foregroundStyle(.purple)
                           Text("IT")
                               .foregroundStyle(.white)
                       }
                       .opacity(0.8)
                       .font(.system(size: fontSize, weight: .light))
                       .offset(y: -itemsOffset)

                   Text("A Swift Student Challenge 2025 submission. \nBy: Leonardo Pereira Mota.")
                       .foregroundStyle(.white)
                }
                
                VStack(alignment: .trailing) {
                    Text("It is strongly recommended to be in a well-lit place.")
                    Text("All image assets were made by me.")
                    
                    Text("Please turn your device to the left as in the picture")
                    Image("landscape_info")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                }
                .foregroundStyle(.white)
                .font(isPad ? .body : .footnote)
                .fontWeight(.medium)
            }
            .shadow(radius: 10)
            .padding(50)
            .glassy()
            .onAppear {
                withAnimation(Animation.bouncy(duration: 1.5).delay(0.5)) {
                    itemsOffset = 0
                }
            }
            
            // X BUTTON
            .overlay(alignment: .topTrailing) {
                CustomButton(icon: "xmark") {
                    if selectedPosition == nil {
                        showAlert = true // alert if no iPad schema selection
                    } else {
                        withAnimation {
                            showInfoView = false
                        }
                        cameraVM.checkCameraPermission()
                    }
                }
                .padding([.top, .trailing], isPad ? -40 : -20)
            }
            // iPad buttons
            .overlay(alignment: .bottomTrailing) {
                VStack {
                    Text("Select your iPad's front camera position:")
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
                .foregroundStyle(.white.opacity(0.8))
                .padding(.trailing, 50)
                .padding(.bottom, 30)
                .opacity(isPad ? 1 : 0)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background {
                Color.black.opacity(0.9).blur(radius: 5).ignoresSafeArea()
            }
            .onAppear {
                selectedPosition = UserIpadSchemaManager.getCameraPosition()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Please choose an iPad schema"),
                    message: Text("You must select either the top or side camera position to proceed."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // userdefaults info save
    private func saveAndProceed(position: CameraPositionOnRealIpad) {
        selectedPosition = position
        UserIpadSchemaManager.saveCameraPosition(position)
    }
}


#Preview {
    CardInfoView(showInfoView: .constant(true))
}


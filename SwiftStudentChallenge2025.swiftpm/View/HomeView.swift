//
//  HomeView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 19/02/25.
//

import SwiftUI

// MARK: - HOME VIEW
struct HomeView: View {
    @EnvironmentObject private var cameraVM: CameraViewModel
    
    // HEAD
    @State private var isTiltingHeadLEFT: Bool = false
    @State private var isTiltingHeadRIGHT: Bool = false
    
    // HEAD PROGRESS TIMER
    @State private var progress: CGFloat = 0
    @State private var loadingTimer: Timer?
    let loadingDuration: TimeInterval = 5.0
    
    // ANIMATION
    @State private var itemsOffset: CGFloat = 400
    
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            VStack {
                Text("DO NOT \n\(Text("TOUCH").foregroundStyle(.purple).bold()) \nIT")
                    .font(.system(size: 80, weight: .thin))
                    .foregroundStyle(.white)
                    .offset(y: -itemsOffset)
                
                Spacer()
                
                VStack {
                    Text("Tilt your head")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    
                    Image("tiltYourHead")
                    
                    Text("LEFT to full experience and RIGHT to free mode")
                }
                .font(.title3)
                .foregroundStyle(.white)
                .offset(y: itemsOffset)
                
            }
            .padding(.vertical, 60)
            .frame(width: width, height: height)
            .overlay {
                // PURPLE SIDES
                ZStack {
                    // Purple ellipses
                    HStack {
                        Ellipse()
                            .glassy(shape: Ellipse())
                            .frame(width: width / 3, height: height * 1.5)
                            .offset(x: -width / 10, y: -height / 10)
                            .opacity(isTiltingHeadLEFT ? 1 : 0)
                        
                        Spacer()
                        
                        Ellipse()
                            .glassy(shape: Ellipse())
                            .frame(width: width / 3, height: height * 1.5)
                            .offset(x: width / 10, y: -height / 10)
                            .opacity(isTiltingHeadRIGHT ? 1 : 0)
                        
                    }
                    // Progress circles
                    HStack {
                        if isTiltingHeadLEFT {
                            CircularProgressView(progress: progress)
                                .frame(width: 100)
                        }
                        
                        Spacer()
                        
                        if isTiltingHeadRIGHT {
                            CircularProgressView(progress: progress)
                                .frame(width: 100, height: 100)
                        }
                    }
                    .padding(50)
                }
                .animation(.easeOut, value: isTiltingHeadLEFT || isTiltingHeadRIGHT)
            }
            .onChange(of: cameraVM.distanceFromCenter) { _, newValue in
                guard let newValue = newValue else { return }
                
                let wasTilting = isTiltingHeadLEFT || isTiltingHeadRIGHT
                
                withAnimation {
                    isTiltingHeadRIGHT = newValue.horizontal < 10
                    isTiltingHeadLEFT = newValue.horizontal > 60
                }
                
                let isNowTilting = isTiltingHeadLEFT || isTiltingHeadRIGHT
                
                if isNowTilting {
                    if !wasTilting { startLoading() }
                } else {
                    resetLoading()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(Animation.bouncy(duration: 1.5).delay(0.5)) {
                itemsOffset = 0
            }
        }
    }
    
    private func startLoading() {
        loadingTimer?.invalidate()
        progress = 0
        
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if progress >= 1 {
                timer.invalidate()
                DispatchQueue.main.async {
                    // MARK: - LEFT (GOES TO SCENE)
                    if isTiltingHeadLEFT {
                        cameraVM.currentAppState = .storyTellingBegginig(.first)
                    // MARK: - RIGHT (GOES TO FREE MODE)
                    } else if isTiltingHeadRIGHT {
                        cameraVM.currentAppState = .freeMode
                    }
                }
            } else {
                progress += 0.1 / CGFloat(loadingDuration)
            }
        }
    }
    
    private func resetLoading() {
        loadingTimer?.invalidate()
        progress = 0
    }
}

// MARK: - Circular Progress View
struct CircularProgressView: View {
    var progress: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.purple.opacity(0.2), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.purple.opacity(0.8), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CameraViewModel())
}

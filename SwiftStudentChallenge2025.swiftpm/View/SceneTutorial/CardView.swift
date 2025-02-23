//
//  CardView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 21/02/25.
//

import SwiftUI
import AVKit

struct CardView: View {
    let phase: SceneTutorialPhases
    let geo: GeometryProxy
    let isInteracting: Bool
    let isMainCard: Bool


    var body: some View {
        let cardWidth = isInteracting ? geo.size.width / 8 : geo.size.width / 1.5
        let cardHeight = isInteracting ? geo.size.height / 8 : geo.size.height / 2

        ZStack {

            if phase == .intro {
                VStack {
                    Text(phase.title)
                        .foregroundStyle(.white)
                        .font(.system(size: 50))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(phase.description)
                        .foregroundStyle(.white)
                        .font(.body)
                }
                .padding(40)
            } else {
                VStack(alignment: .leading) {
                    if !isInteracting {
                        Text(phase.title)
                            .foregroundStyle(.white)
                            .font(.system(size: 50))
                            .fontWeight(.bold)
                            .padding(.leading, 50)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            // image
                            if isInteracting {
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 87.5)
                                }
                            // gif
                            } else {
                                if let gifImages = phase.gifImages {
                                    AnimatedGIFView(frames: gifImages)
                                } else {
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 350)
                                    }
                                }
                            }
                        }
                        
                        if !isInteracting {
                            Spacer()
                            
                            Text(phase.description)
                                .foregroundStyle(.white)
                                .font(.body)
                                .fontWeight(.medium)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .glassy()
        .padding([.leading, .top], (isMainCard && !isInteracting) ? 0 : 50)
        .frame(maxWidth: (isMainCard && !isInteracting) ? .infinity : nil,
               maxHeight: (isMainCard && !isInteracting) ? .infinity : nil, alignment: .center)
    }
}

#Preview {
    GeometryReader { geo in
        CardView(
            phase: .handActionCubeRightSideRotation,
            geo: geo,
            isInteracting: false,
            isMainCard: true
        )
        .padding()
    }
}


// MARK: - GIF VIEW
struct AnimatedGIFView: View {
    let frames: [String]
    @State private var currentIndex = 0
    
    var body: some View {
        Image(frames[currentIndex])
            .resizable()
            .scaledToFit()
            .glassy()
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    currentIndex = (currentIndex + 1) % frames.count
                }
            }
    }
}


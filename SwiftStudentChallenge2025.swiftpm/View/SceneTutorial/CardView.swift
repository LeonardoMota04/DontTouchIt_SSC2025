//
//  CardView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 21/02/25.
//

import SwiftUI

struct CardView: View {
    let phase: SceneTutorialPhases
    let geo: GeometryProxy
    let isInteracting: Bool
    let isMainCard: Bool
    
    var body: some View {
        let cardWidth = isInteracting ? geo.size.width / 8 : geo.size.width / 1.5
        let cardHeight = isInteracting ? geo.size.height / 8 : geo.size.height / 2

        return ZStack {
            RoundedRectangle(cornerRadius: 16)
            
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
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: isInteracting ? 87.5 : 350)
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
        .frame(maxWidth: (isMainCard  && !isInteracting) ? .infinity : nil,
               maxHeight: (isMainCard  && !isInteracting) ? .infinity : nil, alignment: .center)
    }
}

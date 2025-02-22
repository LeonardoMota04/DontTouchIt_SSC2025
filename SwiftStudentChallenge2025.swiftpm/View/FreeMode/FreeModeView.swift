//
//  FreeModeView.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 20/02/25.
//

import SwiftUI

struct FreeModeView: View {
    @State private var phase = SceneTutorialPhases.handActionCubeRightSideRotation

    var body: some View {
        SceneTutorialView(phase: phase, isFreeMode: true, onTap: {}, onTapPhase: { new in
            phase = new
        })
    }
}

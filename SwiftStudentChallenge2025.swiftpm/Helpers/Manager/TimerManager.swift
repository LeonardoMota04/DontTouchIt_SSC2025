//
//  TimerManager.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 21/02/25.
//

import SwiftUI

// timer manager to transition between scene interaction tutorial
final class TimerManager: ObservableObject {
    @Published var remainingTime: Int = 8 
    var phasesWithTimerActivated: Set<SceneTutorialPhases> = []
    private var timer: Timer?
    
    func startTimer(completion: @escaping () -> Void) {
        remainingTime = 8
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.timer?.invalidate()
                completion()
            }
        }
    }
}

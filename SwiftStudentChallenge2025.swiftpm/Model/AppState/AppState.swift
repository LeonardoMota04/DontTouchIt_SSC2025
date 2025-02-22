//
//  AppState.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 21/02/25.
//

import Foundation

enum AppState: Hashable {
    case home
    case storyTellingBegginig(StoryTellingBegginigPhases)
    case alertsCards(AlertsCardsPhases)
    case sceneTutorial(SceneTutorialPhases)
    case freeMode
}

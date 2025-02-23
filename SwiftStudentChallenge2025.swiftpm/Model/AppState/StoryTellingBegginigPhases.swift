//
//  StoryTellingBegginigPhases.swift
//  SwiftStudentChallenge2025
//
//  Created by Leonardo Mota on 21/02/25.
//

import Foundation

enum StoryTellingBegginigPhases {
    case first
    case second
    case third
    case fourth
    case fifth
    case sixth
    
    var text: String {
        switch self {
        case .first:
            return "The world is changing... Closer than ever, more connected..."
        case .second:
            return "Everything moves fast. Technology advances. Society evolves."
        case .third:
            return "But sometimes, in the middle of all the rush... we are far from what is real."
        case .fourth:
            return "What if we didn’t need this distance?"
        case .fifth:
            return "We don’t. We already live in the era of gestures, minimal touch, maximum presence."
        case .sixth:
            return "What if we could merge the real and the virtual?"
        }
    }
    
    var hasOffset: Bool {
        switch self {
        case .first, .second, .third:
            return false
        default:
            return true
        }
    }
}

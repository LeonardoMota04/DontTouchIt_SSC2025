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
            return "O mundo está mudando... Cada vez mais próximo, mais conectado..."
        case .second:
            return "Tudo é muito rápido. A tecnologia avança. A sociedade evolui."
        case .third:
            return "Mas, às vezes, no meio de tanta correria... estamos longe do que é real."
        case .fourth:
            return "E se não precisássemos dessa distância?"
        case .fifth:
            return "Não precisamos. Já vivemos na era dos gestos, do toque mínimo, da presença máxima."
        case .sixth:
            return "E se pudéssemos unir o real e o virtual?"
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

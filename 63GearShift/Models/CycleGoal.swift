//
//  CycleGoal.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation

enum CycleGoal: String, CaseIterable, Identifiable, Codable {
    case strength = "Strength"
    case mass = "Mass"
    case endurance = "Endurance"
    case peakForm = "Peak Form by Date"
    
    var id: String { rawValue }
}

enum CycleDuration: Int, CaseIterable, Identifiable, Codable {
    case four = 4
    case six = 6
    case eight = 8
    
    var id: Int { rawValue }
    
    var displayName: String {
        "\(rawValue) weeks"
    }
}

enum Aggressiveness: String, CaseIterable, Identifiable, Codable {
    case conservative = "Conservative"
    case moderate = "Moderate"
    case aggressive = "Aggressive"
    
    var id: String { rawValue }
    
    var riskMultiplier: Double {
        switch self {
        case .conservative: return 0.7
        case .moderate: return 1.0
        case .aggressive: return 1.3
        }
    }
}

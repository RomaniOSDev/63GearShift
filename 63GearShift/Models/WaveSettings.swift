//
//  WaveSettings.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation

struct WaveSettings: Codable {
    // Wave pattern customization
    var loadingWeeksRatio: Double // Ratio of loading weeks to deload (default: 0.7)
    var deloadReduction: Double // Percentage reduction during deload (default: 0.3)
    var peakIntensity: Double // Maximum intensity multiplier (default: 1.0)
    
    // Microcycle settings
    var microcycleLength: Int // Length of microcycle in weeks (default: 3)
    var enableCustomMicrocycles: Bool // Allow custom microcycle patterns
    
    // Fatigue calculation
    var fatigueDecayRate: Double // How fast fatigue decays (default: 0.1)
    var recoveryMultiplier: Double // Recovery speed multiplier (default: 1.0)
    
    // Advanced
    var enableAdaptiveWave: Bool // Automatically adjust wave based on performance
    var adaptiveThreshold: Double // Performance threshold for adaptation (default: 0.8)
    
    init(
        loadingWeeksRatio: Double = 0.7,
        deloadReduction: Double = 0.3,
        peakIntensity: Double = 1.0,
        microcycleLength: Int = 3,
        enableCustomMicrocycles: Bool = false,
        fatigueDecayRate: Double = 0.1,
        recoveryMultiplier: Double = 1.0,
        enableAdaptiveWave: Bool = false,
        adaptiveThreshold: Double = 0.8
    ) {
        self.loadingWeeksRatio = loadingWeeksRatio
        self.deloadReduction = deloadReduction
        self.peakIntensity = peakIntensity
        self.microcycleLength = microcycleLength
        self.enableCustomMicrocycles = enableCustomMicrocycles
        self.fatigueDecayRate = fatigueDecayRate
        self.recoveryMultiplier = recoveryMultiplier
        self.enableAdaptiveWave = enableAdaptiveWave
        self.adaptiveThreshold = adaptiveThreshold
    }
    
    static let `default` = WaveSettings()
}

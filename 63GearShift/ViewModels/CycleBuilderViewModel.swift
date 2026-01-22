//
//  CycleBuilderViewModel.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftUI
import Combine

class CycleBuilderViewModel: ObservableObject {
    @Published var selectedGoal: CycleGoal = .strength
    @Published var selectedDuration: CycleDuration = .six
    @Published var initialFreshness: Double = 0.5
    @Published var selectedAggressiveness: Aggressiveness = .moderate
    @Published var peakFormDate: Date = Calendar.current.date(byAdding: .weekOfYear, value: 6, to: Date()) ?? Date()
    @Published var hasPeakDate: Bool = false
    
    var previewWeeks: [CycleWeek] {
        WaveCalculator.generateWave(
            duration: selectedDuration,
            initialFreshness: initialFreshness,
            aggressiveness: selectedAggressiveness,
            goal: selectedGoal
        )
    }
    
    func buildCycle() -> TrainingCycle {
        // Allow cycles to start immediately - multiple cycles can be active simultaneously
        var cycle = TrainingCycle(
            goal: selectedGoal,
            duration: selectedDuration,
            startDate: Date(),
            aggressiveness: selectedAggressiveness,
            initialFreshness: initialFreshness,
            peakFormDate: hasPeakDate ? peakFormDate : nil
        )
        cycle.weeks = previewWeeks
        return cycle
    }
}

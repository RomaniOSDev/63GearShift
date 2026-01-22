//
//  ActiveCycleViewModel.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftUI
import Combine

class ActiveCycleViewModel: ObservableObject {
    @Published var cycle: TrainingCycle
    
    private let storageService = StorageService.shared
    var onCycleUpdate: ((TrainingCycle) -> Void)?
    
    init(cycle: TrainingCycle, onCycleUpdate: ((TrainingCycle) -> Void)? = nil) {
        self.cycle = cycle
        self.onCycleUpdate = onCycleUpdate
    }
    
    var currentWeekIndex: Int? {
        guard let weekNum = cycle.currentWeek else { return nil }
        return weekNum - 1
    }
    
    var currentWeek: CycleWeek? {
        guard let index = currentWeekIndex, index < cycle.weeks.count else { return nil }
        return cycle.weeks[index]
    }
    
    var recommendation: String {
        guard let current = currentWeek else {
            return "Start your cycle to see recommendations"
        }
        
        let previousWeek = currentWeekIndex != nil && currentWeekIndex! > 0 
            ? cycle.weeks[currentWeekIndex! - 1] 
            : nil
        
        return WaveCalculator.calculateRecommendation(
            currentWeek: current,
            previousWeek: previousWeek,
            planCompletion: current.planCompletion,
            wellbeing: current.wellbeing
        )
    }
    
    func updateWeek(
        weekIndex: Int,
        planCompletion: Double,
        wellbeing: Int
    ) {
        guard weekIndex < cycle.weeks.count else { return }
        
        var week = cycle.weeks[weekIndex]
        week.planCompletion = planCompletion
        week.wellbeing = wellbeing
        
        // Calculate actual fatigue based on completion and wellbeing
        let baseFatigue = week.targetFatigue
        let completionFactor = planCompletion / 100.0
        let wellbeingFactor = Double(wellbeing) / 5.0
        week.actualFatigue = baseFatigue * completionFactor * (2.0 - wellbeingFactor)
        
        cycle.weeks[weekIndex] = week
        
        // Adjust next week if exists
        if weekIndex + 1 < cycle.weeks.count {
            let nextWeek = cycle.weeks[weekIndex + 1]
            let adjustedTarget = WaveCalculator.adjustNextWeek(
                currentWeek: week,
                planCompletion: planCompletion,
                wellbeing: wellbeing,
                originalTarget: nextWeek.targetFatigue
            )
            cycle.weeks[weekIndex + 1].targetFatigue = adjustedTarget
        }
        
        // Notify parent to save changes
        onCycleUpdate?(cycle)
    }
}

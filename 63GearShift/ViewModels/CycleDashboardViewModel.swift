//
//  CycleDashboardViewModel.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftUI
import Combine

class CycleDashboardViewModel: ObservableObject {
    @Published var cycles: [TrainingCycle] = []
    
    private let storageService = StorageService.shared
    private let achievementViewModel = AchievementViewModel()
    
    init() {
        loadCycles()
        updateAchievements()
    }
    
    func addCycle(_ cycle: TrainingCycle) {
        cycles.append(cycle)
        print("✅ Added cycle: \(cycle.goal.rawValue), isActive: \(cycle.isActive), isCompleted: \(cycle.isCompleted)")
        print("   Total cycles: \(cycles.count), Active: \(activeCycles.count), Upcoming: \(upcomingCycles.count)")
        saveCycles()
    }
    
    func updateCycle(_ cycle: TrainingCycle) {
        if let index = cycles.firstIndex(where: { $0.id == cycle.id }) {
            cycles[index] = cycle
            saveCycles()
            updateAchievements()
        }
    }
    
    func deleteCycle(_ cycle: TrainingCycle) {
        cycles.removeAll { $0.id == cycle.id }
        saveCycles()
        updateAchievements()
    }
    
    private func updateAchievements() {
        achievementViewModel.updateStats(cycles: cycles)
    }
    
    var activeCycles: [TrainingCycle] {
        cycles.filter { $0.isActive }
    }
    
    var activeCycle: TrainingCycle? {
        activeCycles.first
    }
    
    var completedCycles: [TrainingCycle] {
        cycles.filter { $0.isCompleted }
    }
    
    var upcomingCycles: [TrainingCycle] {
        cycles.filter { $0.isUpcoming }
    }
    
    private func loadCycles() {
        let savedCycles = storageService.loadCycles()
        
        if savedCycles.isEmpty {
            // Create sample data only if no saved data exists
            createSampleCycle()
        } else {
            cycles = savedCycles
        }
    }
    
    private func saveCycles() {
        storageService.saveCycles(cycles)
    }
    
    private func createSampleCycle() {
        let sampleCycle = TrainingCycle(
            goal: .strength,
            duration: .six,
            startDate: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date()) ?? Date(),
            aggressiveness: .moderate,
            initialFreshness: 0.6
        )
        var cycle = sampleCycle
        cycle.weeks = WaveCalculator.generateWave(
            duration: cycle.duration,
            initialFreshness: cycle.initialFreshness,
            aggressiveness: cycle.aggressiveness,
            goal: cycle.goal
        )
        cycles.append(cycle)
        saveCycles()
    }
}

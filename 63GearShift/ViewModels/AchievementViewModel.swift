//
//  AchievementViewModel.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftUI
import Combine

class AchievementViewModel: ObservableObject {
    @Published var userStats: UserStats
    private let storageService = StorageService.shared
    
    init() {
        userStats = UserStats()
        userStats.achievements = Achievement.defaultAchievements
        loadStats()
    }
    
    func updateStats(cycles: [TrainingCycle]) {
        // Calculate total volume from all cycles
        userStats.totalVolume = cycles.flatMap { $0.weeks }
            .compactMap { $0.totalVolume }
            .reduce(0, +)
        
        // Calculate total training days
        userStats.totalTrainingDays = cycles.flatMap { $0.weeks }
            .compactMap { $0.trainingDays }
            .reduce(0, +)
        
        // Check achievements
        userStats.checkAchievements(cycles: cycles)
        
        saveStats()
    }
    
    func updateStreak(completedWeek: Bool) {
        userStats.updateStreak(completedWeek: completedWeek)
        saveStats()
    }
    
    var unlockedAchievements: [Achievement] {
        userStats.achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        userStats.achievements.filter { !$0.isUnlocked }
    }
    
    var recentAchievements: [Achievement] {
        unlockedAchievements
            .sorted { ($0.unlockedAt ?? Date.distantPast) > ($1.unlockedAt ?? Date.distantPast) }
            .prefix(5)
            .map { $0 }
    }
    
    private func loadStats() {
        if let data = UserDefaults.standard.data(forKey: "userStats"),
           let decoded = try? JSONDecoder().decode(UserStats.self, from: data) {
            userStats = decoded
            // Ensure all default achievements exist
            let existingIds = Set(userStats.achievements.map { $0.id })
            let defaultAchievements = Achievement.defaultAchievements.filter { !existingIds.contains($0.id) }
            userStats.achievements.append(contentsOf: defaultAchievements)
        }
    }
    
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(userStats) {
            UserDefaults.standard.set(encoded, forKey: "userStats")
        }
    }
}

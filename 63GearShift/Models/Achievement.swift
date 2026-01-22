//
//  Achievement.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: UUID
    let type: AchievementType
    let title: String
    let description: String
    let iconName: String
    var unlockedAt: Date?
    var progress: Double // 0.0 to 1.0
    
    enum AchievementType: String, Codable {
        case cycleCompletion = "Cycle Completion"
        case consistency = "Consistency"
        case volume = "Volume"
        case streak = "Streak"
        case milestone = "Milestone"
    }
    
    init(
        id: UUID = UUID(),
        type: AchievementType,
        title: String,
        description: String,
        iconName: String,
        unlockedAt: Date? = nil,
        progress: Double = 0.0
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.iconName = iconName
        self.unlockedAt = unlockedAt
        self.progress = min(max(progress, 0.0), 1.0)
    }
    
    var isUnlocked: Bool {
        unlockedAt != nil
    }
}

struct UserStats: Codable {
    var totalCyclesCompleted: Int = 0
    var totalWeeksCompleted: Int = 0
    var currentStreak: Int = 0 // Consecutive weeks with completion
    var longestStreak: Int = 0
    var totalVolume: Double = 0 // Total kg lifted
    var totalTrainingDays: Int = 0
    var achievements: [Achievement] = []
    var lastActivityDate: Date?
    
    mutating func updateStreak(completedWeek: Bool) {
        if completedWeek {
            if let lastDate = lastActivityDate,
               Calendar.current.isDate(lastDate, inSameDayAs: Date()) {
                // Already logged today
                return
            }
            
            if let lastDate = lastActivityDate,
               Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day == 1 {
                // Consecutive day
                currentStreak += 1
            } else if lastActivityDate == nil {
                // First activity
                currentStreak = 1
            } else {
                // Streak broken
                currentStreak = 1
            }
            
            longestStreak = max(longestStreak, currentStreak)
            lastActivityDate = Date()
        }
    }
    
    mutating func checkAchievements(cycles: [TrainingCycle]) {
        // Cycle completion achievements
        totalCyclesCompleted = cycles.filter { $0.isCompleted }.count
        totalWeeksCompleted = cycles.flatMap { $0.weeks }.filter { $0.isCompleted }.count
        
        // Update achievement progress
        for (index, achievement) in achievements.enumerated() {
            var updatedAchievement = achievement
            var shouldUnlock = false
            
            switch achievement.type {
            case .cycleCompletion:
                if achievement.title == "First Cycle" && totalCyclesCompleted >= 1 && !achievement.isUnlocked {
                    shouldUnlock = true
                } else if achievement.title == "5 Cycles" && totalCyclesCompleted >= 5 && !achievement.isUnlocked {
                    shouldUnlock = true
                } else if achievement.title == "10 Cycles" && totalCyclesCompleted >= 10 && !achievement.isUnlocked {
                    shouldUnlock = true
                }
                updatedAchievement.progress = min(Double(totalCyclesCompleted) / 10.0, 1.0)
                
            case .consistency:
                if achievement.title == "Week Warrior" && currentStreak >= 4 && !achievement.isUnlocked {
                    shouldUnlock = true
                } else if achievement.title == "Month Master" && currentStreak >= 12 && !achievement.isUnlocked {
                    shouldUnlock = true
                }
                updatedAchievement.progress = min(Double(currentStreak) / 12.0, 1.0)
                
            case .streak:
                if achievement.title == "3 Day Streak" && currentStreak >= 3 && !achievement.isUnlocked {
                    shouldUnlock = true
                } else if achievement.title == "Week Streak" && currentStreak >= 7 && !achievement.isUnlocked {
                    shouldUnlock = true
                }
                updatedAchievement.progress = min(Double(currentStreak) / 7.0, 1.0)
                
            case .volume:
                if achievement.title == "1 Ton" && totalVolume >= 1000 && !achievement.isUnlocked {
                    shouldUnlock = true
                } else if achievement.title == "5 Tons" && totalVolume >= 5000 && !achievement.isUnlocked {
                    shouldUnlock = true
                }
                updatedAchievement.progress = min(totalVolume / 5000.0, 1.0)
                
            case .milestone:
                if achievement.title == "50 Weeks" && totalWeeksCompleted >= 50 && !achievement.isUnlocked {
                    shouldUnlock = true
                }
                updatedAchievement.progress = min(Double(totalWeeksCompleted) / 50.0, 1.0)
            }
            
            if shouldUnlock {
                updatedAchievement.unlockedAt = Date()
            }
            
            achievements[index] = updatedAchievement
        }
    }
}

// Default achievements
extension Achievement {
    static let defaultAchievements: [Achievement] = [
        // Cycle Completion
        Achievement(
            type: .cycleCompletion,
            title: "First Cycle",
            description: "Complete your first training cycle",
            iconName: "star.fill"
        ),
        Achievement(
            type: .cycleCompletion,
            title: "5 Cycles",
            description: "Complete 5 training cycles",
            iconName: "star.circle.fill"
        ),
        Achievement(
            type: .cycleCompletion,
            title: "10 Cycles",
            description: "Complete 10 training cycles",
            iconName: "star.circle"
        ),
        
        // Consistency
        Achievement(
            type: .consistency,
            title: "Week Warrior",
            description: "Complete 4 consecutive weeks",
            iconName: "flame.fill"
        ),
        Achievement(
            type: .consistency,
            title: "Month Master",
            description: "Complete 12 consecutive weeks",
            iconName: "flame.circle.fill"
        ),
        
        // Streak
        Achievement(
            type: .streak,
            title: "3 Day Streak",
            description: "Log training for 3 consecutive days",
            iconName: "bolt.fill"
        ),
        Achievement(
            type: .streak,
            title: "Week Streak",
            description: "Log training for 7 consecutive days",
            iconName: "bolt.circle.fill"
        ),
        
        // Volume
        Achievement(
            type: .volume,
            title: "1 Ton",
            description: "Lift 1,000 kg total volume",
            iconName: "dumbbell.fill"
        ),
        Achievement(
            type: .volume,
            title: "5 Tons",
            description: "Lift 5,000 kg total volume",
            iconName: "dumbbell"
        ),
        
        // Milestone
        Achievement(
            type: .milestone,
            title: "50 Weeks",
            description: "Complete 50 training weeks",
            iconName: "trophy.fill"
        ),
    ]
}

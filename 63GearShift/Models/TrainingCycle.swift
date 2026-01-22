//
//  TrainingCycle.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation

struct TrainingCycle: Identifiable, Codable {
    let id: UUID
    var goal: CycleGoal
    var duration: CycleDuration
    var startDate: Date
    var aggressiveness: Aggressiveness
    var initialFreshness: Double // 0.0 (exhausted) to 1.0 (fully fresh)
    var weeks: [CycleWeek]
    var peakFormDate: Date? // Optional target date for peak form
    
    var isActive: Bool {
        let endDate = Calendar.current.date(byAdding: .weekOfYear, value: duration.rawValue, to: startDate) ?? startDate
        let now = Date()
        // Cycle is active if current date is between start and end (inclusive)
        return now >= startDate && now <= endDate
    }
    
    var isCompleted: Bool {
        let endDate = Calendar.current.date(byAdding: .weekOfYear, value: duration.rawValue, to: startDate) ?? startDate
        return Date() > endDate
    }
    
    var isUpcoming: Bool {
        return Date() < startDate
    }
    
    var currentWeek: Int? {
        guard isActive else { return nil }
        let weeksSinceStart = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: Date()).weekOfYear ?? 0
        return min(weeksSinceStart + 1, duration.rawValue)
    }
    
    init(
        id: UUID = UUID(),
        goal: CycleGoal,
        duration: CycleDuration,
        startDate: Date = Date(),
        aggressiveness: Aggressiveness = .moderate,
        initialFreshness: Double = 0.5,
        peakFormDate: Date? = nil
    ) {
        self.id = id
        self.goal = goal
        self.duration = duration
        self.startDate = startDate
        self.aggressiveness = aggressiveness
        self.initialFreshness = initialFreshness
        self.peakFormDate = peakFormDate
        self.weeks = []
    }
}

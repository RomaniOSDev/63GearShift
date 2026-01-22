//
//  TrainingSession.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation

struct TrainingSession: Identifiable, Codable {
    let id: UUID
    var exercise: Exercise
    var sets: [WorkoutSet]
    var targetVolume: Double? // Target volume in kg
    var targetIntensity: Double? // Target intensity as % of 1RM
    var notes: String?
    
    struct WorkoutSet: Codable {
        var reps: Int
        var weight: Double? // Weight in kg
        var rpe: Int? // Rate of Perceived Exertion (1-10)
        var intensity: Double? // % of 1RM
        var restTime: Int? // Rest time in seconds
        var completed: Bool = false
        
        var volume: Double {
            guard let weight = weight else { return 0 }
            return Double(reps) * weight
        }
    }
    
    init(
        id: UUID = UUID(),
        exercise: Exercise,
        sets: [WorkoutSet] = [],
        targetVolume: Double? = nil,
        targetIntensity: Double? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.targetVolume = targetVolume
        self.targetIntensity = targetIntensity
        self.notes = notes
    }
    
    var totalVolume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }
    
    var averageRPE: Double? {
        let rpeValues = sets.compactMap { $0.rpe }
        guard !rpeValues.isEmpty else { return nil }
        return Double(rpeValues.reduce(0, +)) / Double(rpeValues.count)
    }
    
    var averageIntensity: Double? {
        let intensityValues = sets.compactMap { $0.intensity }
        guard !intensityValues.isEmpty else { return nil }
        return intensityValues.reduce(0, +) / Double(intensityValues.count)
    }
    
    var completionRate: Double {
        guard !sets.isEmpty else { return 0 }
        let completed = sets.filter { $0.completed }.count
        return Double(completed) / Double(sets.count)
    }
}

struct DayPlan: Identifiable, Codable {
    let id: UUID
    let dayOfWeek: Int // 1-7 (Monday-Sunday)
    var sessions: [TrainingSession]
    var isRestDay: Bool
    var notes: String?
    
    init(
        id: UUID = UUID(),
        dayOfWeek: Int,
        sessions: [TrainingSession] = [],
        isRestDay: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.dayOfWeek = dayOfWeek
        self.sessions = sessions
        self.isRestDay = isRestDay
        self.notes = notes
    }
    
    var totalVolume: Double {
        sessions.reduce(0) { $0 + $1.totalVolume }
    }
    
    var averageRPE: Double? {
        let rpeValues = sessions.compactMap { $0.averageRPE }
        guard !rpeValues.isEmpty else { return nil }
        return rpeValues.reduce(0, +) / Double(rpeValues.count)
    }
}

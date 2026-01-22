//
//  CycleWeek.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation

struct CycleWeek: Identifiable, Codable {
    let id: UUID
    let weekNumber: Int
    var targetFatigue: Double // Planned fatigue level
    var actualFatigue: Double? // Actual fatigue level after completion
    var planCompletion: Double? // Percentage of plan completed (0-100)
    var wellbeing: Int? // Self-reported wellbeing (1-5)
    var phase: WeekPhase
    
    // Personal metrics
    var averageRPE: Double? // Average RPE for the week (1-10)
    var totalVolume: Double? // Total training volume in kg
    var averageIntensity: Double? // Average intensity as % of 1RM
    var trainingDays: Int? // Number of training days completed
    
    // Detailed planning
    var dayPlans: [DayPlan] // Training plan for each day of the week
    
    enum WeekPhase: String, Codable {
        case loading = "Loading"
        case deload = "Deload"
    }
    
    init(
        id: UUID = UUID(),
        weekNumber: Int,
        targetFatigue: Double,
        phase: WeekPhase,
        dayPlans: [DayPlan] = []
    ) {
        self.id = id
        self.weekNumber = weekNumber
        self.targetFatigue = targetFatigue
        self.phase = phase
        self.actualFatigue = nil
        self.planCompletion = nil
        self.wellbeing = nil
        self.averageRPE = nil
        self.totalVolume = nil
        self.averageIntensity = nil
        self.trainingDays = nil
        self.dayPlans = dayPlans
    }
    
    var isCompleted: Bool {
        actualFatigue != nil && planCompletion != nil && wellbeing != nil
    }
    
    // Calculate metrics from day plans
    mutating func calculateMetrics() {
        let completedDays = dayPlans.filter { day in
            day.sessions.contains { session in
                session.sets.contains { $0.completed }
            }
        }
        
        trainingDays = completedDays.count
        
        let allSessions = dayPlans.flatMap { $0.sessions }
        let completedSessions = allSessions.filter { session in
            session.sets.contains { $0.completed }
        }
        
        if !completedSessions.isEmpty {
            totalVolume = completedSessions.reduce(0) { $0 + $1.totalVolume }
            
            let rpeValues = completedSessions.compactMap { $0.averageRPE }
            if !rpeValues.isEmpty {
                averageRPE = rpeValues.reduce(0, +) / Double(rpeValues.count)
            }
            
            let intensityValues = completedSessions.compactMap { $0.averageIntensity }
            if !intensityValues.isEmpty {
                averageIntensity = intensityValues.reduce(0, +) / Double(intensityValues.count)
            }
        }
    }
}

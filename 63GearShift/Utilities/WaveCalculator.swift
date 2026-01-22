//
//  WaveCalculator.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation

struct WaveCalculator {
    // Wave pattern templates for different goals
    enum WavePattern {
        case strength      // Slow, gradual build-up
        case mass          // Aggressive volume waves
        case endurance     // Smooth, consistent waves
        case peakForm      // Sharp peak at the end
        
        /// Generates normalized wave pattern (0.0-1.0) based on goal
        /// Returns: (normalizedFatigue: 0.0-1.0, phase: loading/deload)
        func generatePattern(
            week: Int,
            totalWeeks: Int
        ) -> (normalizedFatigue: Double, phase: CycleWeek.WeekPhase) {
            let weekProgress = Double(week) / Double(totalWeeks)
            
            switch self {
            case .strength:
                // Slow linear growth with small deloads
                // Pattern: 2 weeks load, 1 week deload
                let microCycle = (week - 1) % 3
                
                if microCycle < 2 {
                    // Loading phase - slow linear growth
                    let loadingProgress = Double(microCycle) / 2.0
                    // Slow, gradual increase over time
                    let baseLevel = 0.3 + weekProgress * 0.4 // 0.3 to 0.7 over cycle
                    let microVariation = loadingProgress * 0.15 // Small wave within microcycle
                    let normalizedFatigue = baseLevel + microVariation
                    return (normalizedFatigue, .loading)
                } else {
                    // Deload phase - gentle reduction
                    let previousBase = 0.3 + weekProgress * 0.4
                    let previousPeak = previousBase + 0.15
                    let normalizedFatigue = previousPeak * 0.75 // 25% reduction
                    return (normalizedFatigue, .deload)
                }
                
            case .mass:
                // Aggressive volume waves with bigger amplitude
                // Pattern: 3 weeks load, 1 week deload
                let microCycle = (week - 1) % 4
                
                if microCycle < 3 {
                    // Loading phase - aggressive exponential build
                    let loadingProgress = Double(microCycle) / 3.0
                    // Higher base, more aggressive curve
                    let baseLevel = 0.35 + weekProgress * 0.45 // 0.35 to 0.8 over cycle
                    // Exponential-like curve for aggressive build
                    let curve = pow(loadingProgress, 0.6) // Steeper curve
                    let microVariation = curve * 0.25 // Bigger wave
                    let normalizedFatigue = baseLevel + microVariation
                    return (normalizedFatigue, .loading)
                } else {
                    // Deload phase - significant reduction
                    let previousBase = 0.35 + weekProgress * 0.45
                    let previousPeak = previousBase + 0.25
                    let normalizedFatigue = previousPeak * 0.65 // 35% reduction
                    return (normalizedFatigue, .deload)
                }
                
            case .endurance:
                // Smooth, consistent waves with smaller amplitude
                // Pattern: 2 weeks load, 1 week deload, but smoother transitions
                let microCycle = (week - 1) % 3
                
                if microCycle < 2 {
                    // Loading phase - smooth sine-like growth
                    let loadingProgress = Double(microCycle) / 2.0
                    // Moderate base level
                    let baseLevel = 0.25 + weekProgress * 0.35 // 0.25 to 0.6 over cycle
                    // Smooth sine curve
                    let smoothProgress = sin(loadingProgress * .pi / 2)
                    let microVariation = smoothProgress * 0.12 // Smaller, smoother wave
                    let normalizedFatigue = baseLevel + microVariation
                    return (normalizedFatigue, .loading)
                } else {
                    // Deload phase - gentle reduction
                    let previousBase = 0.25 + weekProgress * 0.35
                    let previousPeak = previousBase + 0.12
                    let normalizedFatigue = previousPeak * 0.80 // 20% reduction (gentler)
                    return (normalizedFatigue, .deload)
                }
                
            case .peakForm:
                // Sharp peak at the end, building gradually
                // Pattern: Progressive build with sharp peak in last 2-3 weeks
                if week <= totalWeeks - 2 {
                    // Building phase - gradual exponential increase
                    let buildProgress = Double(week) / Double(totalWeeks - 2)
                    // Slow start, accelerating towards end
                    let curve = pow(buildProgress, 1.8) // Exponential acceleration
                    let normalizedFatigue = 0.2 + curve * 0.6 // 0.2 to 0.8
                    return (normalizedFatigue, .loading)
                } else if week == totalWeeks - 1 {
                    // Peak week - maximum
                    let normalizedFatigue = 0.95
                    return (normalizedFatigue, .loading)
                } else {
                    // Final week - slight deload or maintain
                    let normalizedFatigue = 0.90
                    return (normalizedFatigue, .deload)
                }
            }
        }
    }
    
    static func generateWave(
        duration: CycleDuration,
        initialFreshness: Double,
        aggressiveness: Aggressiveness,
        goal: CycleGoal
    ) -> [CycleWeek] {
        let weeks = duration.rawValue
        var cycleWeeks: [CycleWeek] = []
        
        // Select wave pattern based on goal
        let pattern: WavePattern
        switch goal {
        case .strength:
            pattern = .strength
        case .mass:
            pattern = .mass
        case .endurance:
            pattern = .endurance
        case .peakForm:
            pattern = .peakForm
        }
        
        // Aggressiveness multiplier affects amplitude
        let aggressivenessMultiplier = aggressiveness.riskMultiplier
        
        // Base fatigue from initial freshness (starting point)
        let baseFatigue = (1.0 - initialFreshness) * 0.2
        
        // Generate weeks using selected pattern
        for week in 1...weeks {
            let (normalizedFatigue, phase) = pattern.generatePattern(
                week: week,
                totalWeeks: weeks
            )
            
            // Apply aggressiveness to amplitude
            // Normalized fatigue (0-1) is scaled by aggressiveness
            // Conservative: 0.7x amplitude, Moderate: 1.0x, Aggressive: 1.3x
            let amplitude = normalizedFatigue * aggressivenessMultiplier
            
            // Map to actual fatigue range
            // Base fatigue + scaled amplitude, capped at reasonable max
            let maxFatigue = 0.95
            let availableRange = maxFatigue - baseFatigue
            let targetFatigue = baseFatigue + (amplitude * availableRange)
            
            let cycleWeek = CycleWeek(
                weekNumber: week,
                targetFatigue: min(max(targetFatigue, 0.0), 1.0),
                phase: phase
            )
            cycleWeeks.append(cycleWeek)
        }
        
        return cycleWeeks
    }
    
    static func calculateRecommendation(
        currentWeek: CycleWeek,
        previousWeek: CycleWeek?,
        planCompletion: Double?,
        wellbeing: Int?
    ) -> String {
        guard let completion = planCompletion, let wellbeing = wellbeing else {
            return "Complete this week to get recommendations"
        }
        
        let isLowCompletion = completion < 0.8
        let isLowWellbeing = wellbeing <= 2
        
        if isLowCompletion && isLowWellbeing {
            return "Wave is close to breaking. Consider reducing load by 10%."
        } else if isLowWellbeing {
            return "Monitor recovery. Consider a lighter week next."
        } else if completion >= 0.95 && wellbeing >= 4 {
            return "Excellent progress. Maintain current intensity."
        } else if currentWeek.phase == .loading {
            return "Week \(currentWeek.weekNumber): PEAK LOAD. Complete 95-100% of plan."
        } else {
            return "Week \(currentWeek.weekNumber): DELOAD. Focus on recovery."
        }
    }
    
    static func adjustNextWeek(
        currentWeek: CycleWeek,
        planCompletion: Double?,
        wellbeing: Int?,
        originalTarget: Double
    ) -> Double {
        guard let completion = planCompletion, let wellbeing = wellbeing else {
            return originalTarget
        }
        
        let adjustmentFactor: Double
        if completion < 0.7 || wellbeing <= 2 {
            adjustmentFactor = 0.9 // Reduce by 10%
        } else if completion >= 0.95 && wellbeing >= 4 {
            adjustmentFactor = 1.05 // Increase by 5%
        } else {
            adjustmentFactor = 1.0 // No change
        }
        
        return min(max(originalTarget * adjustmentFactor, 0.0), 1.0)
    }
}

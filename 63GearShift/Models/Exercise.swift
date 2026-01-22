//
//  Exercise.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation

struct Exercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var muscleGroup: MuscleGroup
    var exerciseType: ExerciseType
    
    enum MuscleGroup: String, Codable, CaseIterable {
        case chest = "Chest"
        case back = "Back"
        case shoulders = "Shoulders"
        case legs = "Legs"
        case arms = "Arms"
        case core = "Core"
        case fullBody = "Full Body"
    }
    
    enum ExerciseType: String, Codable, CaseIterable {
        case compound = "Compound"
        case isolation = "Isolation"
        case cardio = "Cardio"
        case mobility = "Mobility"
    }
    
    init(id: UUID = UUID(), name: String, muscleGroup: MuscleGroup, exerciseType: ExerciseType) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.exerciseType = exerciseType
    }
}

// Default exercises library
extension Exercise {
    static let defaultExercises: [Exercise] = [
        // Chest
        Exercise(name: "Bench Press", muscleGroup: .chest, exerciseType: .compound),
        Exercise(name: "Incline Dumbbell Press", muscleGroup: .chest, exerciseType: .compound),
        Exercise(name: "Chest Flyes", muscleGroup: .chest, exerciseType: .isolation),
        
        // Back
        Exercise(name: "Deadlift", muscleGroup: .back, exerciseType: .compound),
        Exercise(name: "Pull-ups", muscleGroup: .back, exerciseType: .compound),
        Exercise(name: "Barbell Row", muscleGroup: .back, exerciseType: .compound),
        Exercise(name: "Lat Pulldown", muscleGroup: .back, exerciseType: .compound),
        
        // Shoulders
        Exercise(name: "Overhead Press", muscleGroup: .shoulders, exerciseType: .compound),
        Exercise(name: "Lateral Raises", muscleGroup: .shoulders, exerciseType: .isolation),
        
        // Legs
        Exercise(name: "Squat", muscleGroup: .legs, exerciseType: .compound),
        Exercise(name: "Leg Press", muscleGroup: .legs, exerciseType: .compound),
        Exercise(name: "Romanian Deadlift", muscleGroup: .legs, exerciseType: .compound),
        Exercise(name: "Leg Curls", muscleGroup: .legs, exerciseType: .isolation),
        
        // Arms
        Exercise(name: "Bicep Curls", muscleGroup: .arms, exerciseType: .isolation),
        Exercise(name: "Tricep Extensions", muscleGroup: .arms, exerciseType: .isolation),
        
        // Core
        Exercise(name: "Plank", muscleGroup: .core, exerciseType: .isolation),
        Exercise(name: "Russian Twists", muscleGroup: .core, exerciseType: .isolation),
    ]
}

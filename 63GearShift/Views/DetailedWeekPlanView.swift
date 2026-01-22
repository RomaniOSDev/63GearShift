//
//  DetailedWeekPlanView.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI

struct DetailedWeekPlanView: View {
    @Binding var week: CycleWeek
    let cycle: TrainingCycle
    @State private var selectedDay: DayPlan?
    @State private var showingSessionEditor = false
    
    var body: some View {
        ZStack {
            Color.gsBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Week metrics summary
                    WeekMetricsCard(week: week)
                    
                    // Days of week
                    ForEach(week.dayPlans.isEmpty ? defaultDayPlans : week.dayPlans) { dayPlan in
                        DayPlanCard(
                            dayPlan: dayPlan,
                            phase: week.phase,
                            onTap: {
                                selectedDay = dayPlan
                                showingSessionEditor = true
                            }
                        )
                    }
                    
                    // Add day button
                    Button(action: {
                        let newDay = DayPlan(dayOfWeek: week.dayPlans.count + 1)
                        week.dayPlans.append(newDay)
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Training Day")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gsLoading)
                        .cornerRadius(12)
                    }
                    .padding()
                }
                .padding()
            }
        }
        .navigationTitle("Week \(week.weekNumber) Plan")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedDay) { day in
            DayPlanEditorView(dayPlan: day, week: $week)
        }
    }
    
    private var defaultDayPlans: [DayPlan] {
        (1...7).map { day in
            DayPlan(dayOfWeek: day, isRestDay: day % 2 == 0)
        }
    }
}

struct WeekMetricsCard: View {
    let week: CycleWeek
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Week Metrics")
                .font(.headline)
                .foregroundColor(.gsLoading)
            
            HStack(spacing: 20) {
                if let volume = week.totalVolume {
                    MetricView(title: "Volume", value: "\(Int(volume)) kg", color: .gsLoading)
                }
                
                if let rpe = week.averageRPE {
                    MetricView(title: "Avg RPE", value: String(format: "%.1f", rpe), color: .gsDeload)
                }
                
                if let intensity = week.averageIntensity {
                    MetricView(title: "Intensity", value: "\(Int(intensity))%", color: .gsLoading)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct MetricView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
    }
}

struct DayPlanCard: View {
    let dayPlan: DayPlan
    let phase: CycleWeek.WeekPhase
    let onTap: () -> Void
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let date = Calendar.current.date(byAdding: .day, value: dayPlan.dayOfWeek - 1, to: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(dayName)
                        .font(.headline)
                        .foregroundColor(.gsLoading)
                    
                    Spacer()
                    
                    if dayPlan.isRestDay {
                        Text("Rest Day")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.gray)
                            .cornerRadius(8)
                    }
                }
                
                if !dayPlan.isRestDay {
                    if dayPlan.sessions.isEmpty {
                        Text("Tap to add exercises")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(dayPlan.sessions) { session in
                            HStack {
                                Text(session.exercise.name)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(session.sets.count) sets")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if dayPlan.totalVolume > 0 {
                            Text("Total Volume: \(Int(dayPlan.totalVolume)) kg")
                                .font(.caption)
                                .foregroundColor(.gsLoading)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DayPlanEditorView: View {
    @State var dayPlan: DayPlan
    @Binding var week: CycleWeek
    @Environment(\.dismiss) var dismiss
    @State private var showingExercisePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Day Settings") {
                    Toggle("Rest Day", isOn: $dayPlan.isRestDay)
                }
                
                if !dayPlan.isRestDay {
                    Section("Training Sessions") {
                        ForEach(dayPlan.sessions) { session in
                            NavigationLink(destination: SessionEditorView(session: session, dayPlan: $dayPlan)) {
                                VStack(alignment: .leading) {
                                    Text(session.exercise.name)
                                        .font(.headline)
                                    Text("\(session.sets.count) sets")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete { indices in
                            dayPlan.sessions.remove(atOffsets: indices)
                        }
                        
                        Button("Add Exercise") {
                            showingExercisePicker = true
                        }
                    }
                }
            }
            .navigationTitle("Day \(dayPlan.dayOfWeek)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let index = week.dayPlans.firstIndex(where: { $0.id == dayPlan.id }) {
                            week.dayPlans[index] = dayPlan
                            week.calculateMetrics()
                        }
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView { exercise in
                    let newSession = TrainingSession(exercise: exercise)
                    dayPlan.sessions.append(newSession)
                    showingExercisePicker = false
                }
            }
        }
    }
}

struct ExercisePickerView: View {
    let onSelect: (Exercise) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(Exercise.defaultExercises) { exercise in
                Button(action: {
                    onSelect(exercise)
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.headline)
                            Text("\(exercise.muscleGroup.rawValue) • \(exercise.exerciseType.rawValue)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SessionEditorView: View {
    @State var session: TrainingSession
    @Binding var dayPlan: DayPlan
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section("Exercise") {
                Text(session.exercise.name)
            }
            
            Section("Sets") {
                ForEach(session.sets.indices, id: \.self) { index in
                    SetRowView(set: $session.sets[index], setNumber: index + 1)
                }
                
                Button("Add Set") {
                    session.sets.append(TrainingSession.WorkoutSet(reps: 10, weight: nil, rpe: nil))
                }
            }
            
            Section("Targets") {
                HStack {
                    Text("Target Volume (kg)")
                    Spacer()
                    TextField("Volume", value: $session.targetVolume, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Target Intensity (%)")
                    Spacer()
                    TextField("Intensity", value: $session.targetIntensity, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .navigationTitle("Edit Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    if let index = dayPlan.sessions.firstIndex(where: { $0.id == session.id }) {
                        dayPlan.sessions[index] = session
                    }
                    dismiss()
                }
            }
        }
    }
}

struct SetRowView: View {
    @Binding var set: TrainingSession.WorkoutSet
    let setNumber: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Set \(setNumber)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Toggle("", isOn: $set.completed)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Reps")
                        .font(.caption)
                    TextField("Reps", value: $set.reps, format: .number)
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading) {
                    Text("Weight (kg)")
                        .font(.caption)
                    TextField("Weight", value: $set.weight, format: .number)
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading) {
                    Text("RPE")
                        .font(.caption)
                    TextField("RPE", value: $set.rpe, format: .number)
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading) {
                    Text("Intensity %")
                        .font(.caption)
                    TextField("%", value: $set.intensity, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

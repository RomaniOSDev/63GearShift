//
//  WeekPlanView.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import EventKit

struct WeekPlanView: View {
    let week: CycleWeek
    let cycle: TrainingCycle
    @State private var showingCalendarExport = false
    
    var body: some View {
        ZStack {
            Color.gsBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Week header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Week \(week.weekNumber)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.gsLoading)
                        
                        Text(week.phase.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Target Fatigue: \(Int(week.targetFatigue * 100))%")
                            .font(.caption)
                            .foregroundColor(week.phase == .loading ? .gsLoading : .gsDeload)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Training days
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Training Schedule")
                            .font(.headline)
                            .foregroundColor(.gsLoading)
                        
                        ForEach(1...7, id: \.self) { day in
                            TrainingDayCard(dayNumber: day, phase: week.phase)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Export button
                    Button(action: {
                        showingCalendarExport = true
                    }) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Export to Calendar")
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
        .navigationTitle("Week Plan")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCalendarExport) {
            CalendarExportView(week: week, cycle: cycle)
        }
    }
}

struct TrainingDayCard: View {
    let dayNumber: Int
    let phase: CycleWeek.WeekPhase
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let date = Calendar.current.date(byAdding: .day, value: dayNumber - 1, to: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(dayNumber == 1 || dayNumber == 3 || dayNumber == 5 ? "Training" : "Rest")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if dayNumber == 1 || dayNumber == 3 || dayNumber == 5 {
                Text(phase == .loading ? "High Intensity" : "Recovery")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        phase == .loading 
                            ? Color.gsLoading.opacity(0.2)
                            : Color.gsDeload.opacity(0.2)
                    )
                    .foregroundColor(
                        phase == .loading 
                            ? Color.gsLoading
                            : Color.gsDeload
                    )
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gsBackground)
        .cornerRadius(8)
    }
}

struct CalendarExportView: View {
    let week: CycleWeek
    let cycle: TrainingCycle
    @Environment(\.dismiss) var dismiss
    @State private var eventStore = EKEventStore()
    @State private var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if authorizationStatus == .authorized {
                    Text("Training sessions will be added to your calendar")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Export") {
                        exportToCalendar()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gsLoading)
                    .cornerRadius(12)
                    .padding()
                } else {
                    Text("Calendar access is required to export training sessions")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Request Access") {
                        requestCalendarAccess()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gsLoading)
                    .cornerRadius(12)
                    .padding()
                }
            }
            .navigationTitle("Export to Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                checkAuthorizationStatus()
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    private func requestCalendarAccess() {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                authorizationStatus = granted ? .authorized : .denied
            }
        }
    }
    
    private func exportToCalendar() {
        // TODO: Implement actual calendar export
        // Create events for training days
    }
}

#Preview {
    NavigationView {
        WeekPlanView(
            week: CycleWeek(weekNumber: 1, targetFatigue: 0.6, phase: .loading),
            cycle: TrainingCycle(goal: .strength, duration: .six)
        )
    }
}

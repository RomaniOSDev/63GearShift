//
//  ActiveCycleView.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import Charts

struct ActiveCycleView: View {
    @StateObject var viewModel: ActiveCycleViewModel
    @State private var selectedWeek: CycleWeek?
    
    var body: some View {
        ZStack {
            Color.gsBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Cycle info header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.cycle.goal.rawValue)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.gsLoading)
                        
                        HStack {
                            Text("Week \(viewModel.cycle.currentWeek ?? 0) of \(viewModel.cycle.duration.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(viewModel.cycle.aggressiveness.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gsLoading.opacity(0.2))
                                .foregroundColor(.gsLoading)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Main wave chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Form-Fatigue Wave")
                            .font(.headline)
                            .foregroundColor(.gsLoading)
                        
                        WaveChartView(
                            weeks: viewModel.cycle.weeks,
                            currentWeekIndex: viewModel.currentWeekIndex
                        )
                        .frame(height: 300)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Recommendation card
                    RecommendationCardView(text: viewModel.recommendation)
                    
                    // Personal metrics card
                    if let currentWeek = viewModel.currentWeek,
                       currentWeek.totalVolume != nil || currentWeek.averageRPE != nil {
                        PersonalMetricsCard(week: currentWeek)
                    }
                    
                    // Current week details
                    if let currentWeek = viewModel.currentWeek {
                        CurrentWeekCardView(
                            week: currentWeek,
                            onUpdate: {
                                selectedWeek = currentWeek
                            },
                            onViewPlan: {
                                // Navigate to detailed week plan
                            }
                        )
                    }
                    
                    // Week list
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All Weeks")
                            .font(.headline)
                            .foregroundColor(.gsLoading)
                        
                        ForEach(Array(viewModel.cycle.weeks.enumerated()), id: \.element.id) { index, week in
                            WeekRowView(week: week, isCurrent: index == viewModel.currentWeekIndex)
                                .onTapGesture {
                                    if week.isCompleted || index == viewModel.currentWeekIndex {
                                        selectedWeek = week
                                    }
                                }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle("Active Cycle")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedWeek) { week in
            if let weekIndex = viewModel.cycle.weeks.firstIndex(where: { $0.id == week.id }) {
                WeekInputView(
                    week: week,
                    onSave: { completion, wellbeing in
                        viewModel.updateWeek(
                            weekIndex: weekIndex,
                            planCompletion: completion,
                            wellbeing: wellbeing
                        )
                        selectedWeek = nil
                    }
                )
            }
        }
    }
}

struct WaveChartView: View {
    let weeks: [CycleWeek]
    let currentWeekIndex: Int?
    
    var body: some View {
        Chart {
            // Base recovery line (RuleMark at y=0)
            RuleMark(y: .value("Recovery", 0.0))
                .foregroundStyle(Color.gsBackground)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .trailing, alignment: .trailing) {
                    Text("Recovery")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            
            // Target wave (plan) - AreaMark with gradient
            ForEach(weeks) { week in
                AreaMark(
                    x: .value("Week", week.weekNumber),
                    yStart: .value("Fatigue", 0),
                    yEnd: .value("Fatigue", week.targetFatigue)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.gsLoading.opacity(0.4),
                            Color.gsDeload.opacity(0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            
            // Target wave line (plan outline)
            ForEach(weeks) { week in
                LineMark(
                    x: .value("Week", week.weekNumber),
                    y: .value("Fatigue", week.targetFatigue)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.gsLoading, Color.gsDeload],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .interpolationMethod(.catmullRom)
            }
            
            // Actual wave (reality) - bold LineMark
            ForEach(weeks.filter { $0.actualFatigue != nil }) { week in
                LineMark(
                    x: .value("Week", week.weekNumber),
                    y: .value("Fatigue", week.actualFatigue ?? 0)
                )
                .foregroundStyle(Color.gsDeload)
                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
                .symbol {
                    Circle()
                        .fill(Color.gsDeload)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            
            // Current week indicator (RuleMark)
            if let currentIndex = currentWeekIndex, currentIndex < weeks.count {
                RuleMark(x: .value("Week", weeks[currentIndex].weekNumber))
                    .foregroundStyle(Color.gsLoading)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .annotation(position: .top, alignment: .center) {
                        VStack(spacing: 4) {
                            Text("Week \(weeks[currentIndex].weekNumber)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gsLoading)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
            }
        }
        .chartYScale(domain: 0...1)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: weeks.count)) { value in
                AxisGridLine()
                    .foregroundStyle(Color.gray.opacity(0.2))
                AxisTick()
                    .foregroundStyle(Color.gray.opacity(0.5))
                AxisValueLabel {
                    if let weekNumber = value.as(Int.self) {
                        Text("\(weekNumber)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(Color.gray.opacity(0.2))
                AxisTick()
                    .foregroundStyle(Color.gray.opacity(0.5))
                AxisValueLabel {
                    if let fatigue = value.as(Double.self) {
                        Text("\(Int(fatigue * 100))%")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.gsBackground.opacity(0.3))
                .cornerRadius(8)
        }
    }
}

struct RecommendationCardView: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.gsLoading)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gsLoading)
            Spacer()
        }
        .padding()
        .background(Color.gsLoading.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gsLoading.opacity(0.3), lineWidth: 1)
        )
    }
}

struct PersonalMetricsCard: View {
    let week: CycleWeek
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Metrics")
                .font(.headline)
                .foregroundColor(.gsLoading)
            
            HStack(spacing: 20) {
                if let volume = week.totalVolume {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Volume")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(Int(volume)) kg")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.gsLoading)
                    }
                }
                
                if let rpe = week.averageRPE {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Avg RPE")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f", rpe))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.gsDeload)
                    }
                }
                
                if let intensity = week.averageIntensity {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Intensity")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(Int(intensity))%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.gsLoading)
                    }
                }
                
                if let days = week.trainingDays {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Training Days")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(days)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.gsDeload)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct CurrentWeekCardView: View {
    let week: CycleWeek
    let onUpdate: () -> Void
    var onViewPlan: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Week \(week.weekNumber)")
                    .font(.headline)
                    .foregroundColor(.gsLoading)
                
                Spacer()
                
                Text(week.phase.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        week.phase == .loading 
                            ? Color.gsLoading.opacity(0.2)
                            : Color.gsDeload.opacity(0.2)
                    )
                    .foregroundColor(
                        week.phase == .loading 
                            ? Color.gsLoading
                            : Color.gsDeload
                    )
                    .cornerRadius(8)
            }
            
            if week.isCompleted {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Completion")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(Int(week.planCompletion ?? 0))%")
                            .font(.headline)
                            .foregroundColor(.gsLoading)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Wellbeing")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(week.wellbeing ?? 0)/5")
                            .font(.headline)
                            .foregroundColor(.gsDeload)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    if !week.dayPlans.isEmpty {
                        NavigationLink(destination: DetailedWeekPlanView(week: Binding(
                            get: { week },
                            set: { _ in }
                        ), cycle: TrainingCycle(goal: .strength, duration: .six))) {
                            HStack {
                                Text("View Training Plan")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "list.bullet")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gsDeload)
                            .cornerRadius(8)
                        }
                    }
                    
                    Button(action: onUpdate) {
                        HStack {
                            Text("Log Week Progress")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gsLoading)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct WeekRowView: View {
    let week: CycleWeek
    let isCurrent: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Week \(week.weekNumber)")
                    .font(.subheadline)
                    .fontWeight(isCurrent ? .semibold : .regular)
                    .foregroundColor(isCurrent ? .gsLoading : .primary)
                
                Text(week.phase.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if week.isCompleted {
                HStack(spacing: 16) {
                    Text("\(Int(week.planCompletion ?? 0))%")
                        .font(.caption)
                        .foregroundColor(.gsLoading)
                    Text("\(week.wellbeing ?? 0)/5")
                        .font(.caption)
                        .foregroundColor(.gsDeload)
                }
            } else if isCurrent {
                Circle()
                    .fill(Color.gsLoading)
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(isCurrent ? Color.gsLoading.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

struct WeekInputView: View {
    let week: CycleWeek
    let onSave: (Double, Int) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var completion: Double
    @State private var wellbeing: Int
    
    init(week: CycleWeek, onSave: @escaping (Double, Int) -> Void) {
        self.week = week
        self.onSave = onSave
        // Initialize with existing values or defaults
        _completion = State(initialValue: week.planCompletion ?? 100)
        _wellbeing = State(initialValue: week.wellbeing ?? 3)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Plan Completion")) {
                    HStack {
                        Slider(value: $completion, in: 0...100, step: 5)
                        Text("\(Int(completion))%")
                            .frame(width: 60)
                            .foregroundColor(.gsLoading)
                    }
                }
                
                Section(header: Text("Wellbeing (1-5)")) {
                    Picker("Wellbeing", selection: $wellbeing) {
                        ForEach(1...5, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button("Save") {
                        onSave(completion, wellbeing)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gsLoading)
                    .cornerRadius(8)
                }
            }
            .navigationTitle("Week \(week.weekNumber)")
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

#Preview {
    NavigationView {
        ActiveCycleView(
            viewModel: ActiveCycleViewModel(
                cycle: {
                    var cycle = TrainingCycle(
                        goal: .strength,
                        duration: .six,
                        aggressiveness: .moderate
                    )
                    cycle.weeks = WaveCalculator.generateWave(
                        duration: .six,
                        initialFreshness: 0.5,
                        aggressiveness: .moderate,
                        goal: .strength
                    )
                    return cycle
                }()
            )
        )
    }
}

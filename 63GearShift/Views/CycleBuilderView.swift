//
//  CycleBuilderView.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import Charts

struct CycleBuilderView: View {
    @ObservedObject var viewModel: CycleBuilderViewModel
    @ObservedObject var dashboardViewModel: CycleDashboardViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gsBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Goal selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Cycle Goal")
                                .font(.headline)
                                .foregroundColor(.gsLoading)
                            
                            Picker("Goal", selection: $viewModel.selectedGoal) {
                                ForEach(CycleGoal.allCases) { goal in
                                    Text(goal.rawValue).tag(goal)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Duration selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Duration")
                                .font(.headline)
                                .foregroundColor(.gsLoading)
                            
                            Picker("Duration", selection: $viewModel.selectedDuration) {
                                ForEach(CycleDuration.allCases) { duration in
                                    Text(duration.displayName).tag(duration)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Initial freshness
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Starting Freshness")
                                .font(.headline)
                                .foregroundColor(.gsLoading)
                            
                            HStack {
                                Text("Exhausted")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("Fully Fresh")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Slider(value: $viewModel.initialFreshness, in: 0...1)
                                .tint(.gsLoading)
                            
                            Text("\(Int(viewModel.initialFreshness * 100))%")
                                .font(.subheadline)
                                .foregroundColor(.gsLoading)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Aggressiveness
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Risk Level")
                                .font(.headline)
                                .foregroundColor(.gsLoading)
                            
                            Picker("Aggressiveness", selection: $viewModel.selectedAggressiveness) {
                                ForEach(Aggressiveness.allCases) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Peak form date
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Peak Form by Date", isOn: $viewModel.hasPeakDate)
                                .font(.headline)
                                .foregroundColor(.gsLoading)
                            
                            if viewModel.hasPeakDate {
                                DatePicker(
                                    "Peak Date",
                                    selection: $viewModel.peakFormDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Wave preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Wave Preview")
                                .font(.headline)
                                .foregroundColor(.gsLoading)
                            
                            WavePreviewChart(weeks: viewModel.previewWeeks)
                                .frame(height: 200)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Cycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        let cycle = viewModel.buildCycle()
                        dashboardViewModel.addCycle(cycle)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.gsLoading)
                }
            }
        }
    }
}

struct WavePreviewChart: View {
    let weeks: [CycleWeek]
    
    var body: some View {
        Chart {
            // Base recovery line (RuleMark at y=0)
            RuleMark(y: .value("Recovery", 0.0))
                .foregroundStyle(Color.gsBackground)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            
            // Target wave (plan) - AreaMark with gradient from #4A91D6 to #153254
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
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
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

#Preview {
    CycleBuilderView(
        viewModel: CycleBuilderViewModel(),
        dashboardViewModel: CycleDashboardViewModel()
    )
}

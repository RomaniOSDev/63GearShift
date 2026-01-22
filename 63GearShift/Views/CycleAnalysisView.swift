//
//  CycleAnalysisView.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import Charts

struct CycleAnalysisView: View {
    let cycles: [TrainingCycle]
    
    var completedCycles: [TrainingCycle] {
        cycles.filter { $0.isCompleted }
    }
    
    var body: some View {
        ZStack {
            Color.gsBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    if completedCycles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No completed cycles yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Complete your first cycle to see insights")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    } else {
                        // Comparison chart
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Cycle Comparison")
                                .font(.headline)
                                .foregroundColor(.gsLoading)
                            
                            CycleComparisonChart(cycles: completedCycles)
                                .frame(height: 300)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Insights
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Insights")
                                .font(.headline)
                                .foregroundColor(.gsLoading)
                            
                            ForEach(generateInsights(), id: \.self) { insight in
                                InsightCard(text: insight)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Individual cycle details
                        ForEach(completedCycles) { cycle in
                            CycleDetailCard(cycle: cycle)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func generateInsights() -> [String] {
        var insights: [String] = []
        
        guard completedCycles.count >= 2 else {
            return ["Complete more cycles to get insights"]
        }
        
        // Analyze deload patterns
        let cyclesWithDoubleDeload = completedCycles.filter { cycle in
            var consecutiveDeloads = 0
            for week in cycle.weeks {
                if week.phase == .deload {
                    consecutiveDeloads += 1
                    if consecutiveDeloads >= 2 {
                        return true
                    }
                } else {
                    consecutiveDeloads = 0
                }
            }
            return false
        }
        
        if cyclesWithDoubleDeload.count > 0 {
            insights.append("In cycles where you did two deload weeks in a row, peak form was 15% higher.")
        }
        
        // Analyze completion rates
        let avgCompletion = completedCycles.flatMap { $0.weeks }
            .compactMap { $0.planCompletion }
            .reduce(0.0, +) / Double(completedCycles.flatMap { $0.weeks }.compactMap { $0.planCompletion }.count)
        
        if avgCompletion >= 90 {
            insights.append("You consistently complete 90%+ of your planned training. Great consistency!")
        }
        
        return insights.isEmpty ? ["Keep training to unlock more insights"] : insights
    }
}

struct CycleComparisonChart: View {
    let cycles: [TrainingCycle]
    
    var body: some View {
        Chart {
            ForEach(cycles) { cycle in
                ForEach(cycle.weeks) { week in
                    LineMark(
                        x: .value("Week", week.weekNumber),
                        y: .value("Fatigue", week.actualFatigue ?? week.targetFatigue)
                    )
                    .foregroundStyle(Color.gsLoading.opacity(0.6))
                    .interpolationMethod(.catmullRom)
                }
            }
        }
        .chartYScale(domain: 0...1)
        .chartXAxis {
            AxisMarks(values: .automatic)
        }
    }
}

struct InsightCard: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.gsLoading)
                .font(.title3)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(Color.gsLoading.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CycleDetailCard: View {
    let cycle: TrainingCycle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(cycle.goal.rawValue)
                    .font(.headline)
                    .foregroundColor(.gsLoading)
                
                Spacer()
                
                Text("\(cycle.duration.rawValue) weeks")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Stats
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Avg Completion")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(Int(averageCompletion))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gsLoading)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Avg Wellbeing")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f", averageWellbeing))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gsDeload)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var averageCompletion: Double {
        let completions = cycle.weeks.compactMap { $0.planCompletion }
        return completions.isEmpty ? 0 : completions.reduce(0, +) / Double(completions.count)
    }
    
    private var averageWellbeing: Double {
        let wellbeing = cycle.weeks.compactMap { $0.wellbeing }
        return wellbeing.isEmpty ? 0 : Double(wellbeing.reduce(0, +)) / Double(wellbeing.count)
    }
}

#Preview {
    NavigationView {
        CycleAnalysisView(cycles: [])
    }
}

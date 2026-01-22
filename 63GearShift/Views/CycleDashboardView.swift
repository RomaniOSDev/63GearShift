//
//  CycleDashboardView.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI

struct CycleDashboardView: View {
    @EnvironmentObject var viewModel: CycleDashboardViewModel
    @State private var selectedView = 0 // 0: Home, 1: All Cycles
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented control
            Picker("View", selection: $selectedView) {
                Text("Home").tag(0)
                Text("All Cycles").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            if selectedView == 0 {
                HomeView()
                    .environmentObject(viewModel)
            } else {
                AllCyclesView()
                    .environmentObject(viewModel)
            }
        }
        .navigationTitle("GearShift")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct AllCyclesView: View {
    @EnvironmentObject var viewModel: CycleDashboardViewModel
    @State private var showingBuilder = false
    
    var body: some View {
        ZStack {
            Color.gsBackground
                .ignoresSafeArea()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    // Active cycles
                    ForEach(viewModel.activeCycles) { cycle in
                        NavigationLink(destination: ActiveCycleView(
                            viewModel: ActiveCycleViewModel(
                                cycle: cycle,
                                onCycleUpdate: { updatedCycle in
                                    viewModel.updateCycle(updatedCycle)
                                }
                            )
                        )) {
                            CycleCardView(cycle: cycle, isActive: true)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Upcoming cycles
                    ForEach(viewModel.upcomingCycles) { cycle in
                        NavigationLink(destination: ActiveCycleView(
                            viewModel: ActiveCycleViewModel(
                                cycle: cycle,
                                onCycleUpdate: { updatedCycle in
                                    viewModel.updateCycle(updatedCycle)
                                }
                            )
                        )) {
                            CycleCardView(cycle: cycle, isActive: false)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Completed cycles
                    ForEach(viewModel.completedCycles) { cycle in
                        NavigationLink(destination: ActiveCycleView(
                            viewModel: ActiveCycleViewModel(
                                cycle: cycle,
                                onCycleUpdate: { updatedCycle in
                                    viewModel.updateCycle(updatedCycle)
                                }
                            )
                        )) {
                            CycleCardView(cycle: cycle, isActive: false, isCompleted: true)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Add new cycle button
                    Button(action: {
                        showingBuilder = true
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gsLoading)
                            Text("New Cycle")
                                .font(.headline)
                                .foregroundColor(.gsLoading)
                        }
                        .frame(width: 200, height: 300)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .id(viewModel.cycles.count)
        }
        .sheet(isPresented: $showingBuilder) {
            CycleBuilderView(viewModel: CycleBuilderViewModel(), dashboardViewModel: viewModel)
        }
    }
}

struct CycleCardView: View {
    let cycle: TrainingCycle
    let isActive: Bool
    var isCompleted: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(cycle.goal.rawValue)
                .font(.headline)
                .foregroundColor(.gsLoading)
            
            Text("\(cycle.duration.rawValue) weeks")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Wave preview
            WavePreviewView(weeks: cycle.weeks, isActive: isActive, isCompleted: isCompleted)
                .frame(height: 150)
            
            if isActive {
                HStack {
                    Circle()
                        .fill(Color.gsLoading)
                        .frame(width: 8, height: 8)
                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.gsLoading)
                }
            }
        }
        .padding()
        .frame(width: 200, height: 300)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct WavePreviewView: View {
    let weeks: [CycleWeek]
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / CGFloat(max(weeks.count, 1))
                
                for (index, week) in weeks.enumerated() {
                    let x = CGFloat(index) * stepX + stepX / 2
                    let y = height - (CGFloat(week.targetFatigue) * height)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                isActive ? Color.gsLoading : (isCompleted ? Color.gsDeload : Color.gray),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
            .opacity(isActive || isCompleted ? 1.0 : 0.5)
        }
    }
}

#Preview {
    NavigationView {
        CycleDashboardView()
            .environmentObject(CycleDashboardViewModel())
    }
}

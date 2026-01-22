//
//  HomeView.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: CycleDashboardViewModel
    @StateObject private var achievementViewModel = AchievementViewModel()
    @State private var showingBuilder = false
    
    var body: some View {
        ZStack {
            Color.gsBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header with greeting
                    HeaderView()
                    
                    // Quick stats
                    QuickStatsView(
                        activeCycles: viewModel.activeCycles.count,
                        completedCycles: viewModel.completedCycles.count,
                        currentStreak: achievementViewModel.userStats.currentStreak
                    )
                    
                    // Active cycle card (if exists)
                    if let activeCycle = viewModel.activeCycle {
                        NavigationLink(destination: ActiveCycleView(
                            viewModel: ActiveCycleViewModel(
                                cycle: activeCycle,
                                onCycleUpdate: { updatedCycle in
                                    viewModel.updateCycle(updatedCycle)
                                }
                            )
                        )) {
                            ActiveCycleHeroCard(cycle: activeCycle) {}
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                    }
                    
                    // Quick actions
                    QuickActionsView(
                        onCreateCycle: { showingBuilder = true }
                    )
                    
                    // Recent cycles
                    if !viewModel.cycles.isEmpty {
                        RecentCyclesSection(cycles: viewModel.cycles)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingBuilder) {
            CycleBuilderView(viewModel: CycleBuilderViewModel(), dashboardViewModel: viewModel)
        }
        .onAppear {
            achievementViewModel.updateStats(cycles: viewModel.cycles)
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                    
                    Text("Plan your form, manage your fatigue")
                        .font(.headline)
                        .foregroundColor(.gsLoading)
                }
                
                Spacer()
                
                // Logo/Icon with volume effect
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.gsLoading.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .blur(radius: 8)
                    
                    // Main circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.gsLoading,
                                    Color.gsDeload
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Color.gsLoading.opacity(0.5), radius: 12, x: 0, y: 6)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "waveform.path")
                        .font(.title2)
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Base white
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color.gsBackground.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 8)
        .shadow(color: Color.gsLoading.opacity(0.1), radius: 30, x: 0, y: 12)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
}

struct QuickStatsView: View {
    let activeCycles: Int
    let completedCycles: Int
    let currentStreak: Int
    
    var body: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Active",
                value: "\(activeCycles)",
                icon: "flame.fill",
                color: .gsLoading
            )
            
            StatCard(
                title: "Completed",
                value: "\(completedCycles)",
                icon: "checkmark.circle.fill",
                color: .gsDeload
            )
            
            StatCard(
                title: "Streak",
                value: "\(currentStreak)",
                icon: "bolt.fill",
                color: .gsLoading
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with volume effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.2),
                                color.opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .shadow(color: color.opacity(0.2), radius: 2, x: 0, y: 1)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                color.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            color.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
        .shadow(color: color.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

struct ActiveCycleHeroCard: View {
    let cycle: TrainingCycle
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
                // Background gradient with depth
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gsLoading,
                                Color.gsDeload,
                                Color.gsDeload.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Overlay gradient for volume
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.clear,
                                Color.black.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Active Cycle")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.9))
                                .textCase(.uppercase)
                                .tracking(1)
                            
                            Text(cycle.goal.rawValue)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                            
                            if let currentWeek = cycle.currentWeek {
                                Text("Week \(currentWeek) of \(cycle.duration.rawValue)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.95))
                            }
                        }
                        
                        Spacer()
                        
                        // Wave icon with volume
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 15,
                                        endRadius: 35
                                    )
                                )
                                .frame(width: 70, height: 70)
                                .blur(radius: 6)
                            
                            // Main circle
                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.5),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: Color.white.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "waveform.path.ecg")
                                .font(.title2)
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 1)
                        }
                    }
                    
                    // Progress bar with volume
                    if let currentWeek = cycle.currentWeek {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Progress")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                                Text("\(Int(Double(currentWeek) / Double(cycle.duration.rawValue) * 100))%")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background track
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.25))
                                        .frame(height: 8)
                                    
                                    // Progress fill with gradient
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white,
                                                    Color.white.opacity(0.9)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: geometry.size.width * (Double(currentWeek) / Double(cycle.duration.rawValue)),
                                            height: 8
                                        )
                                        .shadow(color: Color.white.opacity(0.5), radius: 4, x: 0, y: 2)
                                }
                            }
                            .frame(height: 8)
                            .allowsHitTesting(false)
                        }
                    }
                }
                .padding(24)
            }
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.gsLoading.opacity(0.4), radius: 25, x: 0, y: 12)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 8)
            .shadow(color: Color.gsDeload.opacity(0.3), radius: 15, x: 0, y: 6)
            .contentShape(Rectangle())
    }
}

struct QuickActionsView: View {
    let onCreateCycle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.gsLoading)
                .padding(.horizontal, 4)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "New Cycle",
                    icon: "plus.circle.fill",
                    color: .gsLoading,
                    action: onCreateCycle
                )
                
                NavigationLink(destination: AchievementsView()) {
                    QuickActionButtonContent(
                        title: "Achievements",
                        icon: "trophy.fill",
                        color: .gsDeload
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: SettingsView()) {
                    QuickActionButtonContent(
                        title: "Settings",
                        icon: "gearshape.fill",
                        color: .gray
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct QuickActionButtonContent: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with volume effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.15),
                                color.opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 30
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                color.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            color.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        .shadow(color: color.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon with volume effect
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.15),
                                    color.opacity(0.05)
                                ],
                                center: .center,
                                startRadius: 8,
                                endRadius: 30
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                        .shadow(color: color.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    color.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(0.15),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
            .shadow(color: color.opacity(0.1), radius: 6, x: 0, y: 3)
        }
    }
}

struct RecentCyclesSection: View {
    let cycles: [TrainingCycle]
    
    var recentCycles: [TrainingCycle] {
        Array(cycles.sorted { $0.startDate > $1.startDate }.prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Cycles")
                    .font(.headline)
                    .foregroundColor(.gsLoading)
                
                Spacer()
                
                if cycles.count > 3 {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.gsLoading)
                }
            }
            .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recentCycles) { cycle in
                        CyclePreviewCard(cycle: cycle) {}
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct CyclePreviewCard: View {
    let cycle: TrainingCycle
    let onTap: () -> Void
    
    @EnvironmentObject var viewModel: CycleDashboardViewModel
    
    var body: some View {
        NavigationLink(destination: ActiveCycleView(
            viewModel: ActiveCycleViewModel(
                cycle: cycle,
                onCycleUpdate: { updatedCycle in
                    viewModel.updateCycle(updatedCycle)
                }
            )
        )) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(cycle.goal.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gsLoading)
                    
                    Spacer()
                    
                    if cycle.isActive {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.gsLoading.opacity(0.3),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 2,
                                        endRadius: 8
                                    )
                                )
                                .frame(width: 16, height: 16)
                            
                            Circle()
                                .fill(Color.gsLoading)
                                .frame(width: 8, height: 8)
                                .shadow(color: Color.gsLoading.opacity(0.6), radius: 4, x: 0, y: 2)
                        }
                    } else if cycle.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.gsDeload)
                            .shadow(color: Color.gsDeload.opacity(0.3), radius: 3, x: 0, y: 1)
                    }
                }
                
                Text("\(cycle.duration.rawValue) weeks")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Mini wave preview
                WavePreviewView(weeks: cycle.weeks, isActive: cycle.isActive, isCompleted: cycle.isCompleted)
                    .frame(height: 60)
            }
            .padding(16)
            .frame(width: 180)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    (cycle.isActive ? Color.gsLoading : Color.gsDeload).opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                (cycle.isActive ? Color.gsLoading : Color.gsDeload).opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
            .shadow(color: (cycle.isActive ? Color.gsLoading : Color.gsDeload).opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        HomeView()
            .environmentObject(CycleDashboardViewModel())
    }
}

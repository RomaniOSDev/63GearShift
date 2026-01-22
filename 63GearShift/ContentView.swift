//
//  ContentView.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dashboardViewModel = CycleDashboardViewModel()
    @State private var selectedTab = 0
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard
            NavigationView {
                CycleDashboardView()
                    .environmentObject(dashboardViewModel)
            }
            .tabItem {
                Label("Cycles", systemImage: "waveform.path")
            }
            .tag(0)
            
            // Active Cycles
            NavigationView {
                if dashboardViewModel.activeCycles.isEmpty {
                    ZStack {
                        Color.gsBackground
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No Active Cycles")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Create a new cycle to get started")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .navigationTitle("Active Cycles")
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(dashboardViewModel.activeCycles) { cycle in
                                NavigationLink(destination: ActiveCycleView(
                                    viewModel: ActiveCycleViewModel(
                                        cycle: cycle,
                                        onCycleUpdate: { updatedCycle in
                                            dashboardViewModel.updateCycle(updatedCycle)
                                        }
                                    )
                                )) {
                                    ActiveCycleCard(cycle: cycle)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    .background(Color.gsBackground)
                    .navigationTitle("Active Cycles")
                }
            }
            .tabItem {
                Label("Active", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(1)
            
            // Analysis
            NavigationView {
                CycleAnalysisView(cycles: dashboardViewModel.cycles)
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            NavigationLink(destination: AchievementsView()) {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.gsLoading)
                            }
                            
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.gsLoading)
                            }
                        }
                    }
            }
            .tabItem {
                Label("Analysis", systemImage: "chart.bar")
            }
            .tag(2)
        }
        .accentColor(.gsLoading)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
}

struct ActiveCycleCard: View {
    let cycle: TrainingCycle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(cycle.goal.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.gsLoading)
                
                Spacer()
                
                Text(cycle.aggressiveness.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gsLoading.opacity(0.2))
                    .foregroundColor(.gsLoading)
                    .cornerRadius(8)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(cycle.duration.rawValue) weeks")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                if let currentWeek = cycle.currentWeek {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Current Week")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(currentWeek)/\(cycle.duration.rawValue)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gsLoading)
                    }
                }
            }
            
            // Wave preview
            WavePreviewView(weeks: cycle.weeks, isActive: true, isCompleted: false)
                .frame(height: 100)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
}

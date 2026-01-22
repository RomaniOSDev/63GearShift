//
//  WaveSettingsView.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI

struct WaveSettingsView: View {
    @StateObject private var viewModel = WaveSettingsViewModel()
    
    var body: some View {
        ZStack {
            Color.gsBackground
                .ignoresSafeArea()
            
            Form {
                Section("Wave Pattern") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Loading Weeks Ratio: \(Int(viewModel.settings.loadingWeeksRatio * 100))%")
                            .font(.subheadline)
                        Slider(value: $viewModel.settings.loadingWeeksRatio, in: 0.5...0.9)
                            .tint(.gsLoading)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Deload Reduction: \(Int(viewModel.settings.deloadReduction * 100))%")
                            .font(.subheadline)
                        Slider(value: $viewModel.settings.deloadReduction, in: 0.1...0.5)
                            .tint(.gsDeload)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Peak Intensity: \(Int(viewModel.settings.peakIntensity * 100))%")
                            .font(.subheadline)
                        Slider(value: $viewModel.settings.peakIntensity, in: 0.7...1.3)
                            .tint(.gsLoading)
                    }
                }
                
                Section("Microcycle Settings") {
                    Picker("Microcycle Length", selection: $viewModel.settings.microcycleLength) {
                        Text("2 weeks").tag(2)
                        Text("3 weeks").tag(3)
                        Text("4 weeks").tag(4)
                    }
                    
                    Toggle("Custom Microcycles", isOn: $viewModel.settings.enableCustomMicrocycles)
                }
                
                Section("Fatigue & Recovery") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fatigue Decay Rate: \(String(format: "%.2f", viewModel.settings.fatigueDecayRate))")
                            .font(.subheadline)
                        Slider(value: $viewModel.settings.fatigueDecayRate, in: 0.05...0.2)
                            .tint(.gsDeload)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recovery Multiplier: \(String(format: "%.2f", viewModel.settings.recoveryMultiplier))")
                            .font(.subheadline)
                        Slider(value: $viewModel.settings.recoveryMultiplier, in: 0.5...2.0)
                            .tint(.gsLoading)
                    }
                }
                
                Section("Advanced") {
                    Toggle("Adaptive Wave", isOn: $viewModel.settings.enableAdaptiveWave)
                    
                    if viewModel.settings.enableAdaptiveWave {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Adaptive Threshold: \(Int(viewModel.settings.adaptiveThreshold * 100))%")
                                .font(.subheadline)
                            Slider(value: $viewModel.settings.adaptiveThreshold, in: 0.6...1.0)
                                .tint(.gsLoading)
                        }
                    }
                }
                
                Section {
                    Button("Reset to Defaults") {
                        viewModel.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Wave Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.save()
        }
    }
}

#Preview {
    NavigationView {
        WaveSettingsView()
    }
}

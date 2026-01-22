//
//  SettingsView.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gsBackground
                    .ignoresSafeArea()
                
                Form {
                    Section("App Settings") {
                        NavigationLink(destination: WaveSettingsView()) {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(.gsLoading)
                                    .frame(width: 24)
                                Text("Wave Settings")
                            }
                        }
                        
                        NavigationLink(destination: AchievementsView()) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.gsDeload)
                                    .frame(width: 24)
                                Text("Achievements")
                            }
                        }
                    }
                    
                    Section("About") {
                        Button(action: rateApp) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.gsLoading)
                                    .frame(width: 24)
                                Text("Rate Us")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.primary)
                        
                        Button(action: openPrivacyPolicy) {
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(.gsDeload)
                                    .frame(width: 24)
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.primary)
                        
                        Button(action: openTermsOfService) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.gsLoading)
                                    .frame(width: 24)
                                Text("Terms of Service")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    
                    Section("App Info") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text(appVersion)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Build")
                            Spacer()
                            Text(appBuild)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section {
                        Button("Reset Onboarding") {
                            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://example.com/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://example.com/terms-of-service") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView()
}

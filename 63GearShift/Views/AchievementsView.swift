//
//  AchievementsView.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var viewModel = AchievementViewModel()
    
    var body: some View {
        ZStack {
            Color.gsBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Stats summary
                    StatsSummaryCard(stats: viewModel.userStats)
                    
                    // Recent achievements
                    if !viewModel.recentAchievements.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Achievements")
                                .font(.headline)
                                .foregroundColor(.gsLoading)
                            
                            ForEach(viewModel.recentAchievements) { achievement in
                                AchievementRow(achievement: achievement)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    // All achievements
                    VStack(alignment: .leading, spacing: 16) {
                        Text("All Achievements")
                            .font(.headline)
                            .foregroundColor(.gsLoading)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                            ForEach(viewModel.userStats.achievements) { achievement in
                                AchievementBadge(achievement: achievement)
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
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatsSummaryCard: View {
    let stats: UserStats
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Your Stats")
                .font(.headline)
                .foregroundColor(.gsLoading)
            
            HStack(spacing: 20) {
                StatItem(title: "Cycles", value: "\(stats.totalCyclesCompleted)", icon: "arrow.triangle.2.circlepath")
                StatItem(title: "Weeks", value: "\(stats.totalWeeksCompleted)", icon: "calendar")
                StatItem(title: "Streak", value: "\(stats.currentStreak)", icon: "flame.fill")
                StatItem(title: "Volume", value: "\(Int(stats.totalVolume / 1000))k kg", icon: "dumbbell.fill")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.gsLoading)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.gsLoading)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? .gsLoading : .gray)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .gray)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if let unlockedAt = achievement.unlockedAt {
                    Text("Unlocked: \(unlockedAt, style: .date)")
                        .font(.caption2)
                        .foregroundColor(.gsLoading)
                }
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.gsLoading)
            }
        }
        .padding()
        .background(achievement.isUnlocked ? Color.gsLoading.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.gsLoading.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(achievement.isUnlocked ? .gsLoading : .gray)
            }
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(achievement.isUnlocked ? .primary : .gray)
            
            if !achievement.isUnlocked {
                ProgressView(value: achievement.progress)
                    .tint(.gsLoading)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        AchievementsView()
    }
}

//
//  WaveSettingsViewModel.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftUI
import Combine

class WaveSettingsViewModel: ObservableObject {
    @Published var settings: WaveSettings
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "waveSettings"),
           let decoded = try? JSONDecoder().decode(WaveSettings.self, from: data) {
            settings = decoded
        } else {
            settings = WaveSettings.default
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "waveSettings")
        }
    }
    
    func resetToDefaults() {
        settings = WaveSettings.default
        save()
    }
}

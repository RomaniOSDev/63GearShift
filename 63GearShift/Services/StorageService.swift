//
//  StorageService.swift
//  63GearShift
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let fileName = "training_cycles.json"
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var fileURL: URL {
        documentsDirectory.appendingPathComponent(fileName)
    }
    
    private init() {}
    
    // MARK: - Save Cycles
    
    func saveCycles(_ cycles: [TrainingCycle]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let data = try encoder.encode(cycles)
            try data.write(to: fileURL, options: [.atomic])
            
            print("✅ Successfully saved \(cycles.count) cycles to \(fileURL.path)")
        } catch {
            print("❌ Error saving cycles: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load Cycles
    
    func loadCycles() -> [TrainingCycle] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("ℹ️ No saved cycles found at \(fileURL.path)")
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let cycles = try decoder.decode([TrainingCycle].self, from: data)
            print("✅ Successfully loaded \(cycles.count) cycles from storage")
            return cycles
        } catch {
            print("❌ Error loading cycles: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Delete Cycles
    
    func deleteAllCycles() {
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                print("✅ Successfully deleted all cycles")
            }
        } catch {
            print("❌ Error deleting cycles: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Backup & Restore
    
    func createBackup() -> URL? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        let backupFileName = "training_cycles_backup_\(Date().timeIntervalSince1970).json"
        let backupURL = documentsDirectory.appendingPathComponent(backupFileName)
        
        do {
            try FileManager.default.copyItem(at: fileURL, to: backupURL)
            print("✅ Backup created at \(backupURL.path)")
            return backupURL
        } catch {
            print("❌ Error creating backup: \(error.localizedDescription)")
            return nil
        }
    }
    
    func restoreFromBackup(_ backupURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            try FileManager.default.copyItem(at: backupURL, to: fileURL)
            print("✅ Successfully restored from backup")
            return true
        } catch {
            print("❌ Error restoring from backup: \(error.localizedDescription)")
            return false
        }
    }
}

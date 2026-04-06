//
//  MaintenanceSessionManager.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar
//
//  Recommendation 1: Session Timer + Logging
//  Tracks operator time from opening a unit to completing maintenance.
//  Provides MTTR data for KPI measurement (Section 1.3.3, Objective O4).
//

import Foundation
import SwiftUI

// MARK: - Session Log Entry
struct SessionLogEntry: Identifiable {
    let id = UUID()
    let unitRoomID: String
    let unitName: String
    let startTime: Date
    let endTime: Date
    let durationSeconds: TimeInterval
    let outcome: MaintenanceOutcome
    let tabsVisited: [String]
    let backtrackCount: Int // How many times operator went backwards in workflow
}

// MARK: - Maintenance Session Manager
@Observable
class MaintenanceSessionManager {
    static let shared = MaintenanceSessionManager()

    // Current session state
    var sessionStartTime: Date? = nil
    var currentUnitRoomID: String? = nil
    var currentUnitName: String? = nil
    var isSessionActive: Bool = false
    var elapsedSeconds: TimeInterval = 0

    // Tracking metrics
    var tabsVisited: [String] = []
    var backtrackCount: Int = 0

    // Historical session logs
    var sessionLogs: [SessionLogEntry] = []

    // Timer reference
    private var timer: Timer? = nil

    // MARK: - Session Control

    func startSession(for unit: FanCoilUnit) {
        sessionStartTime = Date()
        currentUnitRoomID = unit.roomID
        currentUnitName = unit.name
        isSessionActive = true
        elapsedSeconds = 0
        tabsVisited = []
        backtrackCount = 0

        // Start the live timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.sessionStartTime else { return }
            self.elapsedSeconds = Date().timeIntervalSince(start)
        }
    }

    func endSession(outcome: MaintenanceOutcome) -> SessionLogEntry? {
        guard let start = sessionStartTime,
              let roomID = currentUnitRoomID,
              let name = currentUnitName else { return nil }

        timer?.invalidate()
        timer = nil

        let endTime = Date()
        let duration = endTime.timeIntervalSince(start)

        let entry = SessionLogEntry(
            unitRoomID: roomID,
            unitName: name,
            startTime: start,
            endTime: endTime,
            durationSeconds: duration,
            outcome: outcome,
            tabsVisited: tabsVisited,
            backtrackCount: backtrackCount
        )

        sessionLogs.insert(entry, at: 0)
        isSessionActive = false

        return entry
    }

    func recordTabVisit(_ tabName: String) {
        tabsVisited.append(tabName)
    }

    func recordBacktrack() {
        backtrackCount += 1
    }

    // MARK: - Formatted Time Helpers

    var formattedElapsedTime: String {
        formatDuration(elapsedSeconds)
    }

    func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 {
            return String(format: "%dm %02ds", mins, secs)
        } else {
            return String(format: "%ds", secs)
        }
    }

    // MARK: - Analytics Computed Properties

    /// Average MTTR across all logged sessions (in minutes)
    var averageMTTR: Double {
        guard !sessionLogs.isEmpty else { return 0 }
        let totalSeconds = sessionLogs.reduce(0.0) { $0 + $1.durationSeconds }
        return (totalSeconds / Double(sessionLogs.count)) / 60.0
    }

    /// Average MTTR for resolved sessions only
    var averageMTTRResolved: Double {
        let resolved = sessionLogs.filter { $0.outcome == .markResolved }
        guard !resolved.isEmpty else { return 0 }
        let totalSeconds = resolved.reduce(0.0) { $0 + $1.durationSeconds }
        return (totalSeconds / Double(resolved.count)) / 60.0
    }

    /// Total sessions completed
    var totalSessions: Int {
        sessionLogs.count
    }

    /// Diagnostic success rate (resolved / total)
    var diagnosticSuccessRate: Double {
        guard !sessionLogs.isEmpty else { return 0 }
        let resolved = sessionLogs.filter { $0.outcome == .markResolved }.count
        return Double(resolved) / Double(sessionLogs.count) * 100
    }

    /// Average backtrack count (error indicator)
    var averageBacktrackCount: Double {
        guard !sessionLogs.isEmpty else { return 0 }
        let total = sessionLogs.reduce(0) { $0 + $1.backtrackCount }
        return Double(total) / Double(sessionLogs.count)
    }
}


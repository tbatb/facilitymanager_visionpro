//
//  SessionTimerBanner.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar
//
//  Displays the live session timer at the top of maintenance containers.
//  Part of Recommendation 1: Session Timer + Logging.
//

import SwiftUI

// MARK: - Session Timer Banner (shown in maintenance containers)
struct SessionTimerBanner: View {
    let sessionManager = MaintenanceSessionManager.shared

    var body: some View {
        if sessionManager.isSessionActive {
            HStack(spacing: 12) {
                // Pulsing recording indicator
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
                    .modifier(PulsingModifier())

                Image(systemName: "timer")
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Text("Session: \(sessionManager.formattedElapsedTime)")
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.semibold)

                Spacer()

                if sessionManager.backtrackCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.caption2)
                        Text("\(sessionManager.backtrackCount)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.orange.opacity(0.15))
                    .cornerRadius(8)
                }

                Text(sessionManager.currentUnitRoomID ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Pulsing Animation Modifier
struct PulsingModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 0.3 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}

// MARK: - Session Summary View (shown after maintenance completion)
struct SessionSummaryView: View {
    let entry: SessionLogEntry
    let sessionManager = MaintenanceSessionManager.shared

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.doc.horizontal.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("Session Performance Summary")
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Divider()

            // KPI Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                SessionKPICard(
                    title: "Session Duration (MTTR)",
                    value: sessionManager.formatDuration(entry.durationSeconds),
                    icon: "clock.fill",
                    color: entry.durationSeconds < 300 ? .green : entry.durationSeconds < 600 ? .orange : .red
                )

                SessionKPICard(
                    title: "Outcome",
                    value: entry.outcome == .markResolved ? "Resolved" : "Follow-up",
                    icon: entry.outcome == .markResolved ? "checkmark.circle.fill" : "calendar.badge.clock",
                    color: entry.outcome == .markResolved ? .green : .yellow
                )

                SessionKPICard(
                    title: "Backtracks",
                    value: "\(entry.backtrackCount)",
                    icon: "arrow.uturn.backward.circle.fill",
                    color: entry.backtrackCount == 0 ? .green : entry.backtrackCount <= 2 ? .orange : .red
                )

                SessionKPICard(
                    title: "Tabs Visited",
                    value: "\(entry.tabsVisited.count)",
                    icon: "rectangle.stack.fill",
                    color: .blue
                )
            }

            // Context info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Unit:")
                        .foregroundStyle(.secondary)
                    Text("\(entry.unitRoomID) — \(entry.unitName)")
                        .fontWeight(.medium)
                }
                HStack {
                    Text("Started:")
                        .foregroundStyle(.secondary)
                    Text(dateFormatter.string(from: entry.startTime))
                }
                HStack {
                    Text("Completed:")
                        .foregroundStyle(.secondary)
                    Text(dateFormatter.string(from: entry.endTime))
                }
            }
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Historical comparison (if previous sessions exist)
            if sessionManager.totalSessions > 1 {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Compared to Previous Sessions")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 20) {
                        MiniKPI(label: "Avg MTTR", value: String(format: "%.1f min", sessionManager.averageMTTR))
                        MiniKPI(label: "Success Rate", value: String(format: "%.0f%%", sessionManager.diagnosticSuccessRate))
                        MiniKPI(label: "Avg Backtracks", value: String(format: "%.1f", sessionManager.averageBacktrackCount))
                        MiniKPI(label: "Total Sessions", value: "\(sessionManager.totalSessions)")
                    }
                }
            }
        }
        .padding(24)
        .background(.thinMaterial)
        .cornerRadius(16)
    }
}

// MARK: - Session KPI Card
struct SessionKPICard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
}

// MARK: - Mini KPI for comparison row
struct MiniKPI: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}


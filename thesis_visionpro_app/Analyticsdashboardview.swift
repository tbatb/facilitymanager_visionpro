//
//  AnalyticsDashboardView.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar
//

import SwiftUI

struct AnalyticsDashboardView: View {
    @State private var registry = FCURegistry.shared

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Facility Analytics")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Maintenance insights and performance overview")
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        AnalyticsStatCard(title: "Fleet Health", value: String(format: "%.0f%%", registry.onlinePercentage), icon: "heart.fill", color: registry.onlinePercentage > 50 ? .green : .red)
                        AnalyticsStatCard(title: "Total Repairs", value: "\(registry.totalRepairs)", icon: "wrench.fill", color: .blue)
                        AnalyticsStatCard(title: "Total Downtime", value: String(format: "%.1fh", registry.totalDowntime), icon: "clock.arrow.circlepath", color: .orange)
                        AnalyticsStatCard(title: "Avg Repair Time", value: "\(registry.averageRepairTime) min", icon: "timer", color: .purple)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Unit Status Breakdown")
                            .font(.title3)
                            .fontWeight(.semibold)

                        HStack(spacing: 0) {
                            let onlineCount = registry.availableUnits.filter { $0.status == .online }.count
                            let maintenanceCount = registry.availableUnits.filter { $0.status == .maintenance }.count
                            let criticalCount = registry.availableUnits.filter { $0.status == .criticalError }.count
                            let total = max(registry.availableUnits.count, 1)

                            StatusBarSegment(count: onlineCount, total: total, color: .green, label: "Online", isFirst: true)
                            StatusBarSegment(count: maintenanceCount, total: total, color: .yellow, label: "Scheduled")
                            StatusBarSegment(count: criticalCount, total: total, color: .red, label: "Critical", isLast: true)
                        }
                        .frame(height: 40)
                        .cornerRadius(12)

                        // Legend
                        HStack(spacing: 24) {
                            StatusLegendItem(color: .green, label: "Online", count: registry.availableUnits.filter { $0.status == .online }.count)
                            StatusLegendItem(color: .yellow, label: "Maintenance", count: registry.availableUnits.filter { $0.status == .maintenance }.count)
                            StatusLegendItem(color: .red, label: "Critical", count: registry.availableUnits.filter { $0.status == .criticalError }.count)
                        }
                    }
                    .padding(24)
                    .background(.thinMaterial)
                    .cornerRadius(16)

                    // MARK: - Most Repaired Units Ranking
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Most Repaired Units")
                            .font(.title3)
                            .fontWeight(.semibold)

                        ForEach(Array(registry.unitsByRepairCount.enumerated()), id: \.element.id) { index, unit in
                            HStack(spacing: 16) {
                                // Rank badge
                                ZStack {
                                    Circle()
                                        .fill(index == 0 ? Color.red.opacity(0.2) : index == 1 ? Color.orange.opacity(0.2) : Color.blue.opacity(0.1))
                                        .frame(width: 36, height: 36)
                                    Text("#\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(index == 0 ? .red : index == 1 ? .orange : .blue)
                                }

                                Image(systemName: unit.imageName)
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(unit.roomID)
                                        .font(.headline)
                                    Text(unit.name)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                // Repair count bar
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(unit.repairCount) repairs")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(String(format: "%.1fh downtime", unit.totalDowntimeHours))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                // Visual bar
                                let maxRepairs = registry.unitsByRepairCount.first?.repairCount ?? 1
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(index == 0 ? Color.red : index == 1 ? Color.orange : Color.blue)
                                    .frame(width: CGFloat(unit.repairCount) / CGFloat(max(maxRepairs, 1)) * 100, height: 8)
                            }
                            .padding(.vertical, 8)

                            if index < registry.unitsByRepairCount.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .padding(24)
                    .background(.thinMaterial)
                    .cornerRadius(16)

                    // MARK: - Recent Maintenance Activity
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Maintenance Activity")
                            .font(.title3)
                            .fontWeight(.semibold)

                        ForEach(registry.recentHistory) { record in
                            HStack(spacing: 14) {
                                // Type icon
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(record.outcome == .markResolved ? Color.green.opacity(0.15) : Color.yellow.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: record.type.icon)
                                        .foregroundStyle(record.outcome == .markResolved ? .green : .yellow)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text("\(record.unitRoomID) — \(record.type.rawValue)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("\(record.technician) · \(record.durationMinutes) min · \(record.outcome.rawValue)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(dateFormatter.string(from: record.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .padding(24)
                    .background(.thinMaterial)
                    .cornerRadius(16)

                    // MARK: - Maintenance Type Distribution
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Maintenance by Type")
                            .font(.title3)
                            .fontWeight(.semibold)

                        let typeCounts = Dictionary(grouping: registry.maintenanceHistory, by: { $0.type }).mapValues { $0.count }
                        let sortedTypes = typeCounts.sorted { $0.value > $1.value }
                        let maxCount = sortedTypes.first?.value ?? 1

                        ForEach(sortedTypes, id: \.key) { type, count in
                            HStack(spacing: 12) {
                                Image(systemName: type.icon)
                                    .foregroundStyle(.blue)
                                    .frame(width: 24)

                                Text(type.rawValue)
                                    .font(.subheadline)
                                    .frame(width: 160, alignment: .leading)

                                GeometryReader { geo in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.blue.opacity(0.6))
                                        .frame(width: geo.size.width * CGFloat(count) / CGFloat(maxCount))
                                }
                                .frame(height: 12)

                                Text("\(count)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(width: 30, alignment: .trailing)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(24)
                    .background(.thinMaterial)
                    .cornerRadius(16)

                    Spacer(minLength: 40)
                }
                .padding(40)
            }
            .navigationTitle("Analytics")
        }
    }
}

// MARK: - Analytics Stat Card
struct AnalyticsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .cornerRadius(16)
    }
}

// MARK: - Status Bar Segment
struct StatusBarSegment: View {
    let count: Int
    let total: Int
    let color: Color
    let label: String
    var isFirst: Bool = false
    var isLast: Bool = false

    var body: some View {
        if count > 0 {
            ZStack {
                Rectangle()
                    .fill(color)
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(width: CGFloat(count) / CGFloat(total) * 500)
        }
    }
}

// MARK: - Status Legend Item
struct StatusLegendItem: View {
    let color: Color
    let label: String
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text("\(label) (\(count))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}


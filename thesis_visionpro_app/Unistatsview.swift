//
//  UnitStatsView.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar
//

import SwiftUI

struct UnitStatsView: View {
    let unit: FanCoilUnit

    @State private var rpm: Double = 1120
    @State private var wattUsage: Double = 345
    @State private var temperature: Double = 22.4
    @State private var airflow: Double = 0.85
    @State private var isRunning: Bool = true

    private let lastMaintenance = "14 Oct 2025"
    private let nextMaintenance = "18 Feb 2026"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {

                // MARK: - Header
                HStack(spacing: 16) {
                    Image(systemName: unit.imageName)
                        .font(.system(size: 36))
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(unit.roomID)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text(unit.name)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Circle()
                            .fill(isRunning ? .green : .red)
                            .frame(width: 12, height: 12)
                        Text(isRunning ? "Running" : "Stopped")
                            .font(.headline)
                            .foregroundStyle(isRunning ? .green : .red)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.thinMaterial)
                    .cornerRadius(20)
                }

                // MARK: - Maintenance Planned Banner
                if unit.status == .maintenance {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.title3)
                            .foregroundStyle(.yellow)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Maintenance Scheduled")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Planned for \(nextMaintenance) — unit will be taken offline.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(.yellow.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.yellow.opacity(0.4), lineWidth: 1)
                    )
                    .cornerRadius(12)
                }

                // MARK: - Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    StatCard(title: "Fan Speed", value: String(format: "%.0f", rpm), unit: "RPM", icon: "fan.fill", color: .blue)
                    StatCard(title: "Power Usage", value: String(format: "%.0f", wattUsage), unit: "W", icon: "bolt.fill", color: .orange)
                    StatCard(title: "Temperature", value: String(format: "%.1f", temperature), unit: "°C", icon: "thermometer.medium", color: .red)
                    StatCard(title: "Airflow Rate", value: String(format: "%.2f", airflow), unit: "m³/s", icon: "wind", color: .cyan)
                }

                // MARK: - Last Maintenance
                HStack {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Last Maintenance")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(lastMaintenance)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding(20)
                .background(.thinMaterial)
                .cornerRadius(16)

                Spacer()
            }
            .padding(40)
        }
        .navigationTitle(unit.roomID)
        .onAppear { simulateStats() }
    }

    private func simulateStats() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                rpm = Double.random(in: 1080...1160)
                wattUsage = Double.random(in: 330...360)
                temperature = Double.random(in: 21.8...23.2)
                airflow = Double.random(in: 0.80...0.90)
            }
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text(unit)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .cornerRadius(16)
    }
}


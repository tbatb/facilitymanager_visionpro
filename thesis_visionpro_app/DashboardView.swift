//
//  DashboardView.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar on 29.11.25.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        TabView {
            UnitsDashboardView()
                .tabItem {
                    Label("Units", systemImage: "square.grid.2x2")
                }

            FaultTreeBrowserView()
                .tabItem {
                    Label("Fault Tree", systemImage: "arrow.triangle.branch")
                }

            AnalyticsDashboardView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.xaxis")
                }
        }
    }
}

// MARK: - Units Dashboard
struct UnitsDashboardView: View {
    @State private var registry = FCURegistry.shared
    @State private var unitForFaultPicker: FanCoilUnit? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 30) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Facility Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("\(registry.availableUnits.count) units registered · \(registry.availableUnits.filter { $0.status == .criticalError }.count) faults detected")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 30) {
                        ForEach(registry.availableUnits) { unit in
                            UnitCardWithActions(
                                unit: unit,
                                onSimulateFault: { unitForFaultPicker = unit }
                            )
                        }
                    }
                    .padding()
                }
            }
            .padding(40)
            .navigationDestination(for: FanCoilUnit.self) { unit in
                switch unit.status {
                case .criticalError:
                    UnitMaintenanceContainer(selectedUnit: unit)
                case .maintenance:
                    ScheduledMaintenanceContainer(selectedUnit: unit)
                case .online:
                    UnitStatsView(unit: unit)
                }
            }
            .sheet(item: $unitForFaultPicker) { unit in
                FaultPickerSheet(unit: unit)
            }
        }
    }
}

// MARK: - Unit Card With Actions
struct UnitCardWithActions: View {
    @ObservedObject var unit: FanCoilUnit
    let onSimulateFault: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            NavigationLink(value: unit) {
                UnitCard(unit: unit)
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                Button {
                    onSimulateFault()
                } label: {
                    Label("Simulate Fault", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .tint(.red)

                if unit.activeFault != nil || unit.status == .criticalError {
                    Button {
                        unit.activeFault = nil
                        unit.status = .online
                    } label: {
                        Label("Clear", systemImage: "xmark.circle.fill")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                }
            }
        }
    }
}

// MARK: - Fault Picker Sheet
struct FaultPickerSheet: View {
    @ObservedObject var unit: FanCoilUnit
    @Environment(\.dismiss) private var dismiss

    private var groupedFaults: [(branch: String, faults: [FaultType])] {
        let grouped = Dictionary(grouping: FaultType.allCases) { $0.branch }
        return grouped.sorted { $0.key < $1.key }.map { (branch: $0.key, faults: $0.value) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)

                        Text("Simulate Fault on \(unit.roomID)")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Select a fault from the Fault Tree to simulate on this unit.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 450)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)

                    ForEach(groupedFaults, id: \.branch) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(group.branch)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            VStack(spacing: 0) {
                                ForEach(Array(group.faults.enumerated()), id: \.element.id) { index, fault in
                                    Button {
                                        unit.activeFault = fault
                                        unit.status = .criticalError
                                        dismiss()
                                    } label: {
                                        HStack(spacing: 14) {
                                            Image(systemName: fault.icon)
                                                .font(.title3)
                                                .foregroundStyle(fault.color)
                                                .frame(width: 32)

                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(fault.title)
                                                    .font(.headline)
                                                    .foregroundStyle(.primary)
                                                Text(fault.diagnosticSummary)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(2)
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(.tertiary)
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 16)
                                    }
                                    .buttonStyle(.plain)

                                    if index < group.faults.count - 1 {
                                        Divider().padding(.leading, 62)
                                    }
                                }
                            }
                            .background(.thinMaterial)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(32)
            }
            .navigationTitle("Fault Tree")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Unit Card Component
struct UnitCard: View {
    @ObservedObject var unit: FanCoilUnit

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 100)
                Circle()
                    .strokeBorder(unit.status.color.opacity(0.5), lineWidth: 2)
                    .frame(height: 100)
                Image(systemName: unit.imageName)
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 5) {
                Text(unit.roomID)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(unit.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let fault = unit.activeFault {
                HStack(spacing: 4) {
                    Image(systemName: fault.icon)
                        .font(.caption2)
                    Text(fault.title)
                        .font(.caption2)
                        .lineLimit(1)
                }
                .foregroundStyle(fault.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(fault.color.opacity(0.1))
                .cornerRadius(8)
            }

            HStack(spacing: 6) {
                Image(systemName: unit.status.icon)
                    .font(.caption2)
                Text(unit.status.rawValue.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(unit.status.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.thinMaterial)
            .cornerRadius(20)
        }
        .padding(30)
        .frame(width: 280, height: 320)
        .glassBackgroundEffect()
    }
}

//
//  FaultTreeBrowserView.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar
//

import SwiftUI

struct FaultTreeBrowserView: View {
    @State private var registry = FCURegistry.shared
    @State private var expandedBranches: Set<String> = []
    @State private var selectedFault: FaultType? = nil

    // Group faults by branch
    private var branches: [(branch: String, icon: String, color: Color, faults: [FaultType])] {
        [
            (branch: "B1 Actuator/Control Failure", icon: "gear.badge.xmark", color: .red,
             faults: [.actuatorStuck, .valveFault, .no24VSupply, .actuatorMotor]),
            (branch: "B2 Software Failure", icon: "cpu", color: .purple,
             faults: [.logicTrap, .configMismatch, .firmwareFailure]),
            (branch: "B3 Mechanical/HVAC Failure", icon: "fan.fill", color: .orange,
             faults: [.fanFault, .filterClogged, .coilFouling, .pumpMalfunction]),
            (branch: "B4 Sensor/Data Problem", icon: "sensor.fill", color: .yellow,
             faults: [.sensorCalibration, .sensorSignalLoss]),
        ]
    }

    private func unitsWithFault(_ fault: FaultType) -> [FanCoilUnit] {
        registry.availableUnits.filter { $0.activeFault == fault }
    }

    private func unitsInBranch(_ faults: [FaultType]) -> [FanCoilUnit] {
        registry.availableUnits.filter { unit in
            guard let active = unit.activeFault else { return false }
            return faults.contains(active)
        }
    }

    private var totalAffected: Int {
        registry.availableUnits.filter { $0.activeFault != nil }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // MARK: - Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.title)
                            .foregroundStyle(.blue)
                        Text("Fault Tree Analysis")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }

                    Text("FCU Temperature Anomalies — Complete diagnostic hierarchy from Figure 4.3")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // MARK: - Top Event
                VStack(spacing: 0) {
                    // Top event node
                    HStack(spacing: 14) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("TOP EVENT")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.red)
                            Text("Room Temperature > 22°C")
                                .font(.headline)
                        }

                        Spacer()

                        if totalAffected > 0 {
                            Text("\(totalAffected) unit\(totalAffected == 1 ? "" : "s") affected")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.red)
                                .cornerRadius(8)
                        }
                    }
                    .padding(20)
                    .background(.red.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.red.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(16)

                    // OR gate connector
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(.secondary.opacity(0.3))
                            .frame(width: 2, height: 16)
                        Text("OR")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.secondary.opacity(0.1))
                            .cornerRadius(6)
                        Rectangle()
                            .fill(.secondary.opacity(0.3))
                            .frame(width: 2, height: 16)
                    }
                }

                // MARK: - Branches
                ForEach(Array(branches.enumerated()), id: \.element.branch) { index, branch in
                    let isExpanded = expandedBranches.contains(branch.branch)
                    let affected = unitsInBranch(branch.faults)

                    VStack(spacing: 0) {
                        // Branch header
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if isExpanded {
                                    expandedBranches.remove(branch.branch)
                                } else {
                                    expandedBranches.insert(branch.branch)
                                }
                            }
                        } label: {
                            HStack(spacing: 14) {
                                // Branch icon
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(branch.color.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: branch.icon)
                                        .font(.title3)
                                        .foregroundStyle(branch.color)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(branch.branch)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text("\(branch.faults.count) fault types")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                // Affected unit count badge
                                if !affected.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .font(.caption2)
                                        Text("\(affected.count)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(branch.color)
                                    .cornerRadius(8)
                                }

                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                        }
                        .buttonStyle(.plain)

                        // Expanded fault list
                        if isExpanded {
                            VStack(spacing: 0) {
                                ForEach(Array(branch.faults.enumerated()), id: \.element.id) { faultIndex, fault in
                                    let affectedUnits = unitsWithFault(fault)

                                    Button {
                                        withAnimation {
                                            selectedFault = (selectedFault == fault) ? nil : fault
                                        }
                                    } label: {
                                        VStack(spacing: 0) {
                                            HStack(spacing: 12) {
                                                // Connector line
                                                HStack(spacing: 0) {
                                                    Rectangle()
                                                        .fill(branch.color.opacity(0.3))
                                                        .frame(width: 20, height: 2)
                                                    Circle()
                                                        .fill(affectedUnits.isEmpty ? branch.color.opacity(0.3) : branch.color)
                                                        .frame(width: 8, height: 8)
                                                }
                                                .frame(width: 32)

                                                Image(systemName: fault.icon)
                                                    .font(.body)
                                                    .foregroundStyle(fault.color)
                                                    .frame(width: 24)

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(fault.title)
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                        .foregroundStyle(.primary)
                                                    Text(fault.faultPath)
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                        .lineLimit(1)
                                                }

                                                Spacer()

                                                // Affected units badges
                                                if !affectedUnits.isEmpty {
                                                    HStack(spacing: 4) {
                                                        ForEach(affectedUnits) { unit in
                                                            Text(unit.roomID)
                                                                .font(.caption2)
                                                                .fontWeight(.semibold)
                                                                .foregroundStyle(.white)
                                                                .padding(.horizontal, 6)
                                                                .padding(.vertical, 3)
                                                                .background(fault.color)
                                                                .cornerRadius(6)
                                                        }
                                                    }
                                                }

                                                Image(systemName: selectedFault == fault ? "chevron.up" : "chevron.right")
                                                    .font(.caption2)
                                                    .foregroundStyle(.tertiary)
                                            }
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)

                                            // Expanded fault detail
                                            if selectedFault == fault {
                                                VStack(alignment: .leading, spacing: 12) {
                                                    Text(fault.diagnosticSummary)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)

                                                    HStack(spacing: 16) {
                                                        Label("\(fault.repairSteps.count) repair steps", systemImage: "wrench.and.screwdriver")
                                                            .font(.caption2)
                                                            .foregroundStyle(.blue)

                                                        Label(fault.repairTitle, systemImage: "doc.text")
                                                            .font(.caption2)
                                                            .foregroundStyle(.secondary)
                                                    }

                                                    if !affectedUnits.isEmpty {
                                                        VStack(alignment: .leading, spacing: 6) {
                                                            Text("Affected Units:")
                                                                .font(.caption)
                                                                .fontWeight(.semibold)
                                                                .foregroundStyle(.primary)

                                                            ForEach(affectedUnits) { unit in
                                                                HStack(spacing: 8) {
                                                                    Image(systemName: unit.imageName)
                                                                        .font(.caption)
                                                                        .foregroundStyle(.blue)
                                                                    Text("\(unit.roomID) — \(unit.name)")
                                                                        .font(.caption)
                                                                    Text("(\(unit.type))")
                                                                        .font(.caption2)
                                                                        .foregroundStyle(.secondary)
                                                                }
                                                            }
                                                        }
                                                        .padding(12)
                                                        .background(fault.color.opacity(0.06))
                                                        .cornerRadius(10)
                                                    } else {
                                                        Text("No units currently affected.")
                                                            .font(.caption)
                                                            .foregroundStyle(.tertiary)
                                                    }
                                                }
                                                .padding(.horizontal, 48)
                                                .padding(.bottom, 12)
                                                .transition(.opacity.combined(with: .move(edge: .top)))
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)

                                    if faultIndex < branch.faults.count - 1 {
                                        Divider().padding(.leading, 48)
                                    }
                                }
                            }
                            .padding(.bottom, 8)
                            .transition(.opacity)
                        }
                    }
                    .background(.thinMaterial)
                    .cornerRadius(16)

                    // Connector between branches (except after last)
                    if index < branches.count - 1 {
                        Rectangle()
                            .fill(.secondary.opacity(0.2))
                            .frame(width: 2, height: 12)
                            .padding(.leading, 36)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(40)
        }
    }
}

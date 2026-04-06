//
//  UnitMaintenanceContainer.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar on 29.11.25.
//

import SwiftUI

struct UnitMaintenanceContainer: View {
    let selectedUnit: FanCoilUnit
    @Environment(\.dismiss) private var dismiss

    @State private var showCompletionView: Bool = false

    var body: some View {
        TabView {
            // TAB 1: Back to Dashboard
            DashboardReturnView {
                dismiss()
            }
            .tabItem {
                Label("Dashboard", systemImage: "square.grid.2x2")
            }

            // TAB 2: Fault Diagnostics (shows active fault info)
            FaultDiagnosticsView(unit: selectedUnit)
                .tabItem {
                    Label("Diagnostics", systemImage: "exclamationmark.triangle")
                }

            // TAB 3: Repair Workflow (fault-specific steps)
            RepairWorkflowView(unit: selectedUnit) {
                showCompletionView = true
            }
            .tabItem {
                Label("Repair", systemImage: "wrench.and.screwdriver")
            }
        }
        .navigationTitle(selectedUnit.roomID)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCompletionView) {
            MaintenanceCompleteView(unit: selectedUnit) {
                showCompletionView = false
                dismiss()
            }
        }
    }
}

// MARK: - Fault Diagnostics View
struct FaultDiagnosticsView: View {
    @ObservedObject var unit: FanCoilUnit

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let fault = unit.activeFault {
                    // Fault Header
                    VStack(spacing: 12) {
                        Image(systemName: fault.icon)
                            .font(.system(size: 60))
                            .foregroundStyle(fault.color)

                        Text("FAULT DETECTED")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundStyle(fault.color)

                        Text(fault.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }

                    // Fault Path
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Fault Tree Path", systemImage: "arrow.triangle.branch")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(fault.faultPath)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(fault.color.opacity(0.7))
                            .cornerRadius(12)
                    }
                    .frame(maxWidth: 560)

                    // Branch Info
                    HStack(spacing: 12) {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Branch")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(fault.branch)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(.thinMaterial)
                    .cornerRadius(12)
                    .frame(maxWidth: 560)

                    // Diagnostic Summary
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Diagnostic Analysis", systemImage: "stethoscope")
                            .font(.headline)

                        Text(fault.diagnosticSummary)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .frame(maxWidth: 560, alignment: .leading)
                    .background(.thinMaterial)
                    .cornerRadius(16)

                    // Recommended Action
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Recommended Repair", systemImage: "wrench.and.screwdriver")
                            .font(.headline)
                            .foregroundStyle(.green)

                        Text(fault.repairTitle)
                            .font(.body)
                            .fontWeight(.medium)

                        Text("\(fault.repairSteps.count) steps · Navigate to the Repair tab to begin.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .frame(maxWidth: 560, alignment: .leading)
                    .background(.green.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.green.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(16)

                    // Unit context
                    unitInfoSection

                } else {
                    // No fault assigned — fallback to the original Logic Trap display
                    MaintenanceOverlayView()
                }

                Spacer(minLength: 40)
            }
            .padding(40)
        }
    }

    private var unitInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Unit Information", systemImage: "info.circle")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 24) {
                InfoChip(label: "Room", value: unit.roomID)
                InfoChip(label: "Type", value: unit.type)
                InfoChip(label: "Repairs", value: "\(unit.repairCount)")
                InfoChip(label: "Downtime", value: String(format: "%.1fh", unit.totalDowntimeHours))
            }
        }
        .padding(20)
        .frame(maxWidth: 560, alignment: .leading)
        .background(.thinMaterial)
        .cornerRadius(16)
    }
}

// MARK: - Info Chip
struct InfoChip: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Repair Workflow View (generic, fault-driven)
struct RepairWorkflowView: View {
    @ObservedObject var unit: FanCoilUnit
    let onCompleteMaintenance: () -> Void

    @State private var currentStepIndex = 0

    private var fault: FaultType? { unit.activeFault }

    private var steps: [MaintenanceStep] {
        fault?.repairSteps ?? ProcedureModel.replacementSteps
    }

    private var title: String {
        fault?.repairTitle ?? "Actuator Replacement Guide"
    }

    private var isLastStep: Bool {
        currentStepIndex == steps.count - 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)

                    if let fault = fault {
                        HStack(spacing: 6) {
                            Image(systemName: fault.icon)
                                .font(.caption)
                                .foregroundStyle(fault.color)
                            Text(fault.branch)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Text("Step \(currentStepIndex + 1) of \(steps.count)")
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
            }

            Divider()

            // Progress indicator
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isLastStep ? Color.green : Color.blue)
                        .frame(width: geo.size.width * (Double(currentStepIndex + 1) / Double(steps.count)))
                        .animation(.easeInOut(duration: 0.3), value: currentStepIndex)
                }
            }
            .frame(height: 6)

            // Current Step Display
            VStack(spacing: 30) {
                // Step number
                Text("Step \(steps[currentStepIndex].number)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)

                Image(systemName: steps[currentStepIndex].icon)
                    .font(.system(size: 60))
                    .foregroundStyle(.primary)
                    .frame(height: 80)

                Text(steps[currentStepIndex].description)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .frame(minHeight: 80)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.08))
            .cornerRadius(16)

            Spacer()

            // Navigation Buttons
            HStack(spacing: 20) {
                Button(action: {
                    if currentStepIndex > 0 { withAnimation { currentStepIndex -= 1 } }
                }) {
                    Label("Previous", systemImage: "chevron.left")
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .disabled(currentStepIndex == 0)

                if isLastStep {
                    Button(action: onCompleteMaintenance) {
                        Label("Complete Maintenance", systemImage: "checkmark.seal.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                } else {
                    Button(action: {
                        withAnimation { currentStepIndex += 1 }
                    }) {
                        Label("Next", systemImage: "chevron.right")
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(40)
        .frame(width: 620, height: 580)
        .glassBackgroundEffect()
    }
}

// MARK: - Dashboard Return View
struct DashboardReturnView: View {
    let onReturn: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Return to Dashboard")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Go back to the facility overview to select another unit.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 350)

            Button(action: onReturn) {
                Label("Back to Dashboard", systemImage: "arrow.left.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }
}

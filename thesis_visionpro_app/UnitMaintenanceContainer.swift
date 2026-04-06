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

            // TAB 2: The Diagnosis (Logic Trap)
            MaintenanceOverlayView()
                .tabItem {
                    Label("Diagnostics", systemImage: "exclamationmark.triangle")
                }

            // TAB 3: The Actuator Replacement (with inline completion button)
            ActuatorReplacementWrapperView {
                showCompletionView = true
            }
            .tabItem {
                Label("Replace Actuator", systemImage: "wrench.and.screwdriver")
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

// MARK: - Actuator Replacement Wrapper (adds completion button at the end)
struct ActuatorReplacementWrapperView: View {
    let onCompleteMaintenance: () -> Void
    @State private var currentStepIndex = 0
    let steps = ProcedureModel.replacementSteps

    private var isLastStep: Bool {
        currentStepIndex == steps.count - 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Standard Operating Procedure")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Step \(currentStepIndex + 1) of \(steps.count)")
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
            }

            Divider()

            // Current Step Display
            VStack(spacing: 30) {
                Image(systemName: steps[currentStepIndex].icon)
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .frame(height: 80)

                Text(steps[currentStepIndex].description)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .frame(height: 120)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
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
                    // Final step: show "Complete Maintenance" instead of disabled "Next"
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
        .frame(width: 600, height: 500)
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


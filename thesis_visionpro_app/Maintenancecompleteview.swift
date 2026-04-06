//
//  MaintenanceCompleteView.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar
//

import SwiftUI

struct MaintenanceCompleteView: View {
    @ObservedObject var unit: FanCoilUnit
    let onDismiss: () -> Void

    @State private var selectedOutcome: MaintenanceOutcome? = nil
    @State private var isSaved: Bool = false
    @State private var scheduledDate: Date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                if isSaved {
                    savedConfirmationView
                } else {
                    mainSelectionView
                }
            }
            .padding(40)
        }
        .animation(.easeInOut, value: isSaved)
        .animation(.easeInOut, value: selectedOutcome)
    }

    // MARK: - Main Selection
    private var mainSelectionView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                Text("Complete Maintenance")
                    .font(.title)
                    .fontWeight(.bold)
                Text("How would you like to close this maintenance task for \(unit.roomID)?")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }

            VStack(spacing: 16) {
                OutcomeOptionCard(
                    outcome: .markResolved,
                    isSelected: selectedOutcome == .markResolved,
                    onTap: { selectedOutcome = .markResolved }
                )
                OutcomeOptionCard(
                    outcome: .scheduleMaintenance,
                    isSelected: selectedOutcome == .scheduleMaintenance,
                    onTap: { selectedOutcome = .scheduleMaintenance }
                )
            }
            .frame(maxWidth: 500)

            // MARK: - Date Picker (shown when scheduling follow-up)
            if selectedOutcome == .scheduleMaintenance {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Schedule Follow-up Date", systemImage: "calendar")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    DatePicker(
                        "Maintenance Date",
                        selection: $scheduledDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .frame(maxWidth: 500)
                    .padding(16)
                    .background(.thinMaterial)
                    .cornerRadius(16)

                    Text("Selected: \(scheduledDate.formatted(date: .long, time: .omitted))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 500)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if let outcome = selectedOutcome {
                Button(action: { saveOutcome(outcome) }) {
                    Label("Save & Return to Dashboard", systemImage: "arrow.down.doc.fill")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(outcome == .markResolved ? .green : .yellow)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Saved Confirmation
    private var savedConfirmationView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(.green)

            Text("Maintenance Saved")
                .font(.title)
                .fontWeight(.bold)

            if selectedOutcome == .scheduleMaintenance {
                Text("\(unit.roomID) — follow-up scheduled for \(scheduledDate.formatted(date: .long, time: .omitted)).")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("\(unit.roomID) has been updated to \"\(unit.status.rawValue)\".")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onDismiss) {
                Label("Back to Dashboard", systemImage: "square.grid.2x2.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Save Logic
    private func saveOutcome(_ outcome: MaintenanceOutcome) {
        let registry = FCURegistry.shared
        switch outcome {
        case .markResolved:
            registry.updateStatus(for: unit, to: .online)
            unit.repairCount += 1
            unit.scheduledMaintenanceDate = nil
            unit.activeFault = nil
        case .scheduleMaintenance:
            registry.updateStatus(for: unit, to: .maintenance)
            unit.scheduledMaintenanceDate = scheduledDate
        }

        // Log the maintenance record
        registry.addMaintenanceRecord(MaintenanceRecord(
            unitRoomID: unit.roomID,
            unitName: unit.name,
            date: Date(),
            type: unit.status == .criticalError ? .criticalRepair : .scheduledCheck,
            outcome: outcome,
            durationMinutes: Int.random(in: 20...90),
            technician: "T. Batbayar"
        ))

        withAnimation {
            isSaved = true
        }
    }
}

// MARK: - Outcome Option Card
struct OutcomeOptionCard: View {
    let outcome: MaintenanceOutcome
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: outcome.icon)
                    .font(.title2)
                    .foregroundStyle(outcome.color)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(outcome.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(outcome.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? outcome.color : .secondary)
            }
            .padding(20)
            .background(isSelected ? outcome.color.opacity(0.1) : Color.clear)
            .background(.thinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? outcome.color : Color.clear, lineWidth: 2)
            )
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

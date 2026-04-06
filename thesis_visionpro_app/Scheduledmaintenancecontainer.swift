//
//  ScheduledMaintenanceContainer.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar
//

import SwiftUI

struct ScheduledMaintenanceContainer: View {
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

            // TAB 2: Scheduled Tasks Workflow (with inline completion trigger)
            ScheduledTasksView(
                unit: selectedUnit,
                onCompleteMaintenance: {
                    showCompletionView = true
                }
            )
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }

            // TAB 3: Reschedule
            RescheduleMaintenanceView(unit: selectedUnit)
                .tabItem {
                    Label("Reschedule", systemImage: "calendar.badge.clock")
                }

            // TAB 4: Live Stats (unit is still running)
            UnitStatsView(unit: selectedUnit)
                .tabItem {
                    Label("Live Stats", systemImage: "chart.line.uptrend.xyaxis")
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

// MARK: - Reschedule Maintenance View
struct RescheduleMaintenanceView: View {
    @ObservedObject var unit: FanCoilUnit
    @State private var newDate: Date = Date()
    @State private var isSaved: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                if isSaved {
                    // Confirmation
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 60))
                            .foregroundStyle(.green)

                        Text("Maintenance Rescheduled")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("\(unit.roomID) is now scheduled for \(formattedDate(unit.scheduledMaintenanceDate)).")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 400)
                    }
                    .transition(.opacity)
                } else {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 50))
                            .foregroundStyle(.orange)
                        Text("Reschedule Maintenance")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Change the planned maintenance date for \(unit.roomID).")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 400)
                    }

                    // Current date info
                    if let currentDate = unit.scheduledMaintenanceDate {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Currently Scheduled")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(formattedDate(currentDate))
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(.thinMaterial)
                        .cornerRadius(12)
                        .frame(maxWidth: 500)
                    }

                    // Date picker
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Pick a New Date", systemImage: "calendar")
                            .font(.headline)

                        DatePicker(
                            "New Maintenance Date",
                            selection: $newDate,
                            in: Date()...,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .frame(maxWidth: 500)
                        .padding(16)
                        .background(.thinMaterial)
                        .cornerRadius(16)

                        Text("New date: \(formattedDate(newDate))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: 500)

                    // Save button
                    Button {
                        unit.scheduledMaintenanceDate = newDate
                        withAnimation { isSaved = true }
                    } label: {
                        Label("Save New Date", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .frame(maxWidth: 500)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }

                Spacer(minLength: 40)
            }
            .padding(40)
        }
        .onAppear {
            // Pre-fill with current scheduled date or default to 1 week from now
            newDate = unit.scheduledMaintenanceDate
                ?? Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())
                ?? Date()
        }
        .animation(.easeInOut, value: isSaved)
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Not set" }
        return date.formatted(date: .long, time: .omitted)
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .long, time: .omitted)
    }
}

// MARK: - Scheduled Tasks View
struct ScheduledTasksView: View {
    let unit: FanCoilUnit
    let onCompleteMaintenance: () -> Void

    @State private var completedTasks: Set<UUID> = []
    @State private var activeTaskID: UUID? = nil

    // Tasks are now stable (cached in FanCoilUnit) so UUIDs persist across renders
    private var tasks: [MaintenanceTask] {
        unit.scheduledTasks
    }

    private var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTasks.count) / Double(tasks.count)
    }

    private var isAllDone: Bool {
        !tasks.isEmpty && completedTasks.count == tasks.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // MARK: - Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: unit.imageName)
                            .font(.title2)
                            .foregroundStyle(.blue)
                        Text("Scheduled Maintenance")
                            .font(.title)
                            .fontWeight(.bold)
                    }

                    HStack(spacing: 8) {
                        Text("\(unit.roomID) · \(unit.type)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let scheduled = unit.scheduledMaintenanceDate {
                            Text("·")
                                .foregroundStyle(.secondary)
                            Label(scheduled.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                        }
                    }
                }

                // MARK: - Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(completedTasks.count) of \(tasks.count) tasks completed")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "%.0f%%", progress * 100))
                            .font(.headline)
                            .foregroundStyle(isAllDone ? .green : .blue)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isAllDone ? Color.green : Color.blue)
                                .frame(width: geo.size.width * progress)
                                .animation(.easeInOut(duration: 0.4), value: progress)
                        }
                    }
                    .frame(height: 12)
                }
                .padding(20)
                .background(.thinMaterial)
                .cornerRadius(16)

                // MARK: - All Done Banner + Inline Complete Button
                if isAllDone {
                    VStack(spacing: 20) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("All Tasks Completed")
                                    .font(.headline)
                                    .foregroundStyle(.green)
                                Text("You can now log the maintenance outcome.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }

                        Button(action: onCompleteMaintenance) {
                            Label("Complete Maintenance", systemImage: "checkmark.seal.fill")
                                .font(.headline)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                    .padding(20)
                    .background(.green.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.green.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // MARK: - Task List
                VStack(spacing: 0) {
                    ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                        let isCompleted = completedTasks.contains(task.id)
                        let isActive = activeTaskID == task.id

                        VStack(spacing: 0) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if activeTaskID == task.id {
                                        activeTaskID = nil
                                    } else {
                                        activeTaskID = task.id
                                    }
                                }
                            } label: {
                                HStack(spacing: 16) {
                                    // Step number / checkmark
                                    ZStack {
                                        Circle()
                                            .fill(isCompleted ? Color.green : task.priority.color.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        if isCompleted {
                                            Image(systemName: "checkmark")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                        } else {
                                            Text("\(index + 1)")
                                                .font(.headline)
                                                .foregroundStyle(task.priority.color)
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(task.title)
                                            .font(.headline)
                                            .foregroundStyle(isCompleted ? .secondary : .primary)
                                            .strikethrough(isCompleted)

                                        HStack(spacing: 8) {
                                            Label(task.priority.rawValue, systemImage: "flag.fill")
                                                .font(.caption2)
                                                .foregroundStyle(task.priority.color)
                                            Text("·")
                                                .foregroundStyle(.secondary)
                                            Label("~\(task.estimatedMinutes) min", systemImage: "clock")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Image(systemName: isActive ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                            }
                            .buttonStyle(.plain)

                            // Expanded detail
                            if isActive {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: task.icon)
                                            .font(.title3)
                                            .foregroundStyle(.blue)
                                            .frame(width: 28)
                                        Text(task.description)
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                    }

                                    Button {
                                        withAnimation {
                                            if isCompleted {
                                                completedTasks.remove(task.id)
                                            } else {
                                                completedTasks.insert(task.id)
                                                // Auto-advance to next incomplete task
                                                let updatedCompleted = completedTasks
                                                if let nextTask = tasks.first(where: { !updatedCompleted.contains($0.id) }) {
                                                    activeTaskID = nextTask.id
                                                } else {
                                                    activeTaskID = nil
                                                }
                                            }
                                        }
                                    } label: {
                                        Label(isCompleted ? "Mark as Incomplete" : "Mark as Done", systemImage: isCompleted ? "arrow.uturn.backward" : "checkmark.circle.fill")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(isCompleted ? .gray : .green)
                                }
                                .padding(.horizontal, 76)
                                .padding(.bottom, 16)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            if index < tasks.count - 1 {
                                Divider().padding(.leading, 76)
                            }
                        }
                    }
                }
                .background(.thinMaterial)
                .cornerRadius(16)

                Spacer(minLength: 40)
            }
            .padding(40)
        }
    }
}

//
//  FCURegistry.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar on 29.11.25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Maintenance Record
struct MaintenanceRecord: Identifiable {
    let id = UUID()
    let unitRoomID: String
    let unitName: String
    let date: Date
    let type: MaintenanceType
    let outcome: MaintenanceOutcome
    let durationMinutes: Int
    let technician: String
}

enum MaintenanceType: String {
    case criticalRepair = "Critical Repair"
    case scheduledCheck = "Scheduled Check"
    case actuatorReplacement = "Actuator Replacement"
    case filterReplacement = "Filter Replacement"
    case valveService = "Valve Service"
    case sensorCalibration = "Sensor Calibration"

    var icon: String {
        switch self {
        case .criticalRepair: return "exclamationmark.triangle.fill"
        case .scheduledCheck: return "magnifyingglass"
        case .actuatorReplacement: return "wrench.and.screwdriver"
        case .filterReplacement: return "aqi.medium"
        case .valveService: return "valve.fill"
        case .sensorCalibration: return "sensor.fill"
        }
    }
}

// MARK: - Maintenance Task (for workflows)
struct MaintenanceTask: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let estimatedMinutes: Int
    let priority: TaskPriority

    init(id: UUID = UUID(), title: String, description: String, icon: String, estimatedMinutes: Int, priority: TaskPriority) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.estimatedMinutes = estimatedMinutes
        self.priority = priority
    }
}

enum TaskPriority: String {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}

// MARK: - Fan Coil Unit
class FanCoilUnit: Identifiable, Hashable, ObservableObject {
    let id = UUID()
    let name: String
    let roomID: String
    let type: String
    @Published var status: UnitStatus
    let imageName: String
    var repairCount: Int
    var lastMaintenanceDate: Date
    var totalDowntimeHours: Double
    @Published var scheduledMaintenanceDate: Date?

    // Cached tasks so UUIDs remain stable across renders
    private lazy var _scheduledTasks: [MaintenanceTask] = Self.buildTasks(for: type)

    init(name: String, roomID: String, type: String, status: UnitStatus, imageName: String,
         repairCount: Int = 0, lastMaintenanceDate: Date = Date(), totalDowntimeHours: Double = 0,
         scheduledMaintenanceDate: Date? = nil) {
        self.name = name
        self.roomID = roomID
        self.type = type
        self.status = status
        self.imageName = imageName
        self.repairCount = repairCount
        self.lastMaintenanceDate = lastMaintenanceDate
        self.totalDowntimeHours = totalDowntimeHours
        self.scheduledMaintenanceDate = scheduledMaintenanceDate
    }

    // Return stable (cached) tasks — UUIDs persist for the lifetime of the object
    var scheduledTasks: [MaintenanceTask] {
        _scheduledTasks
    }

    private static func buildTasks(for type: String) -> [MaintenanceTask] {
        switch type {
        case "4-Pipe Hydronic":
            return [
                MaintenanceTask(title: "Inspect Control Valve", description: "Check 4-pipe valve assembly for leaks and corrosion. Verify smooth actuation on both heating and cooling circuits.", icon: "valve.fill", estimatedMinutes: 25, priority: .high),
                MaintenanceTask(title: "Replace Air Filter", description: "Remove and replace MERV-13 filter. Inspect filter housing for bypass gaps.", icon: "aqi.medium", estimatedMinutes: 15, priority: .medium),
                MaintenanceTask(title: "Calibrate Temperature Sensor", description: "Compare control sensor reading against handheld reference. Recalibrate if deviation exceeds ±0.5°C.", icon: "sensor.fill", estimatedMinutes: 20, priority: .high),
                MaintenanceTask(title: "Check Condensate Drain", description: "Flush condensate pan and drain line. Verify proper slope and no blockage.", icon: "drop.fill", estimatedMinutes: 10, priority: .low),
            ]
        case "2-Pipe Cooling":
            return [
                MaintenanceTask(title: "Clean Coil Assembly", description: "Vacuum and chemically clean the cooling coil. Check fin spacing for damage or blockage.", icon: "wind", estimatedMinutes: 30, priority: .high),
                MaintenanceTask(title: "Replace Air Filter", description: "Swap out the ceiling-mounted filter cassette. Record filter condition for reporting.", icon: "aqi.medium", estimatedMinutes: 10, priority: .medium),
                MaintenanceTask(title: "Test Fan Motor", description: "Measure motor current draw against nameplate. Listen for bearing noise and check vibration.", icon: "fan.fill", estimatedMinutes: 15, priority: .medium),
            ]
        case "Refrigerant VRF":
            return [
                MaintenanceTask(title: "Check Refrigerant Charge", description: "Connect manifold gauge to service ports. Verify subcooling and superheat values are within spec.", icon: "thermometer.snowflake", estimatedMinutes: 30, priority: .high),
                MaintenanceTask(title: "Clean Indoor Coil", description: "Remove front panel, vacuum coil, and apply coil cleaner spray. Rinse and dry.", icon: "sparkles", estimatedMinutes: 20, priority: .medium),
                MaintenanceTask(title: "Test Electronic Expansion Valve", description: "Verify EEV opening steps via controller diagnostics. Check wiring connections.", icon: "bolt.fill", estimatedMinutes: 25, priority: .high),
                MaintenanceTask(title: "Inspect Wall Mount Brackets", description: "Check mounting hardware for looseness. Tighten and verify unit is level.", icon: "level.fill", estimatedMinutes: 10, priority: .low),
            ]
        case "2-Pipe Heating":
            return [
                MaintenanceTask(title: "Bleed Radiator Circuit", description: "Open bleed valve and release trapped air until steady water flow. Check system pressure after bleeding.", icon: "drop.fill", estimatedMinutes: 15, priority: .high),
                MaintenanceTask(title: "Inspect Heating Valve Actuator", description: "Verify actuator stroke and response time. Check linkage for wear.", icon: "wrench.and.screwdriver", estimatedMinutes: 20, priority: .medium),
                MaintenanceTask(title: "Replace Air Filter", description: "Replace floor-standing unit intake filter. Vacuum surrounding area.", icon: "aqi.medium", estimatedMinutes: 10, priority: .low),
            ]
        default:
            return [
                MaintenanceTask(title: "General Inspection", description: "Perform visual inspection of all components. Check for unusual noise or vibration.", icon: "magnifyingglass", estimatedMinutes: 20, priority: .medium),
                MaintenanceTask(title: "Replace Air Filter", description: "Replace the unit's air filter and inspect housing.", icon: "aqi.medium", estimatedMinutes: 15, priority: .medium),
            ]
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(roomID)
    }

    static func == (lhs: FanCoilUnit, rhs: FanCoilUnit) -> Bool {
        lhs.roomID == rhs.roomID
    }
}

// MARK: - Unit Status
enum UnitStatus: String {
    case online = "Online"
    case criticalError = "Critical Fault"
    case maintenance = "Maintenance Planned"

    var color: Color {
        switch self {
        case .online: return .green
        case .criticalError: return .red
        case .maintenance: return .yellow
        }
    }

    var icon: String {
        switch self {
        case .online: return "checkmark.circle.fill"
        case .criticalError: return "exclamationmark.triangle.fill"
        case .maintenance: return "wrench.fill"
        }
    }
}

// MARK: - Maintenance Outcome
enum MaintenanceOutcome: String {
    case markResolved = "Resolved"
    case scheduleMaintenance = "Follow-up Scheduled"

    var title: String {
        switch self {
        case .markResolved: return "Mark as Resolved"
        case .scheduleMaintenance: return "Book Further Maintenance"
        }
    }

    var subtitle: String {
        switch self {
        case .markResolved: return "Unit is fixed and operational. Status will be set to Online."
        case .scheduleMaintenance: return "Issue needs follow-up. Pick a date for the next maintenance window."
        }
    }

    var icon: String {
        switch self {
        case .markResolved: return "checkmark.circle.fill"
        case .scheduleMaintenance: return "calendar.badge.clock"
        }
    }

    var color: Color {
        switch self {
        case .markResolved: return .green
        case .scheduleMaintenance: return .yellow
        }
    }
}

// MARK: - FCU Registry (Singleton)
@Observable
class FCURegistry {
    static let shared = FCURegistry()

    var availableUnits: [FanCoilUnit] = [
        // — Online (2) —
        FanCoilUnit(name: "Ceiling Cassette", roomID: "BC04H42", type: "2-Pipe Cooling", status: .online, imageName: "fan.ceiling.fill",
                    repairCount: 3, lastMaintenanceDate: Calendar.current.date(byAdding: .day, value: -45, to: Date())!, totalDowntimeHours: 8.5),
        FanCoilUnit(name: "Ducted Concealed", roomID: "BC04H45", type: "4-Pipe Hydronic", status: .online, imageName: "rectangle.split.3x1.fill",
                    repairCount: 1, lastMaintenanceDate: Calendar.current.date(byAdding: .day, value: -12, to: Date())!, totalDowntimeHours: 2.0),

        // — Maintenance Planned (2) —
        FanCoilUnit(name: "Wall Split Unit", roomID: "BC04H43", type: "Refrigerant VRF", status: .maintenance, imageName: "air.conditioner.horizontal.fill",
                    repairCount: 5, lastMaintenanceDate: Calendar.current.date(byAdding: .day, value: -90, to: Date())!, totalDowntimeHours: 18.0,
                    scheduledMaintenanceDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())),
        FanCoilUnit(name: "Floor Standing", roomID: "BC04H46", type: "2-Pipe Heating", status: .maintenance, imageName: "heater.vertical.fill",
                    repairCount: 2, lastMaintenanceDate: Calendar.current.date(byAdding: .day, value: -60, to: Date())!, totalDowntimeHours: 5.5,
                    scheduledMaintenanceDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())),

        // — Critical Fault (2) —
        FanCoilUnit(name: "Vertical Console", roomID: "BC04H41", type: "4-Pipe Hydronic", status: .criticalError, imageName: "cabinet.fill",
                    repairCount: 7, lastMaintenanceDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, totalDowntimeHours: 34.0),
        FanCoilUnit(name: "Horizontal Ceiling", roomID: "BC04H44", type: "4-Pipe Hydronic", status: .criticalError, imageName: "air.purifier.fill",
                    repairCount: 4, lastMaintenanceDate: Calendar.current.date(byAdding: .day, value: -20, to: Date())!, totalDowntimeHours: 12.0),
    ]

    // Simulated maintenance history for analytics
    var maintenanceHistory: [MaintenanceRecord] = [
        MaintenanceRecord(unitRoomID: "BC04H41", unitName: "Vertical Console", date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, type: .criticalRepair, outcome: .scheduleMaintenance, durationMinutes: 95, technician: "T. Batbayar"),
        MaintenanceRecord(unitRoomID: "BC04H41", unitName: "Vertical Console", date: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, type: .actuatorReplacement, outcome: .markResolved, durationMinutes: 60, technician: "T. Batbayar"),
        MaintenanceRecord(unitRoomID: "BC04H41", unitName: "Vertical Console", date: Calendar.current.date(byAdding: .day, value: -58, to: Date())!, type: .sensorCalibration, outcome: .markResolved, durationMinutes: 25, technician: "M. Weber"),
        MaintenanceRecord(unitRoomID: "BC04H42", unitName: "Ceiling Cassette", date: Calendar.current.date(byAdding: .day, value: -45, to: Date())!, type: .filterReplacement, outcome: .markResolved, durationMinutes: 15, technician: "T. Batbayar"),
        MaintenanceRecord(unitRoomID: "BC04H42", unitName: "Ceiling Cassette", date: Calendar.current.date(byAdding: .day, value: -100, to: Date())!, type: .scheduledCheck, outcome: .markResolved, durationMinutes: 30, technician: "M. Weber"),
        MaintenanceRecord(unitRoomID: "BC04H43", unitName: "Wall Split Unit", date: Calendar.current.date(byAdding: .day, value: -90, to: Date())!, type: .valveService, outcome: .scheduleMaintenance, durationMinutes: 45, technician: "T. Batbayar"),
        MaintenanceRecord(unitRoomID: "BC04H43", unitName: "Wall Split Unit", date: Calendar.current.date(byAdding: .day, value: -120, to: Date())!, type: .criticalRepair, outcome: .markResolved, durationMinutes: 110, technician: "M. Weber"),
        MaintenanceRecord(unitRoomID: "BC04H44", unitName: "Horizontal Ceiling", date: Calendar.current.date(byAdding: .day, value: -20, to: Date())!, type: .criticalRepair, outcome: .scheduleMaintenance, durationMinutes: 80, technician: "T. Batbayar"),
        MaintenanceRecord(unitRoomID: "BC04H44", unitName: "Horizontal Ceiling", date: Calendar.current.date(byAdding: .day, value: -55, to: Date())!, type: .filterReplacement, outcome: .markResolved, durationMinutes: 15, technician: "M. Weber"),
        MaintenanceRecord(unitRoomID: "BC04H45", unitName: "Ducted Concealed", date: Calendar.current.date(byAdding: .day, value: -12, to: Date())!, type: .scheduledCheck, outcome: .markResolved, durationMinutes: 20, technician: "T. Batbayar"),
        MaintenanceRecord(unitRoomID: "BC04H46", unitName: "Floor Standing", date: Calendar.current.date(byAdding: .day, value: -60, to: Date())!, type: .filterReplacement, outcome: .markResolved, durationMinutes: 15, technician: "M. Weber"),
        MaintenanceRecord(unitRoomID: "BC04H46", unitName: "Floor Standing", date: Calendar.current.date(byAdding: .day, value: -130, to: Date())!, type: .scheduledCheck, outcome: .markResolved, durationMinutes: 25, technician: "T. Batbayar"),
    ]

    func updateStatus(for unit: FanCoilUnit, to newStatus: UnitStatus) {
        unit.status = newStatus
    }

    func addMaintenanceRecord(_ record: MaintenanceRecord) {
        maintenanceHistory.insert(record, at: 0)
    }

    // MARK: - Analytics Computed Properties
    var totalRepairs: Int {
        availableUnits.reduce(0) { $0 + $1.repairCount }
    }

    var totalDowntime: Double {
        availableUnits.reduce(0) { $0 + $1.totalDowntimeHours }
    }

    var mostRepairedUnit: FanCoilUnit? {
        availableUnits.max(by: { $0.repairCount < $1.repairCount })
    }

    var averageRepairTime: Int {
        guard !maintenanceHistory.isEmpty else { return 0 }
        return maintenanceHistory.reduce(0) { $0 + $1.durationMinutes } / maintenanceHistory.count
    }

    var onlinePercentage: Double {
        guard !availableUnits.isEmpty else { return 0 }
        let onlineCount = availableUnits.filter { $0.status == .online }.count
        return Double(onlineCount) / Double(availableUnits.count) * 100
    }

    var unitsByRepairCount: [FanCoilUnit] {
        availableUnits.sorted { $0.repairCount > $1.repairCount }
    }

    var recentHistory: [MaintenanceRecord] {
        Array(maintenanceHistory.prefix(5))
    }
}

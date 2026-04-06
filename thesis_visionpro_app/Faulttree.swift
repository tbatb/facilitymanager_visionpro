//
//  FaultTreeView.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar
//

import SwiftUI

// MARK: - Fault Tree Node Model

enum FTAGateType: String {
    case or = "OR"
    case and = "AND"
}

enum FTANodeType {
    case topEvent
    case gate(FTAGateType)
    case intermediateEvent
    case basicEvent
}

struct FTANode: Identifiable {
    let id: String            // e.g., "T1", "B2", "G1", "Q1"
    let label: String
    let detail: String
    let nodeType: FTANodeType
    let icon: String
    var children: [String]    // IDs of child nodes
    var isOnActivePath: Bool  // Highlighted red if part of current fault path
}

// MARK: - Fault Tree Data Builder

class FaultTreeData {
    /// Build the fault tree for the FCU Temperature Anomaly scenario.
    /// Matches thesis Figure 4.3 — simplified to key branches for readability.
    static func buildFCUFaultTree(fcuModel: FCUModel) -> [FTANode] {
        let isLogicTrap = fcuModel.isLogicTrapDetected
        let activePath: Set<String> = isLogicTrap
            ? ["T1", "OR_TOP", "B2", "G1", "Q1", "B4", "N1"]
            : []

        return [
            // ── TOP EVENT ──
            FTANode(id: "T1",
                    label: "Room Temperature > 22°C",
                    detail: "The top-level undesired event. Physical duct sensor reads \(String(format: "%.2f", fcuModel.ductDischargeTemp))°C.",
                    nodeType: .topEvent, icon: "thermometer.sun.fill",
                    children: ["OR_TOP"],
                    isOnActivePath: activePath.contains("T1")),

            // ── TOP OR GATE ──
            FTANode(id: "OR_TOP",
                    label: "OR",
                    detail: "Any of the following branches can cause the top event.",
                    nodeType: .gate(.or), icon: "arrow.triangle.branch",
                    children: ["B1", "B2", "B3", "B4", "B5", "B7"],
                    isOnActivePath: activePath.contains("OR_TOP")),

            // ══════════════════════════════════════════════
            // BRANCH B1: Actuator / Control Failure
            // ══════════════════════════════════════════════
            FTANode(id: "B1",
                    label: "Actuator / Control Failure",
                    detail: "Physical actuator or valve hardware has failed, preventing correct control action.",
                    nodeType: .intermediateEvent, icon: "gearshape.2.fill",
                    children: ["C1", "C2", "C3", "C4"],
                    isOnActivePath: false),
            FTANode(id: "C1", label: "Actuator Motor Damaged", detail: "Motor windings or gear train failure prevents actuator movement.", nodeType: .basicEvent, icon: "bolt.slash.fill", children: [], isOnActivePath: false),
            FTANode(id: "C2", label: "Valve Fault", detail: "Valve body stuck, corroded, or mechanically jammed.", nodeType: .basicEvent, icon: "valve.fill", children: [], isOnActivePath: false),
            FTANode(id: "C3", label: "Manual Override Active", detail: "Valve has been manually forced to a position, overriding BMS control.", nodeType: .basicEvent, icon: "hand.raised.fill", children: [], isOnActivePath: false),
            FTANode(id: "C4", label: "No 24V AC Supply", detail: "Power supply to the actuator is interrupted — check fuse and transformer.", nodeType: .basicEvent, icon: "powerplug.fill", children: [], isOnActivePath: false),

            // ══════════════════════════════════════════════
            // BRANCH B2: Software Failure (ACTIVE PATH)
            // ══════════════════════════════════════════════
            FTANode(id: "B2",
                    label: "Software Failure",
                    detail: "The control algorithm or its configuration causes incorrect behavior.",
                    nodeType: .intermediateEvent, icon: "laptopcomputer.trianglebadge.exclamationmark",
                    children: ["G1", "B3_sw", "B4_sw", "B5_sw"],
                    isOnActivePath: activePath.contains("B2")),

            FTANode(id: "G1",
                    label: "Logic Trap (G1)",
                    detail: "Controller logic is valid, but inputs conflict with physical reality. Sensor reads \(String(format: "%.2f", fcuModel.controlSensorTemp))°C (< setpoint \(String(format: "%.2f", fcuModel.setpointTemp))°C), so valve output = \(String(format: "%.0f", fcuModel.valveOutput))%. Meanwhile duct = \(String(format: "%.2f", fcuModel.ductDischargeTemp))°C.",
                    nodeType: .intermediateEvent, icon: "exclamationmark.triangle.fill",
                    children: ["Q1"],
                    isOnActivePath: activePath.contains("G1")),

            FTANode(id: "Q1",
                    label: "Data Conflict (Q1)",
                    detail: "Control sensor and physical duct sensor disagree by \(String(format: "%.2f", fcuModel.ductDischargeTemp - fcuModel.controlSensorTemp))°C. Root cause: sensor drift or miscalibration.",
                    nodeType: .basicEvent, icon: "sensor.fill",
                    children: [],
                    isOnActivePath: activePath.contains("Q1")),

            FTANode(id: "B3_sw", label: "Configuration Mismatch", detail: "BMS parameters do not match the physical installation.", nodeType: .basicEvent, icon: "doc.badge.gearshape.fill", children: [], isOnActivePath: false),
            FTANode(id: "B4_sw", label: "Control Algorithm Bug", detail: "PI loop tuning or sequence logic error.", nodeType: .basicEvent, icon: "ladybug.fill", children: [], isOnActivePath: false),
            FTANode(id: "B5_sw", label: "Firmware Update Failure", detail: "Controller firmware is outdated or partially updated.", nodeType: .basicEvent, icon: "arrow.triangle.2.circlepath", children: [], isOnActivePath: false),

            // ══════════════════════════════════════════════
            // BRANCH B3: Mechanical / HVAC Failure
            // ══════════════════════════════════════════════
            FTANode(id: "B3",
                    label: "Mechanical / HVAC Failure",
                    detail: "Physical HVAC components have degraded or failed.",
                    nodeType: .intermediateEvent, icon: "fan.fill",
                    children: ["H4", "H6", "H8", "H9"],
                    isOnActivePath: false),
            FTANode(id: "H4", label: "Fan Fault", detail: "Fan motor, bearing, or electrical fault reducing airflow.", nodeType: .basicEvent, icon: "fan.slash.fill", children: [], isOnActivePath: false),
            FTANode(id: "H6", label: "Cooling Register Dirty", detail: "Coil fins blocked by dust — reduced heat transfer.", nodeType: .basicEvent, icon: "aqi.medium", children: [], isOnActivePath: false),
            FTANode(id: "H8", label: "Manual Mode Active", detail: "Unit has been switched to manual mode at the local controller.", nodeType: .basicEvent, icon: "hand.raised.fill", children: [], isOnActivePath: false),
            FTANode(id: "H9", label: "Coil Fouling", detail: "Scale buildup or corrosion inside the coil tubes.", nodeType: .basicEvent, icon: "drop.triangle.fill", children: [], isOnActivePath: false),

            // ══════════════════════════════════════════════
            // BRANCH B4: Sensor / Data Problem
            // ══════════════════════════════════════════════
            FTANode(id: "B4",
                    label: "Sensor / Data Problem",
                    detail: "Sensor hardware or data transmission issues causing incorrect readings.",
                    nodeType: .intermediateEvent, icon: "sensor.fill",
                    children: ["N1", "N5", "N4", "N6"],
                    isOnActivePath: activePath.contains("B4")),

            FTANode(id: "N1",
                    label: "Calibration Issues",
                    detail: "Control sensor has drifted from factory calibration — reading \(String(format: "%.2f", fcuModel.controlSensorTemp))°C instead of true room temp.",
                    nodeType: .basicEvent, icon: "tuningfork",
                    children: [],
                    isOnActivePath: activePath.contains("N1")),
            FTANode(id: "N5", label: "Info Inaccuracy", detail: "Dashboard displays stale or rounded values.", nodeType: .basicEvent, icon: "clock.arrow.circlepath", children: [], isOnActivePath: false),
            FTANode(id: "N4", label: "Sensor Signal Loss", detail: "Wiring fault or power interruption to the sensor.", nodeType: .basicEvent, icon: "bolt.slash.fill", children: [], isOnActivePath: false),
            FTANode(id: "N6", label: "Contamination", detail: "Sensor probe covered in dust or moisture, affecting reading.", nodeType: .basicEvent, icon: "drop.fill", children: [], isOnActivePath: false),

            // ══════════════════════════════════════════════
            // BRANCH B5: Operational / Human Error
            // ══════════════════════════════════════════════
            FTANode(id: "B5",
                    label: "Operational / Human Error",
                    detail: "Errors introduced by operators or maintenance staff.",
                    nodeType: .intermediateEvent, icon: "person.fill.questionmark",
                    children: ["S1", "S2"],
                    isOnActivePath: false),
            FTANode(id: "S1", label: "Human Factors", detail: "Fatigue, distraction, or insufficient training.", nodeType: .basicEvent, icon: "person.wave.2.fill", children: [], isOnActivePath: false),
            FTANode(id: "S2", label: "Operational Mistakes", detail: "Incorrect setpoint entry, improper tool use, or skipped step.", nodeType: .basicEvent, icon: "xmark.circle.fill", children: [], isOnActivePath: false),

            // ══════════════════════════════════════════════
            // BRANCH B7: Procedure Execution Error
            // ══════════════════════════════════════════════
            FTANode(id: "B7",
                    label: "Procedure Execution Error",
                    detail: "Maintenance SOP not followed correctly.",
                    nodeType: .intermediateEvent, icon: "list.bullet.clipboard.fill",
                    children: ["Y3", "Y1", "Y2"],
                    isOnActivePath: false),
            FTANode(id: "Y3", label: "Incomplete Logging", detail: "Maintenance actions not recorded — lost knowledge.", nodeType: .basicEvent, icon: "doc.questionmark.fill", children: [], isOnActivePath: false),
            FTANode(id: "Y1", label: "Post-Repair Verification Skipped", detail: "System self-test not performed after repair.", nodeType: .basicEvent, icon: "checkmark.circle.trianglebadge.exclamationmark", children: [], isOnActivePath: false),
            FTANode(id: "Y2", label: "Voltage Check Discipline", detail: "24V supply not verified before closing ticket.", nodeType: .basicEvent, icon: "bolt.fill", children: [], isOnActivePath: false),
        ]
    }
}

// MARK: - Fault Tree View (Interactive Visualization)

struct FaultTreeView: View {
    @State private var fcuData = FCUModel()
    @State private var nodes: [FTANode] = []
    @State private var selectedNode: FTANode? = nil
    @State private var expandedBranches: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        Text("Interactive Fault Tree Analysis")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Text("Tap any branch to expand and inspect. The active fault path is highlighted in red.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // MARK: - Active Fault Path Summary
                if fcuData.isLogicTrapDetected {
                    activeFaultPathBanner
                }

                // MARK: - Tree Visualization
                if let topNode = nodes.first(where: { $0.id == "T1" }) {
                    FTANodeView(
                        node: topNode,
                        allNodes: nodes,
                        depth: 0,
                        expandedBranches: $expandedBranches,
                        selectedNode: $selectedNode
                    )
                }

                // MARK: - Legend
                faultTreeLegend

                Spacer(minLength: 40)
            }
            .padding(40)
        }
        .onAppear {
            fcuData.refreshData()
            nodes = FaultTreeData.buildFCUFaultTree(fcuModel: fcuData)
            // Auto-expand the active fault path
            if fcuData.isLogicTrapDetected {
                expandedBranches = ["T1", "OR_TOP", "B2", "G1", "B4"]
            }
        }
        .sheet(item: $selectedNode) { node in
            NodeDetailSheet(node: node, fcuData: fcuData)
        }
    }

    // MARK: - Active Fault Path Banner
    private var activeFaultPathBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                Text("ACTIVE FAULT PATH DETECTED")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
            }

            // Visual fault path chain
            HStack(spacing: 6) {
                FaultPathChip(label: "T1", sublabel: "Room > 22°C")
                Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.6)).font(.caption2)
                FaultPathChip(label: "B2", sublabel: "Software")
                Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.6)).font(.caption2)
                FaultPathChip(label: "G1", sublabel: "Logic Trap")
                Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.6)).font(.caption2)
                FaultPathChip(label: "Q1", sublabel: "Data Conflict")
            }

            Text("Controller reads \(String(format: "%.2f°C", fcuData.controlSensorTemp)) < setpoint \(String(format: "%.2f°C", fcuData.setpointTemp)), so valve = \(String(format: "%.0f%%", fcuData.valveOutput)). But duct sensor = \(String(format: "%.2f°C", fcuData.ductDischargeTemp)).")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))

            Text("Recommended Action: Recalibrate control sensor (Node N1) or replace sensor probe.")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.yellow)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.85))
        .cornerRadius(16)
    }

    // MARK: - Legend
    private var faultTreeLegend: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Legend")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                LegendItem(color: .red, label: "Active Fault Path")
                LegendItem(color: .blue, label: "Intermediate Event")
                LegendItem(color: .secondary, label: "Basic Event")
                LegendItem(color: .purple, label: "Logic Gate (OR/AND)")
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Fault Path Chip
struct FaultPathChip: View {
    let label: String
    let sublabel: String

    var body: some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(.caption2, design: .monospaced))
                .fontWeight(.bold)
            Text(sublabel)
                .font(.system(size: 9))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.white.opacity(0.2))
        .cornerRadius(6)
    }
}

// MARK: - Legend Item
struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Recursive FTA Node View

struct FTANodeView: View {
    let node: FTANode
    let allNodes: [FTANode]
    let depth: Int
    @Binding var expandedBranches: Set<String>
    @Binding var selectedNode: FTANode?

    private var isExpanded: Bool {
        expandedBranches.contains(node.id)
    }

    private var childNodes: [FTANode] {
        node.children.compactMap { childID in
            allNodes.first(where: { $0.id == childID })
        }
    }

    private var hasChildren: Bool {
        !node.children.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Node row
            Button {
                if hasChildren {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if isExpanded {
                            expandedBranches.remove(node.id)
                        } else {
                            expandedBranches.insert(node.id)
                        }
                    }
                } else {
                    selectedNode = node
                }
            } label: {
                HStack(spacing: 12) {
                    // Depth indent line
                    if depth > 0 {
                        ForEach(0..<depth, id: \.self) { _ in
                            Rectangle()
                                .fill(node.isOnActivePath ? Color.red.opacity(0.3) : Color.gray.opacity(0.15))
                                .frame(width: 2)
                        }
                    }

                    // Node icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(nodeBackgroundColor)
                            .frame(width: 36, height: 36)
                        Image(systemName: node.icon)
                            .font(.subheadline)
                            .foregroundStyle(nodeIconColor)
                    }

                    // Node content
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(node.id)
                                .font(.system(.caption2, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundStyle(node.isOnActivePath ? .red : .secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(node.isOnActivePath ? Color.red.opacity(0.15) : Color.gray.opacity(0.1))
                                .cornerRadius(4)

                            if case .gate(let type) = node.nodeType {
                                Text(type.rawValue)
                                    .font(.system(.caption2, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.purple)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.purple.opacity(0.12))
                                    .cornerRadius(4)
                            }
                        }

                        Text(node.label)
                            .font(.subheadline)
                            .fontWeight(node.isOnActivePath ? .bold : .medium)
                            .foregroundStyle(node.isOnActivePath ? .red : .primary)

                        if !hasChildren {
                            Text(node.detail)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }

                    Spacer()

                    // Expand/collapse chevron
                    if hasChildren {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(node.isOnActivePath ? Color.red.opacity(0.06) : Color.clear)
            }
            .buttonStyle(.plain)

            // Children (when expanded)
            if isExpanded {
                ForEach(childNodes) { child in
                    FTANodeView(
                        node: child,
                        allNodes: allNodes,
                        depth: depth + 1,
                        expandedBranches: $expandedBranches,
                        selectedNode: $selectedNode
                    )
                }
            }

            if depth == 0 {
                Divider().padding(.leading, 16)
            }
        }
    }

    // MARK: - Styling

    private var nodeBackgroundColor: Color {
        if node.isOnActivePath { return Color.red.opacity(0.15) }
        switch node.nodeType {
        case .topEvent: return Color.red.opacity(0.12)
        case .gate: return Color.purple.opacity(0.12)
        case .intermediateEvent: return Color.blue.opacity(0.1)
        case .basicEvent: return Color.gray.opacity(0.1)
        }
    }

    private var nodeIconColor: Color {
        if node.isOnActivePath { return .red }
        switch node.nodeType {
        case .topEvent: return .red
        case .gate: return .purple
        case .intermediateEvent: return .blue
        case .basicEvent: return .secondary
        }
    }
}

// MARK: - Node Detail Sheet

struct NodeDetailSheet: View {
    let node: FTANode
    let fcuData: FCUModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Node Header
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(node.isOnActivePath ? Color.red.opacity(0.15) : Color.blue.opacity(0.1))
                                .frame(width: 52, height: 52)
                            Image(systemName: node.icon)
                                .font(.title3)
                                .foregroundStyle(node.isOnActivePath ? .red : .blue)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(node.id)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(node.isOnActivePath ? .red : .secondary)
                            Text(node.label)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }

                    // Active path badge
                    if node.isOnActivePath {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.white)
                            Text("This node is on the ACTIVE fault path")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red)
                        .cornerRadius(10)
                    }

                    // Detail description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(node.detail)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    // Live data (if relevant)
                    if node.isOnActivePath {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Live Sensor Data")
                                .font(.headline)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                LiveDataCell(label: "Control Sensor", value: String(format: "%.2f°C", fcuData.controlSensorTemp), color: .orange)
                                LiveDataCell(label: "Setpoint", value: String(format: "%.2f°C", fcuData.setpointTemp), color: .blue)
                                LiveDataCell(label: "Duct Discharge", value: String(format: "%.2f°C", fcuData.ductDischargeTemp), color: .red)
                                LiveDataCell(label: "Valve Output", value: String(format: "%.0f%%", fcuData.valveOutput), color: .purple)
                            }
                        }
                    }

                    // Children list
                    if !node.children.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Child Nodes")
                                .font(.headline)
                            Text("This node has \(node.children.count) child node(s): \(node.children.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(30)
            }
            .navigationTitle("Node \(node.id)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Live Data Cell
struct LiveDataCell: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }
}

// Make FTANode identifiable for sheet presentation
extension FTANode: Hashable {
    static func == (lhs: FTANode, rhs: FTANode) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}


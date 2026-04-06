//
//  FaultCatalog.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar
//

import Foundation
import SwiftUI

// MARK: - Maintenance Step (moved here from ProcedureModel.swift)
struct MaintenanceStep: Identifiable {
    let id = UUID()
    let number: Int
    let description: String
    let icon: String // SF Symbol name for visual aid
}

// MARK: - Procedure Model (Actuator Replacement — original thesis procedure)
class ProcedureModel {
    static let replacementSteps: [MaintenanceStep] = [
        MaintenanceStep(number: 1, description: "Identify the defective Actuator. \n(See Red Highlight in AR)", icon: "exclamationmark.triangle.fill"),
        MaintenanceStep(number: 2, description: "Locate the textured metal ring at the base of the Sauter actuator.", icon: "circle.grid.cross.fill"),
        MaintenanceStep(number: 3, description: "Rotate the metal ring COUNTER-CLOCKWISE to loosen.", icon: "arrow.counterclockwise.circle.fill"),
        MaintenanceStep(number: 4, description: "Pull the white actuator body gently upwards to remove.", icon: "arrow.up.circle.fill"),
        MaintenanceStep(number: 5, description: "Inspect the valve pin (metal pin) for corrosion or seizure.", icon: "magnifyingglass"),
        MaintenanceStep(number: 6, description: "Place the NEW actuator (Sauter) onto the valve thread.", icon: "arrow.down.circle.fill"),
        MaintenanceStep(number: 7, description: "Tighten the metal ring CLOCKWISE until hand-tight.", icon: "arrow.clockwise.circle.fill"),
        MaintenanceStep(number: 8, description: "Reconnect the 24V power cable.", icon: "powerplug.fill"),
    ]
}

// MARK: - Fault Type (maps to fault tree leaf nodes from Figure 4.3)
enum FaultType: String, CaseIterable, Identifiable {
    // B1 — Actuator / Control Failure
    case actuatorStuck       = "C3 Actuator Stuck"
    case valveFault          = "C2 Valve Fault"
    case no24VSupply         = "C4 No 24V AC Supply"
    case actuatorMotor       = "E1 Actuator Motor Damaged"

    // B2 — Software Failure
    case logicTrap           = "G1 Logic Trap"
    case configMismatch      = "B9 Configuration Mismatch"
    case firmwareFailure     = "S2 Firmware Update Failure"

    // B3 — Mechanical / HVAC Hardware Failure
    case fanFault            = "R4 Fan Fault"
    case filterClogged       = "K3 Filter Clogged"
    case coilFouling         = "B5 Coil Fouling"
    case pumpMalfunction     = "M3 Pump Malfunction"

    // B4 — Sensor / Data Problem
    case sensorCalibration   = "R1 Calibration Issue"
    case sensorSignalLoss    = "M4 Sensor Signal Loss"

    var id: String { rawValue }

    // MARK: - Display Properties

    var title: String { rawValue }

    var branch: String {
        switch self {
        case .actuatorStuck, .valveFault, .no24VSupply, .actuatorMotor:
            return "B1 Actuator/Control Failure"
        case .logicTrap, .configMismatch, .firmwareFailure:
            return "B2 Software Failure"
        case .fanFault, .filterClogged, .coilFouling, .pumpMalfunction:
            return "B3 Mechanical/HVAC Failure"
        case .sensorCalibration, .sensorSignalLoss:
            return "B4 Sensor/Data Problem"
        }
    }

    var faultPath: String {
        switch self {
        case .actuatorStuck:     return "B1 → C3 Actuator Stuck → D2 Mechanical Jamming"
        case .valveFault:        return "B1 → C2 Valve Fault → F1 Threads Not Sealing"
        case .no24VSupply:       return "B1 → C4 No 24V AC → E1 Battery Depleted"
        case .actuatorMotor:     return "B1 → E1 Actuator Motor → D1 Incorrect Heating"
        case .logicTrap:         return "B2 → G1 Logic Trap → Q1 Data Conflict"
        case .configMismatch:    return "B2 → B9 Configuration Mismatch"
        case .firmwareFailure:   return "B2 → S2 Firmware Update Failure"
        case .fanFault:          return "B3 → R4 Fan Fault → I8 Electrical Fault"
        case .filterClogged:     return "B3 → H8 Cooling Register → K3 Filter Clogged"
        case .coilFouling:       return "B3 → B5 Coil Fouling → M3 Corrosion"
        case .pumpMalfunction:   return "B3 → M3 Pump Malfunction → J4 Sensor Failure"
        case .sensorCalibration: return "B4 → R1 Calibration Issue → O3 Drift"
        case .sensorSignalLoss:  return "B4 → M4 Signal Loss → R2 Power Interruption"
        }
    }

    var diagnosticSummary: String {
        switch self {
        case .actuatorStuck:
            return "Actuator is mechanically jammed and does not respond to control signals. Valve position remains fixed despite output commands."
        case .valveFault:
            return "Control valve is leaking or not sealing properly. Flow regulation is compromised, causing unstable temperature control."
        case .no24VSupply:
            return "Actuator has lost 24V AC power supply. No motor movement detected. Check transformer and wiring."
        case .actuatorMotor:
            return "Actuator motor is damaged — abnormal current draw or no rotation detected. Motor replacement required."
        case .logicTrap:
            return "Controller logic is valid but input data conflicts with physical reality. Sensor reads 19.96°C while duct discharge is 24.47°C."
        case .configMismatch:
            return "Controller configuration parameters do not match the installed hardware. Setpoints, PID tuning, or I/O mapping may be incorrect."
        case .firmwareFailure:
            return "Recent firmware update has corrupted controller behavior. System operating on fallback logic with degraded functionality."
        case .fanFault:
            return "Fan motor has failed or is operating outside normal parameters. No airflow or reduced airflow detected across the coil."
        case .filterClogged:
            return "Air filter is severely clogged, restricting airflow. Pressure differential across filter exceeds threshold."
        case .coilFouling:
            return "Heat exchanger coil is fouled with scale, corrosion, or biological growth. Heat transfer efficiency significantly reduced."
        case .pumpMalfunction:
            return "Circulation pump has failed or is cavitating. No water flow detected through the hydronic circuit."
        case .sensorCalibration:
            return "Temperature sensor has drifted beyond ±0.5°C tolerance. Readings are consistently offset from reference measurements."
        case .sensorSignalLoss:
            return "Sensor signal has been lost — possible wiring fault, power interruption, or sensor hardware failure."
        }
    }

    var icon: String {
        switch self {
        case .actuatorStuck:     return "lock.fill"
        case .valveFault:        return "valve.fill"
        case .no24VSupply:       return "powerplug.fill"
        case .actuatorMotor:     return "gear.badge.xmark"
        case .logicTrap:         return "brain.head.profile"
        case .configMismatch:    return "slider.horizontal.2.gobackward"
        case .firmwareFailure:   return "cpu"
        case .fanFault:          return "fan.fill"
        case .filterClogged:     return "aqi.medium"
        case .coilFouling:       return "humidity.fill"
        case .pumpMalfunction:   return "drop.triangle.fill"
        case .sensorCalibration: return "sensor.fill"
        case .sensorSignalLoss:  return "antenna.radiowaves.left.and.right.slash"
        }
    }

    var color: Color {
        switch self {
        case .actuatorStuck, .valveFault, .no24VSupply, .actuatorMotor:
            return .red
        case .logicTrap, .configMismatch, .firmwareFailure:
            return .purple
        case .fanFault, .filterClogged, .coilFouling, .pumpMalfunction:
            return .orange
        case .sensorCalibration, .sensorSignalLoss:
            return .yellow
        }
    }

    // MARK: - Repair Steps (step-by-step repair procedure for each fault)

    var repairTitle: String {
        switch self {
        case .actuatorStuck:     return "Actuator Unjamming Procedure"
        case .valveFault:        return "Valve Repair / Reseating Procedure"
        case .no24VSupply:       return "24V AC Power Restoration"
        case .actuatorMotor:     return "Actuator Motor Replacement"
        case .logicTrap:         return "Logic Trap Resolution (Sensor Recalibration)"
        case .configMismatch:    return "Controller Configuration Correction"
        case .firmwareFailure:   return "Firmware Rollback Procedure"
        case .fanFault:          return "Fan Motor Replacement"
        case .filterClogged:     return "Air Filter Replacement"
        case .coilFouling:       return "Coil Cleaning Procedure"
        case .pumpMalfunction:   return "Circulation Pump Service"
        case .sensorCalibration: return "Temperature Sensor Recalibration"
        case .sensorSignalLoss:  return "Sensor Wiring & Signal Restoration"
        }
    }

    var repairSteps: [MaintenanceStep] {
        switch self {

        case .actuatorStuck:
            return [
                MaintenanceStep(number: 1, description: "Isolate the FCU from the BMS by switching to manual override.", icon: "power"),
                MaintenanceStep(number: 2, description: "Disconnect the 24V power cable from the actuator.", icon: "powerplug.fill"),
                MaintenanceStep(number: 3, description: "Twist the metal locking ring counter-clockwise to release the actuator body.", icon: "arrow.counterclockwise.circle.fill"),
                MaintenanceStep(number: 4, description: "Lift the actuator off the valve stem. Inspect the valve pin for corrosion or debris.", icon: "arrow.up.circle.fill"),
                MaintenanceStep(number: 5, description: "Apply penetrating lubricant to the valve stem. Work the pin up and down until it moves freely.", icon: "drop.fill"),
                MaintenanceStep(number: 6, description: "Clean the actuator mounting surface and valve thread of debris.", icon: "sparkles"),
                MaintenanceStep(number: 7, description: "Reseat the actuator onto the valve stem and tighten the locking ring clockwise.", icon: "arrow.clockwise.circle.fill"),
                MaintenanceStep(number: 8, description: "Reconnect 24V power. Verify actuator responds to 0% and 100% commands from BMS.", icon: "checkmark.circle.fill"),
            ]

        case .valveFault:
            return [
                MaintenanceStep(number: 1, description: "Close upstream and downstream isolation valves. Drain residual water from the line.", icon: "drop.triangle.fill"),
                MaintenanceStep(number: 2, description: "Remove the actuator from the valve body (counter-clockwise locking ring).", icon: "arrow.counterclockwise.circle.fill"),
                MaintenanceStep(number: 3, description: "Unscrew the valve bonnet from the body using a pipe wrench.", icon: "wrench.fill"),
                MaintenanceStep(number: 4, description: "Inspect the valve seat and disc for scoring, pitting, or debris. Clean with a brass brush.", icon: "magnifyingglass"),
                MaintenanceStep(number: 5, description: "Replace the valve packing and O-rings. Apply thread sealant (PTFE tape) to all joints.", icon: "seal.fill"),
                MaintenanceStep(number: 6, description: "Reassemble valve body, tighten bonnet to spec. Remount actuator.", icon: "arrow.clockwise.circle.fill"),
                MaintenanceStep(number: 7, description: "Open isolation valves slowly. Check all joints for leaks under pressure.", icon: "drop.fill"),
                MaintenanceStep(number: 8, description: "Test valve stroke from BMS — verify 0%, 50%, 100% positions.", icon: "checkmark.circle.fill"),
            ]

        case .no24VSupply:
            return [
                MaintenanceStep(number: 1, description: "Check the 24V AC transformer fuse at the electrical panel. Replace if blown.", icon: "bolt.trianglebadge.exclamationmark.fill"),
                MaintenanceStep(number: 2, description: "Measure output voltage at the transformer secondary with a multimeter. Expect 24V AC ±10%.", icon: "gauge.with.dots.needle.33percent"),
                MaintenanceStep(number: 3, description: "Trace the wiring from the transformer to the actuator terminal block. Look for breaks or loose crimps.", icon: "cable.connector"),
                MaintenanceStep(number: 4, description: "Check for water ingress or corrosion at junction boxes along the cable run.", icon: "drop.triangle.fill"),
                MaintenanceStep(number: 5, description: "Re-terminate any damaged wire ends with proper ferrules. Tighten terminal screws.", icon: "wrench.and.screwdriver.fill"),
                MaintenanceStep(number: 6, description: "Measure 24V AC at the actuator plug to confirm power is restored.", icon: "powerplug.fill"),
                MaintenanceStep(number: 7, description: "Reconnect the actuator. Verify motor spins and responds to BMS commands.", icon: "checkmark.circle.fill"),
            ]

        case .actuatorMotor:
            return ProcedureModel.replacementSteps  // existing 8-step actuator replacement

        case .logicTrap:
            return [
                MaintenanceStep(number: 1, description: "Record current BMS readings: Control Sensor, Setpoint, Valve Output, and Duct Discharge Temperature.", icon: "doc.text.fill"),
                MaintenanceStep(number: 2, description: "Place a calibrated handheld thermometer at the control sensor location. Compare readings.", icon: "thermometer.medium"),
                MaintenanceStep(number: 3, description: "If deviation > ±0.5°C: the control sensor is faulty. Proceed to replace or recalibrate it.", icon: "exclamationmark.triangle.fill"),
                MaintenanceStep(number: 4, description: "Disconnect the sensor cable from the controller terminal block.", icon: "cable.connector"),
                MaintenanceStep(number: 5, description: "Install the replacement NTC/PT1000 sensor at the same mounting point. Secure with cable ties.", icon: "sensor.fill"),
                MaintenanceStep(number: 6, description: "Reconnect the sensor cable. Verify the BMS now reads within ±0.3°C of the handheld reference.", icon: "checkmark.circle.fill"),
                MaintenanceStep(number: 7, description: "Monitor for 10 minutes: confirm valve output responds correctly to the corrected temperature signal.", icon: "clock.fill"),
                MaintenanceStep(number: 8, description: "Clear the fault in the BMS. Document the sensor replacement in the maintenance log.", icon: "doc.badge.plus"),
            ]

        case .configMismatch:
            return [
                MaintenanceStep(number: 1, description: "Connect a laptop to the controller via BACnet/IP or local service port.", icon: "desktopcomputer"),
                MaintenanceStep(number: 2, description: "Download the current running configuration and compare against the commissioning baseline.", icon: "doc.on.doc.fill"),
                MaintenanceStep(number: 3, description: "Identify mismatched parameters: setpoint ranges, PID gains, I/O channel assignments, or unit type.", icon: "magnifyingglass"),
                MaintenanceStep(number: 4, description: "Correct each parameter to match the commissioning specification document.", icon: "slider.horizontal.3"),
                MaintenanceStep(number: 5, description: "Upload the corrected configuration to the controller. Perform a soft restart.", icon: "arrow.triangle.2.circlepath"),
                MaintenanceStep(number: 6, description: "Verify the controller's live values match expected behavior (correct valve response, fan speed stages).", icon: "checkmark.circle.fill"),
            ]

        case .firmwareFailure:
            return [
                MaintenanceStep(number: 1, description: "Note the current firmware version displayed on the controller or via BMS diagnostics.", icon: "info.circle.fill"),
                MaintenanceStep(number: 2, description: "Connect to the controller via the manufacturer's service tool (USB or Ethernet).", icon: "desktopcomputer"),
                MaintenanceStep(number: 3, description: "Initiate firmware rollback to the last known stable version from the backup archive.", icon: "arrow.uturn.backward.circle.fill"),
                MaintenanceStep(number: 4, description: "Wait for the flash process to complete. Do NOT disconnect power during this step.", icon: "exclamationmark.shield.fill"),
                MaintenanceStep(number: 5, description: "After reboot, verify the controller version matches the target rollback version.", icon: "checkmark.shield.fill"),
                MaintenanceStep(number: 6, description: "Re-upload the site-specific configuration (may be reset during rollback).", icon: "arrow.up.doc.fill"),
                MaintenanceStep(number: 7, description: "Test all control sequences: heating, cooling, fan stages. Confirm normal BMS communication.", icon: "checkmark.circle.fill"),
            ]

        case .fanFault:
            return [
                MaintenanceStep(number: 1, description: "Switch off the FCU at the local isolator and lock out/tag out.", icon: "power"),
                MaintenanceStep(number: 2, description: "Remove the fan access panel. Inspect the fan wheel for damage or foreign objects.", icon: "magnifyingglass"),
                MaintenanceStep(number: 3, description: "Measure motor winding resistance with a multimeter. Compare to nameplate spec.", icon: "gauge.with.dots.needle.33percent"),
                MaintenanceStep(number: 4, description: "If motor is burnt out: disconnect motor leads and remove mounting bolts.", icon: "wrench.and.screwdriver.fill"),
                MaintenanceStep(number: 5, description: "Install the replacement motor. Align the fan wheel on the shaft and tighten the set screw.", icon: "fan.fill"),
                MaintenanceStep(number: 6, description: "Reconnect motor leads (L, N, E). Check rotation direction by briefly powering on.", icon: "arrow.clockwise"),
                MaintenanceStep(number: 7, description: "Replace the access panel. Restore power and test all fan speed stages from BMS.", icon: "checkmark.circle.fill"),
            ]

        case .filterClogged:
            return [
                MaintenanceStep(number: 1, description: "Open the filter access door on the FCU housing.", icon: "door.left.hand.open"),
                MaintenanceStep(number: 2, description: "Slide out the existing filter. Note the filter size, type (MERV rating), and airflow direction arrow.", icon: "arrow.right.circle.fill"),
                MaintenanceStep(number: 3, description: "Inspect the filter housing for bypass gaps or damage to the gasket seal.", icon: "magnifyingglass"),
                MaintenanceStep(number: 4, description: "Insert the new filter with the airflow arrow pointing in the correct direction.", icon: "arrow.down.circle.fill"),
                MaintenanceStep(number: 5, description: "Close the access door. Verify it latches securely with no air gaps.", icon: "lock.fill"),
                MaintenanceStep(number: 6, description: "Check the pressure differential across the filter is within spec on the BMS.", icon: "checkmark.circle.fill"),
            ]

        case .coilFouling:
            return [
                MaintenanceStep(number: 1, description: "Isolate the FCU and close the water valves on both supply and return.", icon: "power"),
                MaintenanceStep(number: 2, description: "Remove the coil access panel. Photograph the coil condition for records.", icon: "camera.fill"),
                MaintenanceStep(number: 3, description: "Vacuum loose debris from the coil face using a soft brush attachment.", icon: "wind"),
                MaintenanceStep(number: 4, description: "Apply alkaline coil cleaner spray evenly across the fin surface. Allow 10 minutes dwell time.", icon: "spray.fill"),
                MaintenanceStep(number: 5, description: "Rinse the coil with low-pressure water from the air-leaving side. Collect runoff in a drip tray.", icon: "drop.fill"),
                MaintenanceStep(number: 6, description: "Inspect fin spacing — straighten bent fins with a fin comb where necessary.", icon: "comb.fill"),
                MaintenanceStep(number: 7, description: "Replace access panel, open water valves, restore power. Verify improved delta-T across coil.", icon: "checkmark.circle.fill"),
            ]

        case .pumpMalfunction:
            return [
                MaintenanceStep(number: 1, description: "Check the pump circuit breaker and local isolator. Reset if tripped.", icon: "bolt.trianglebadge.exclamationmark.fill"),
                MaintenanceStep(number: 2, description: "Listen and feel the pump body — check for unusual vibration, noise, or heat.", icon: "ear.fill"),
                MaintenanceStep(number: 3, description: "Measure motor current draw. Compare to nameplate FLA (full load amps).", icon: "gauge.with.dots.needle.33percent"),
                MaintenanceStep(number: 4, description: "Check system pressure on both sides of the pump. No differential = no flow.", icon: "gauge.with.needle.fill"),
                MaintenanceStep(number: 5, description: "If impeller is seized: isolate, drain, and remove the pump cartridge. Replace with spare.", icon: "wrench.and.screwdriver.fill"),
                MaintenanceStep(number: 6, description: "Bleed air from the pump housing and circuit using the bleed valve.", icon: "drop.fill"),
                MaintenanceStep(number: 7, description: "Restore power. Verify pressure differential and flow rate on the BMS.", icon: "checkmark.circle.fill"),
            ]

        case .sensorCalibration:
            return [
                MaintenanceStep(number: 1, description: "Place a NIST-traceable reference thermometer next to the installed sensor.", icon: "thermometer.medium"),
                MaintenanceStep(number: 2, description: "Wait 5 minutes for thermal equilibrium. Record both readings.", icon: "clock.fill"),
                MaintenanceStep(number: 3, description: "If deviation > ±0.5°C: access the controller calibration menu via BMS or local keypad.", icon: "slider.horizontal.3"),
                MaintenanceStep(number: 4, description: "Apply the offset correction: new_offset = reference_reading − sensor_reading.", icon: "plus.forwardslash.minus"),
                MaintenanceStep(number: 5, description: "Save the calibration. Wait 2 minutes and re-compare readings to confirm accuracy.", icon: "checkmark.circle.fill"),
                MaintenanceStep(number: 6, description: "If offset exceeds ±2°C or sensor is non-linear: replace the sensor entirely (see Sensor Signal Loss procedure).", icon: "exclamationmark.triangle.fill"),
            ]

        case .sensorSignalLoss:
            return [
                MaintenanceStep(number: 1, description: "At the controller terminal block, check if the sensor channel shows 'Open Circuit' or '—' on the BMS.", icon: "exclamationmark.triangle.fill"),
                MaintenanceStep(number: 2, description: "Measure resistance across the sensor cable at the controller end. NTC ≈ 10kΩ at 25°C, PT1000 ≈ 1000Ω.", icon: "gauge.with.dots.needle.33percent"),
                MaintenanceStep(number: 3, description: "If open circuit: trace the cable from the controller to the sensor. Check junction boxes for disconnected wires.", icon: "cable.connector"),
                MaintenanceStep(number: 4, description: "If cable is intact: the sensor element has failed. Disconnect the old sensor from its mounting.", icon: "wrench.and.screwdriver.fill"),
                MaintenanceStep(number: 5, description: "Install the replacement sensor (matching type: NTC or PT1000). Secure mounting and route cable neatly.", icon: "sensor.fill"),
                MaintenanceStep(number: 6, description: "Terminate the new cable at the controller. Verify the BMS shows a valid temperature reading.", icon: "checkmark.circle.fill"),
                MaintenanceStep(number: 7, description: "Perform a quick calibration check against a handheld reference thermometer.", icon: "thermometer.medium"),
            ]
        }
    }
}

import SwiftUI
import RealityKit

struct MaintenanceOverlayView: View {
    // Connect to the data model
    @State private var fcuData = FCUModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(fcuData.isLogicTrapDetected ? .white : .green)
                Text("AR-DSS: Operator 4.0 Assistant")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .padding(.top)
            
            Divider()
            
            // Live Data Grid
            HStack(spacing: 40) {
                DataCell(title: "Control Sensor", value: "\(fcuData.controlSensorTemp)°C", icon: "thermometer.low")
                DataCell(title: "Setpoint", value: "\(fcuData.setpointTemp)°C", icon: "target")
                DataCell(title: "Valve Output", value: "\(Int(fcuData.valveOutput))%", icon: "fanblades")
            }
            
            Divider()
            
            // The "Physical Reality" Section
            HStack {
                Image(systemName: "sensor.tag.radiowaves.forward.fill")
                Text("Physical Duct Sensor: \(fcuData.ductDischargeTemp)°C")
                    .font(.headline)
                    .foregroundStyle(fcuData.isLogicTrapDetected ? .yellow : .primary)
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(12)
            
            // MARK: - Fault Diagnosis Section
            if fcuData.isLogicTrapDetected {
                VStack(alignment: .leading, spacing: 10) {
                    Text("CRITICAL ANOMALY DETECTED")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                    
                    Text("Fault Path: \(fcuData.faultPath)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Text("Analysis: Controller logic is valid, but input data conflicts with physical reality. Verify Sensor Calibration (Node O1).")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.8)) // RED ALERT BACKGROUND
                .cornerRadius(16)
            } else {
                Text("System Status: Normal")
                    .font(.title)
                    .foregroundStyle(.green)
            }
        }
        .padding(40)
        .frame(width: 600)
        // Apply the standard visionOS glass effect
        .glassBackgroundEffect()
        .onAppear {
            // Run the logic immediately when the window opens
            fcuData.refreshData()
        }
    }
}

// Helper View for the data grid
struct DataCell: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .padding(.bottom, 5)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview(windowStyle: .automatic) {
    MaintenanceOverlayView()
}

//
//  FCUModel.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar on 29.11.25.
//

import Foundation
import SwiftUI

// This class simulates the live data stream coming from the Building Management System (BMS)
@Observable
class FCUModel {
    // MARK: - Dashboard Inputs (Simulated)
    // Hardcoded to match your thesis screenshot BC04H41.JPG
    var setpointTemp: Double = 21.00
    var controlSensorTemp: Double = 19.96 // Controller thinks it's cold
    var valveOutput: Double = 0.0         // 0% Cooling because 19.96 < 21.00
    
    // MARK: - Physical Reality (Simulated Sensor)
    // The specific sensor causing the logic trap
    var ductDischargeTemp: Double = 24.47 // Reality is HOT
    
    // MARK: - Diagnosis State
    var isLogicTrapDetected: Bool = false
    var faultPath: String = ""
    
    // Function to update values (Simulating real-time data changes)
    func refreshData() {
        // In a real app, you would fetch JSON here.
        // For the thesis prototype, we keep these static to prove the specific scenario.
        checkFaultTree()
    }
    
    // MARK: - The Fault Tree Logic Engine
    private func checkFaultTree() {
        // STEP 1: Check Top Event (Room > 22°C?)
        // If duct temp is > 22.0, the room is physically hot.
        let isRoomActuallyHot = ductDischargeTemp > 22.0
        
        // STEP 2: Check Controller State
        // Controller sees 19.96 < 21.00, so it correctly thinks "I need to heat" or "Stop cooling".
        let controllerThinksCold = controlSensorTemp < setpointTemp
        let valveIsClosed = valveOutput <= 0.1
        
        // STEP 3: Diagnose Node G1 (Control Algorithm Logic Trap)
        // Condition: Room is HOT + Controller thinks COLD + Valve CLOSED
        if isRoomActuallyHot && controllerThinksCold && valveIsClosed {
            isLogicTrapDetected = true
            faultPath = "B2 (Software) -> G1 (Logic Trap) -> Q1 (Data Conflict)"
        } else {
            isLogicTrapDetected = false
            faultPath = "Normal Operation"
        }
    }
}


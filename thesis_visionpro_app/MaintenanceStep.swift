//
//  ProcedureModel.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar on 29.11.25.
//

import Foundation

struct MaintenanceStep: Identifiable {
    let id = UUID()
    let number: Int
    let description: String
    let icon: String // SF Symbol name for visual aid
}

class ProcedureModel {
    // These steps match your provided "Procedure for Troubleshooting" document
    // ... inside ProcedureModel.swift ...

    static let replacementSteps: [MaintenanceStep] = [
        MaintenanceStep(
            number: 1,
            description: "Identify the defective Actuator. \n(See Red Highlight in AR)",
            icon: "exclamationmark.triangle.fill"
        ),
        MaintenanceStep(
            number: 2,
            description: "Locate the textured metal ring at the base of the Sauter actuator.",
            icon: "circle.grid.cross.fill"
        ),
        MaintenanceStep(
            number: 3,
            description: "Rotate the metal ring COUNTER-CLOCKWISE to loosen.",
            icon: "arrow.counterclockwise.circle.fill"
        ),
        MaintenanceStep(
            number: 4,
            description: "Pull the white actuator body gently upwards to remove.",
            icon: "arrow.up.circle.fill"
        ),
        MaintenanceStep(
            number: 5,
            description: "Inspect the valve pin (metal pin) for corrosion or seizure.",
            icon: "magnifyingglass"
        ),
        MaintenanceStep(
            number: 6,
            description: "Place the NEW actuator (Sauter) onto the valve thread.",
            icon: "arrow.down.circle.fill"
        ),
        MaintenanceStep(
            number: 7,
            description: "Tighten the metal ring CLOCKWISE until hand-tight.",
            icon: "arrow.clockwise.circle.fill"
        ),
        MaintenanceStep(
            number: 8,
            description: "Reconnect the 24V power cable.",
            icon: "powerplug.fill"
        )
    ]
}

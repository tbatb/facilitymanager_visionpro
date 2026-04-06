//
//  GuidedWorkflowView 2.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar on 06.04.26.
//


//
//  GuidedWorkflowView.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar on 29.11.25.
//

import SwiftUI

struct GuidedWorkflowView: View {
    @State private var currentStepIndex = 0
    let steps = ProcedureModel.replacementSteps
    
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
                    .frame(height: 120) // Fixed height to prevent jumping
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
                
                Button(action: {
                    if currentStepIndex < steps.count - 1 { withAnimation { currentStepIndex += 1 } }
                }) {
                    Label("Next", systemImage: "chevron.right")
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .disabled(currentStepIndex == steps.count - 1)
            }
        }
        .padding(40)
        .frame(width: 600, height: 500)
        .glassBackgroundEffect()
    }
}

#Preview {
    GuidedWorkflowView()
}

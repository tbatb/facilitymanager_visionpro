import SwiftUI

struct ActuatorReplacementView: View {
    // These steps match your specific Sauter actuator images
    let steps: [MaintenanceStep] = [
        MaintenanceStep(number: 1, description: "Identify the defective Actuator.\n(Left = Heat, Right = Cold).", icon: "magnifyingglass"),
        MaintenanceStep(number: 2, description: "Locate the textured metal ring at the base.", icon: "circle.grid.cross"),
        MaintenanceStep(number: 3, description: "Twist the metal ring COUNTER-CLOCKWISE to loosen.", icon: "arrow.counterclockwise.circle.fill"),
        MaintenanceStep(number: 4, description: "Lift the white actuator body straight up.", icon: "arrow.up.circle.fill"),
        MaintenanceStep(number: 5, description: "Check valve pin for movement.", icon: "pencil.tip"),
        MaintenanceStep(number: 6, description: "Place NEW actuator onto the valve.", icon: "arrow.down.circle.fill"),
        MaintenanceStep(number: 7, description: "Tighten metal ring CLOCKWISE until hand-tight.", icon: "arrow.clockwise.circle.fill"),
        MaintenanceStep(number: 8, description: "Reconnect 24V power cable.", icon: "powerplug.fill")
    ]
    
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Actuator Replacement Guide")
                .font(.headline)
            
            Divider()
            
            // The Step Card
            VStack(spacing: 30) {
                // Step Number
                Text("Step \(steps[currentStep].number)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                
                // Icon
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 80))
                    .foregroundStyle(.primary)
                
                // Description
                Text(steps[currentStep].description)
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            
            // Controls
            HStack(spacing: 40) {
                Button("Previous") {
                    if currentStep > 0 { withAnimation { currentStep -= 1 } }
                }
                .disabled(currentStep == 0)
                
                Button("Next Step") {
                    if currentStep < steps.count - 1 { withAnimation { currentStep += 1 } }
                }
                .disabled(currentStep == steps.count - 1)
            }
            .padding()
        }
        .padding()
    }
}
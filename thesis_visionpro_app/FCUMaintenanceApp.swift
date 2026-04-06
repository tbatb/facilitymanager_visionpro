import SwiftUI

@main
struct FCUMaintenanceApp: App {
    var body: some Scene {
        // This creates a standard window that floats in the user's room
        WindowGroup {
            //MaintenanceOverlayView()
            DashboardView()
        
        }
        .windowStyle(.plain) // Gives it the clean 'no-bar' look if preferred, or use .automatic
    }
}

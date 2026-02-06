# AR-DSS: Augmented Reality-Driven Decision Support System for Facility Maintenance

<p align="center">
  <img src="https://img.shields.io/badge/Platform-visionOS-blue?style=for-the-badge&logo=apple" alt="visionOS"/>
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift" alt="Swift"/>
  <img src="https://img.shields.io/badge/RealityKit-Enabled-green?style=for-the-badge" alt="RealityKit"/>
  <img src="https://img.shields.io/badge/License-Academic-lightgrey?style=for-the-badge" alt="License"/>
</p>

> **Bachelor Thesis Project** | Technische Universität Wien  
> *Augmented Reality-Driven Decision Support Systems: Applications in Maintenance and Quality Management*

## Overview

This application is a functional prototype developed for the **Apple Vision Pro** that demonstrates how Augmented Reality can serve as a cognitive tool for industrial maintenance operations. Built as part of a Design Science Research (DSR) methodology, the system integrates **Fault Tree Analysis (FTA)** directly into a spatial computing environment to assist "Operator 4.0" in diagnosing complex Cyber-Physical System failures.

### Key Innovation: Logic Trap Detection

The system identifies **"Logic Traps"**—scenarios where control algorithms function correctly based on conflicting sensor inputs. For example:
- Control sensor reads: `19.96°C` (below setpoint)
- Physical duct sensor reads: `24.47°C` (room is actually hot)
- Result: Cooling valve stays closed because the controller "thinks" it's cold

Traditional automated alerts miss these failures. This AR-DSS bridges the gap between digital anomalies and physical reality.

---

## Features

### Facility Dashboard
- Real-time overview of all Fan Coil Units (FCUs)
- Visual status indicators (Online, Maintenance Scheduled, Critical Fault)
- One-tap navigation to unit-specific maintenance workflows

### Analytics Dashboard
- Fleet health metrics and KPIs
- Unit status breakdown with visual bar charts
- Most repaired units ranking
- Recent maintenance activity feed
- Maintenance type distribution analysis

### Guided Maintenance Workflows
- **Critical Fault Resolution**: FTA-based diagnostics for "Logic Trap" detection
- **Scheduled Maintenance**: Task checklist with progress tracking
- **Actuator Replacement**: Step-by-step AR-guided procedure

### Live Unit Statistics
- Real-time simulated sensor data (RPM, Power, Temperature, Airflow)
- Animated value transitions for monitoring
- Maintenance history tracking

### Maintenance Completion
- Outcome selection (Resolved / Schedule Follow-up)
- Automatic status updates to facility registry
- Maintenance record logging

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FCUMaintenanceApp                        │
│                         (Entry Point)                           │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DashboardView                            │
│              ┌──────────────┬──────────────────┐                │
│              │ Units Tab    │ Analytics Tab    │                │
│              └──────────────┴──────────────────┘                │
└─────────────────────────┬───────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ UnitStats     │ │ Scheduled     │ │ Critical      │
│ View          │ │ Maintenance   │ │ Maintenance   │
│ (Online)      │ │ Container     │ │ Container     │
└───────────────┘ └───────────────┘ └───────────────┘
                          │                 │
                          ▼                 ▼
                  ┌───────────────────────────────┐
                  │   MaintenanceCompleteView     │
                  │   (Outcome Recording)         │
                  └───────────────────────────────┘
```

---

## Project Structure

```
facilitymanager_visionpro/
├── FCUMaintenanceApp.swift          # App entry point
├── AppModel.swift                   # App-wide state management
│
├── Models/
│   ├── FCUModel.swift               # Logic Trap detection algorithm
│   ├── FCURegistry.swift            # Singleton data store & analytics
│   └── ProcedureModel.swift         # SOP step definitions
│
├── Views/
│   ├── DashboardView.swift          # Main dashboard with unit grid
│   ├── AnalyticsDashboardView.swift # Analytics & metrics view
│   ├── UnitStatsView.swift          # Live unit monitoring
│   ├── UnitMaintenanceContainer.swift    # Critical fault workflow
│   ├── ScheduledMaintenanceContainer.swift # Scheduled tasks workflow
│   ├── MaintenanceOverlayView.swift # FTA diagnostic display
│   ├── ActuatorReplacementView.swift # Step-by-step repair guide
│   ├── MaintenanceCompleteView.swift # Outcome selection
│   └── GuidedWorkflowView.swift     # Generic SOP viewer
│
├── Components/
│   ├── MainTabView.swift            # Tab navigation
│   ├── ToggleImmersiveSpaceButton.swift # Immersive mode toggle
│   └── ImmersiveView.swift          # RealityKit immersive content
│
└── tu_bachelor_thesis_v04.pdf       # Full thesis documentation
```

---

## Core Algorithms

### Logic Trap Detection (from FCUModel.swift)

```swift
// Fault Tree Implementation
private func checkFaultTree() {
    // STEP 1: Is the room physically hot?
    let isRoomActuallyHot = ductDischargeTemp > 22.0
    
    // STEP 2: Does the controller think it's cold?
    let controllerThinksCold = controlSensorTemp < setpointTemp
    let valveIsClosed = valveOutput <= 0.1
    
    // STEP 3: Diagnose Logic Trap
    if isRoomActuallyHot && controllerThinksCold && valveIsClosed {
        isLogicTrapDetected = true
        faultPath = "B2 (Software) → G1 (Logic Trap) → Q1 (Data Conflict)"
    }
}
```

### Maintenance Workflow State Machine

The guided workflow follows a deterministic finite state machine:
1. **Identification** → Locate defective component
2. **Disassembly** → Remove faulty actuator
3. **Assembly** → Install replacement
4. **Test** → Verify system normalization

---

## Getting Started

### Prerequisites

- **Xcode 15.2+** with visionOS SDK
- **Apple Vision Pro** or visionOS Simulator
- **macOS Sonoma 14.0+**

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/tbatb/facilitymanager_visionpro.git
   ```

2. Open in Xcode:
   ```bash
   cd facilitymanager_visionpro
   open *.xcodeproj
   ```

3. Select the visionOS Simulator or connected Apple Vision Pro

4. Build and Run (⌘ + R)

### Configuration

The app uses simulated BMS data. To modify the test scenario, edit `FCUModel.swift`:

```swift
var setpointTemp: Double = 21.00
var controlSensorTemp: Double = 19.96  // Simulated sensor drift
var ductDischargeTemp: Double = 24.47  // Physical reality
```

---

## 📖 Use Case: Fan Coil Unit Maintenance

The prototype models a **vertical four-pipe hydronic Fan Coil Unit (FCU)** based on LBNL Fault Detection and Diagnostics datasets.

### System Configuration
- 3-speed fan with variable airflow
- Separate heating and cooling coils
- PI (Proportional-Integral) control loop
- Outdoor air damper integration

### Maintenance Scenarios

| Status | Description | Workflow |
|--------|-------------|----------|
| 🟢 **Online** | Normal operation | View live stats only |
| 🟡 **Maintenance** | Scheduled service | Task checklist with progress |
| 🔴 **Critical Fault** | Logic Trap detected | FTA diagnostics + Repair guide |

---

## Academic Context

This project was developed as part of a Bachelor Thesis at:

**Technische Universität Wien**  
Institute of Management Science  
Production and Quality Maintenance (E 330)

### Supervisors
- Univ.-Prof. Dr.-Ing. Fazel Ansari
- Dr. Sara Elisabeth Scheffer

### Research Questions Addressed
1. How can AR enhance decision-making in complex IT/OT environments?
2. What features improve fault diagnosis accuracy in AR maintenance systems?
3. What measurable impacts do AR tools have on operator performance?

---

## Future Development

- [ ] **Live IoT Integration**: MQTT/OPC-UA middleware for real BMS data
- [ ] **LLM-Powered Authoring**: Auto-generate fault trees from technical documentation
- [ ] **Multi-Asset Support**: Extend beyond FCUs to other facility equipment
- [ ] **Collaborative Features**: Remote expert assistance via SharePlay

---

## License

This project is developed for academic purposes as part of a bachelor thesis at TU Wien. Please contact the author for usage permissions.

---

##  Acknowledgments

- TU Wien Institute of Management Science
- LBNL for Fault Detection and Diagnostics datasets
- Apple Developer Documentation for visionOS guidance

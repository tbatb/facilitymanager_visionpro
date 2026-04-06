# AR-DSS: Augmented Reality-Driven Decision Support System for FCU Maintenance

A visionOS application built for Apple Vision Pro that assists HVAC maintenance technicians with fault diagnosis and guided repair workflows for Fan Coil Units (FCUs). Developed as the practical artifact for a bachelor thesis at TU Wien.


## About

This application implements an AR-Driven Decision Support System (AR-DSS) that combines Fault Tree Analysis (FTA) with step-by-step repair procedures to help maintenance operators diagnose and resolve faults in four-pipe hydronic Fan Coil Units. Rather than relying on intuition or manual cross-referencing of BMS (Building Management System) dashboards, the system provides structured, transparent diagnostic reasoning and guided workflows directly in the operator's field of view.

The project was developed as part of the bachelor thesis "Augmented Reality-Driven Decision Support Systems: Applications in Maintenance and Quality Management" at the Institute of Management Science, Technische Universitat Wien, supervised by Univ.-Prof. Dr.-Ing. Fazel Ansari and Dr. Sara Elisabeth Scheffer.


## Problem Statement

Modern HVAC systems produce complex failure scenarios where control software operates correctly based on incorrect inputs -- so-called "Logic Traps." Traditional BMS dashboards present raw data without diagnostic context, forcing technicians to manually correlate values across multiple screens. This application addresses three core problems identified in the thesis:

- P1 -- Insufficient context-aware information availability during maintenance tasks
- P2 -- Limited integration of structured decision-making techniques in existing AR maintenance tools
- P3 -- Inefficient capture and reuse of maintenance knowledge across service activities


## Features

### Facility Dashboard

The main view displays all registered FCU units in a grid layout. Each unit card shows its room ID, name, current status (Online, Critical Fault, or Maintenance Planned), and the active fault type if one exists. Units are color-coded by status for quick visual triage.

### Fault Simulation

Any unit can be set to a faulty state directly from the dashboard. Tapping "Simulate Fault" below a unit card opens a sheet listing all 13 fault types from the Fault Tree Analysis, organized by branch. Selecting a fault sets the unit to Critical Fault status and assigns the corresponding diagnostic data. A "Clear" button resets the unit to Online.

### Fault Tree Browser

The Fault Tree tab provides a complete interactive view of the diagnostic hierarchy derived from Figure 4.3 of the thesis. The top event ("Room Temperature > 22 C") connects via an OR gate to four branches:

- B1 Actuator/Control Failure (4 fault types)
- B2 Software Failure (3 fault types)
- B3 Mechanical/HVAC Failure (4 fault types)
- B4 Sensor/Data Problem (2 fault types)

Each branch can be expanded to show its fault nodes. Faults that are currently active on any unit display the affected unit's room ID as a badge directly on the fault node. Expanding a fault node shows the diagnostic summary, repair step count, and a list of affected units with their names and types.

### Fault Diagnostics

When a unit with an active fault is opened, the Diagnostics tab displays the full fault tree path (e.g., "B2 -> G1 Logic Trap -> Q1 Data Conflict"), the branch classification, a diagnostic analysis explaining the failure mechanism, and the recommended repair procedure. For units without a programmatically assigned fault, the view falls back to the original Logic Trap detection overlay that compares live BMS values.

### Guided Repair Workflows

The Repair tab loads fault-specific step-by-step procedures. Each of the 13 fault types has its own repair sequence (6 to 8 steps), including instructions for actuator unjamming, valve reseating, 24V power restoration, fan motor replacement, filter replacement, coil cleaning, pump servicing, sensor recalibration, firmware rollback, and controller reconfiguration. Steps are presented one at a time with an SF Symbol icon, a progress bar, and Previous/Next navigation. The final step replaces the Next button with "Complete Maintenance" to proceed directly to outcome logging.

### Scheduled Maintenance

Units with Maintenance Planned status open into a task checklist view with tasks specific to the unit's FCU type. Tasks can be expanded for detailed instructions and marked as done individually, with a progress bar tracking completion. When all tasks are complete, a "Complete Maintenance" button appears inline. A separate Reschedule tab allows changing the planned maintenance date via a graphical date picker.

### Maintenance Completion

After finishing a repair or scheduled maintenance, the completion view offers two outcomes: marking the unit as resolved (status returns to Online, fault is cleared) or booking further maintenance (status set to Maintenance Planned with a selected follow-up date via date picker). All outcomes are logged as maintenance records.

### Analytics Dashboard

The Analytics tab provides facility-wide metrics including fleet health percentage, total repairs, cumulative downtime, and average repair time. It also shows a per-unit repair ranking and recent maintenance history.

### Live Unit Stats

Online units display simulated real-time telemetry including fan RPM, power consumption, temperature, and airflow rate, with values that update every two seconds.


## Architecture

The application is built entirely in Swift and SwiftUI, targeting visionOS. There is no external backend -- all data is held in memory via a singleton registry.

### Source Files

```
FCUMaintenanceApp.swift          App entry point, single WindowGroup with DashboardView
DashboardView.swift              Main tab container (Units, Fault Tree, Analytics), unit grid,
                                 fault picker sheet, unit card component
FaultCatalog.swift               FaultType enum (13 faults), MaintenanceStep struct,
                                 ProcedureModel class, repair step definitions
FaultTreeBrowserView.swift       Interactive fault tree hierarchy with live affected-unit badges
FCURegistry.swift                FanCoilUnit class, UnitStatus/MaintenanceOutcome enums,
                                 FCURegistry singleton, MaintenanceTask, MaintenanceRecord
FCUModel.swift                   BMS data simulation and Logic Trap detection algorithm
UnitMaintenanceContainer.swift   Critical fault flow: diagnostics + repair + completion
ScheduledMaintenanceContainer.swift  Scheduled maintenance: task checklist + reschedule + completion
MaintenanceCompleteView.swift    Outcome selection (resolve or schedule follow-up) with date picker
MaintenanceOverlayView.swift     Original Logic Trap overlay with live BMS data display
AnalyticsDashboardView.swift     Facility analytics and maintenance history
UnitStatsView.swift              Live telemetry display for online units
AppModel.swift                   App-wide state for immersive space management
ImmersiveView.swift              RealityKit immersive space (scaffold for future AR content)
ToggleImmersiveSpaceButton.swift Toggle control for immersive space
```

### Data Model

`FanCoilUnit` is an `ObservableObject` with published properties for `status`, `activeFault`, and `scheduledMaintenanceDate`. The `FCURegistry` singleton holds an array of six simulated units spanning three status categories and provides computed analytics properties. `FaultType` is a `CaseIterable` enum where each case carries its fault tree path, diagnostic summary, icon, color, and an array of `MaintenanceStep` values defining the repair procedure.

### Key Design Decisions

The application uses navigation-based unit selection rather than camera-based object detection. This was a deliberate choice for the Vision Pro platform, where reliable real-time object detection of ceiling-mounted HVAC equipment proved impractical in the prototype phase. The navigation approach provides deterministic unit identification while the diagnostic logic and repair workflows remain identical to what a camera-based system would deliver.

Scheduled maintenance tasks use a `lazy var` cache on `FanCoilUnit` to ensure stable UUIDs across SwiftUI render cycles. Without this, the computed property would regenerate new `MaintenanceTask` instances (and new UUIDs) on every access, causing task selection and completion tracking to break.


## Requirements

- Xcode 16.0 or later
- visionOS 2.0 SDK
- Apple Vision Pro (device or simulator)
- macOS Sonoma 14.0 or later (for Xcode)


## Building and Running

1. Clone the repository
2. Open the `.xcodeproj` file in Xcode
3. Select the visionOS simulator or a connected Apple Vision Pro as the run destination
4. Build and run (Cmd+R)

The app launches into the Facility Dashboard with six pre-configured FCU units. Two units start in Critical Fault state (BC04H41 with Logic Trap, BC04H44 with Actuator Stuck), two in Maintenance Planned state, and two Online.


## Fault Catalog Reference

The following fault types are implemented, each with a complete diagnostic description and step-by-step repair procedure:

| Fault ID | Fault Name | Branch | Repair Steps |
|----------|-----------|--------|-------------|
| C3 | Actuator Stuck | B1 Actuator/Control | 8 steps |
| C2 | Valve Fault | B1 Actuator/Control | 8 steps |
| C4 | No 24V AC Supply | B1 Actuator/Control | 7 steps |
| E1 | Actuator Motor Damaged | B1 Actuator/Control | 8 steps |
| G1 | Logic Trap | B2 Software | 8 steps |
| B9 | Configuration Mismatch | B2 Software | 6 steps |
| S2 | Firmware Update Failure | B2 Software | 7 steps |
| R4 | Fan Fault | B3 Mechanical/HVAC | 7 steps |
| K3 | Filter Clogged | B3 Mechanical/HVAC | 6 steps |
| B5 | Coil Fouling | B3 Mechanical/HVAC | 7 steps |
| M3 | Pump Malfunction | B3 Mechanical/HVAC | 7 steps |
| R1 | Calibration Issue | B4 Sensor/Data | 6 steps |
| M4 | Sensor Signal Loss | B4 Sensor/Data | 7 steps |


## Simulated Units

| Room ID | Unit Name | Type | Default Status |
|---------|----------|------|---------------|
| BC04H41 | Vertical Console | 4-Pipe Hydronic | Critical Fault (Logic Trap) |
| BC04H42 | Ceiling Cassette | 2-Pipe Cooling | Online |
| BC04H43 | Wall Split Unit | Refrigerant VRF | Maintenance Planned |
| BC04H44 | Horizontal Ceiling | 4-Pipe Hydronic | Critical Fault (Actuator Stuck) |
| BC04H45 | Ducted Concealed | 4-Pipe Hydronic | Online |
| BC04H46 | Floor Standing | 2-Pipe Heating | Maintenance Planned |


## Thesis Context

This application serves as the functional prototype (artifact) for a Design Science Research study. It addresses three research questions:

- RQ1: To what extent do AR-based support tools enhance decision-making in industrial maintenance, specifically focusing on fault diagnosis and response time?
- RQ2: What key features and methods in AR maintenance systems improve fault diagnosis accuracy, reduce human error, and minimize downtime?
- RQ3: What measurable impacts do AR-based maintenance tools have on operator performance, including task completion time, error rates, and system reliability?

The implementation validates the thesis contributions through the Logic Trap Detection algorithm (Algorithm 1 in the thesis), the Context Recognition mechanism (Algorithm 2), the Maintenance Workflow state machine (Algorithm 3), session tracking for MTTR measurement (Algorithm 4), and analytics computation (Algorithm 5).


## Limitations

- All sensor data and BMS values are simulated. There is no connection to a live Building Management System.
- The immersive AR overlay (RealityKit scene) is a scaffold. The current prototype operates as a windowed visionOS application with spatial UI rather than full AR object overlay.
- Unit identification is navigation-based, not camera-based. A production system would use object detection or QR/NFC scanning.
- Maintenance records and fault states are held in memory and reset when the app is relaunched.
- Repair procedures are representative but not validated against specific manufacturer service manuals.


## License

This project was developed as an academic thesis artifact at TU Wien. See the repository for license details.


## Author

Tegshbayar Batbayar
Bachelor of Science, Technische Universitat Wien
Institute of Management Science -- Production and Quality Maintenance

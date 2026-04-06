# AR-DSS: When Your HVAC System Lies to Itself

**An Apple Vision Pro application that catches the faults your Building Management System misses.**

Built for visionOS in Swift/SwiftUI. Developed as a bachelor thesis artifact at TU Wien.

---

## The Problem This Solves

A four-pipe Fan Coil Unit reports a room temperature of 19.96 degrees C. The setpoint is 21.00 degrees C. The controller does exactly what it should: it closes the cooling valve. Logical.

Except the room is actually 24.47 degrees C.

The control sensor is wrong. The algorithm is right. The building is overheating. And the BMS dashboard shows nothing out of the ordinary -- because from the software's perspective, everything is working perfectly.

This is a **Logic Trap**: valid software logic operating on invalid data. Standard automated alerts will never catch it. A technician staring at the BMS dashboard might not catch it either, because every value looks internally consistent. You only see the problem when you compare what the system *believes* against what is *physically happening*.

This application was built to make that comparison automatic, visible, and actionable.


## What It Does

AR-DSS is a decision support system for HVAC maintenance operators. It runs on Apple Vision Pro and provides three things that traditional BMS dashboards do not: transparent diagnostic reasoning, guided repair procedures, and structured maintenance workflows.

The system manages a facility of Fan Coil Units. Each unit has a live status, and any unit can be set to one of 13 fault conditions drawn directly from a Fault Tree Analysis. When a fault is active, the application shows the operator exactly *why* the system thinks something is wrong -- not just *that* something is wrong -- by displaying the full fault tree path from the top event down to the root cause. It then walks the operator through a step-by-step repair procedure specific to that fault.

No tab switching. No guesswork. No reliance on the technician happening to remember the right troubleshooting sequence.


## The Fault Tree

The diagnostic engine is built on a complete Fault Tree Analysis for FCU temperature anomalies. The top event -- room temperature exceeding 22 degrees C -- branches through an OR gate into four failure categories, each containing specific fault types:

**B1 -- Actuator/Control Failure:**
Actuator stuck (mechanical jamming), valve fault (seal failure), no 24V AC supply (power loss), actuator motor damaged (burnout).

**B2 -- Software Failure:**
Logic trap (sensor-controller data conflict), configuration mismatch (wrong parameters), firmware update failure (corrupted controller).

**B3 -- Mechanical/HVAC Failure:**
Fan fault (motor failure), filter clogged (airflow restriction), coil fouling (scale/corrosion buildup), pump malfunction (no circulation).

**B4 -- Sensor/Data Problem:**
Calibration drift (readings offset beyond tolerance), sensor signal loss (wiring fault or hardware failure).

Each of these 13 faults carries a full diagnostic description, a fault tree path string, and a step-by-step repair procedure with 6 to 8 detailed instructions.

The Fault Tree Browser tab renders this entire hierarchy as an interactive, expandable view. Faults that are currently active on any unit show the affected unit's room ID directly on the tree node -- so you can see at a glance which parts of your failure space are currently occupied.


## How It Works

### Dashboard

Six simulated FCU units are displayed in a grid. Each card shows the unit's room ID, name, type, status, and active fault (if any). Below each card, a "Simulate Fault" button opens the full fault catalog so you can assign any of the 13 fault types to any unit. A "Clear" button resets it.

### Diagnostics

Tapping a unit in Critical Fault state opens the diagnostics view. If the unit has an assigned fault, the view displays the fault tree path (e.g., "B1 -> C3 Actuator Stuck -> D2 Mechanical Jamming"), the branch classification, a plain-language diagnostic analysis explaining the failure mechanism, and the recommended repair procedure. If no fault is programmatically assigned, it falls back to the original Logic Trap detector that compares live BMS sensor values in real time.

### Guided Repair

The Repair tab loads the correct procedure for the active fault. Steps are presented one at a time -- icon, instruction text, progress bar, Previous/Next navigation. On the final step, the Next button is replaced with "Complete Maintenance," which opens the outcome logger directly. No searching for the right tab. No context switching.

### Scheduled Maintenance

Units in Maintenance Planned status open into a task checklist tailored to the unit's FCU type (4-pipe hydronic gets different tasks than a VRF split unit). Tasks expand to show detailed instructions and can be marked done individually. A progress bar tracks completion. When all tasks are finished, an inline "Complete Maintenance" button appears right there in the task list. A separate Reschedule tab lets you change the planned date with a graphical picker.

### Completion and Recording

Every maintenance session ends with an outcome choice: mark the unit as resolved (clears the fault, sets status to Online) or book a follow-up (sets a date, moves status to Maintenance Planned). Both outcomes are logged as maintenance records with timestamps, types, and technician identifiers.

### Analytics

The Analytics tab computes fleet-wide metrics in real time: percentage of units online, total repair count, cumulative downtime hours, average repair duration. It ranks units by repair frequency and shows recent maintenance history.


## Architecture

Pure Swift/SwiftUI targeting visionOS. No backend, no network calls, no database. All state lives in a singleton registry in memory.

```
FCUMaintenanceApp.swift             Entry point. Single WindowGroup launching DashboardView.

DashboardView.swift                 Three-tab container (Units, Fault Tree, Analytics).
                                    Unit grid with fault simulation buttons and picker sheet.

FaultCatalog.swift                  The core diagnostic data. FaultType enum with 13 cases,
                                    each carrying fault path, diagnostic summary, icon, color,
                                    and a complete array of MaintenanceStep repair instructions.
                                    Also contains MaintenanceStep struct and ProcedureModel class.

FaultTreeBrowserView.swift          Interactive fault tree hierarchy. Expandable branches,
                                    live affected-unit badges, per-fault diagnostic detail.

FCURegistry.swift                   FanCoilUnit model (ObservableObject with published status,
                                    activeFault, scheduledMaintenanceDate). FCURegistry singleton
                                    holding six units, maintenance history, and computed analytics.

FCUModel.swift                      BMS data simulator and Logic Trap detection algorithm.
                                    Implements the core diagnostic logic from Algorithm 1.

UnitMaintenanceContainer.swift      Critical fault workflow container. Tabs for fault diagnostics
                                    (FaultDiagnosticsView) and guided repair (RepairWorkflowView).
                                    Triggers completion sheet on final repair step.

ScheduledMaintenanceContainer.swift Scheduled maintenance container. Task checklist with inline
                                    completion, reschedule date picker, and live stats tab.

MaintenanceCompleteView.swift       Outcome selection: resolve (clear fault, set Online) or
                                    schedule follow-up (date picker, set Maintenance Planned).
                                    Logs maintenance record to registry.

MaintenanceOverlayView.swift        Original Logic Trap overlay. Displays live BMS values and
                                    highlights data conflicts between sensor and physical reality.

AnalyticsDashboardView.swift        Fleet health, repair rankings, downtime totals, history.

UnitStatsView.swift                 Live telemetry for online units (RPM, watts, temp, airflow).

AppModel.swift                      App-wide state for immersive space management.
ImmersiveView.swift                 RealityKit immersive space scaffold.
ToggleImmersiveSpaceButton.swift    Immersive space toggle control.
```

### Key Design Decisions

**Navigation over object detection.** The app identifies units by tapping cards on the dashboard, not by pointing the Vision Pro's cameras at ceiling-mounted equipment. This was a deliberate choice: reliable real-time detection of HVAC hardware proved impractical in the prototype phase. The diagnostic logic and repair workflows are identical regardless of how the unit is identified -- swapping in camera-based detection later would not change the downstream experience.

**Cached task UUIDs.** Scheduled maintenance tasks are generated from a computed property on FanCoilUnit based on the unit's type. Without caching, SwiftUI would regenerate new MaintenanceTask objects (with new UUIDs) on every render cycle, silently breaking task selection and completion tracking. A `lazy var` cache ensures UUIDs persist for the lifetime of the unit object.


## Fault Catalog

| ID | Fault | Branch | Steps |
|----|-------|--------|-------|
| C3 | Actuator Stuck | B1 Actuator/Control | 8 |
| C2 | Valve Fault | B1 Actuator/Control | 8 |
| C4 | No 24V AC Supply | B1 Actuator/Control | 7 |
| E1 | Actuator Motor Damaged | B1 Actuator/Control | 8 |
| G1 | Logic Trap | B2 Software | 8 |
| B9 | Configuration Mismatch | B2 Software | 6 |
| S2 | Firmware Update Failure | B2 Software | 7 |
| R4 | Fan Fault | B3 Mechanical/HVAC | 7 |
| K3 | Filter Clogged | B3 Mechanical/HVAC | 6 |
| B5 | Coil Fouling | B3 Mechanical/HVAC | 7 |
| M3 | Pump Malfunction | B3 Mechanical/HVAC | 7 |
| R1 | Calibration Issue | B4 Sensor/Data | 6 |
| M4 | Sensor Signal Loss | B4 Sensor/Data | 7 |


## Simulated Units

| Room ID | Name | Type | Default State |
|---------|------|------|---------------|
| BC04H41 | Vertical Console | 4-Pipe Hydronic | Critical Fault -- Logic Trap |
| BC04H42 | Ceiling Cassette | 2-Pipe Cooling | Online |
| BC04H43 | Wall Split Unit | Refrigerant VRF | Maintenance Planned |
| BC04H44 | Horizontal Ceiling | 4-Pipe Hydronic | Critical Fault -- Actuator Stuck |
| BC04H45 | Ducted Concealed | 4-Pipe Hydronic | Online |
| BC04H46 | Floor Standing | 2-Pipe Heating | Maintenance Planned |


## Requirements

- Xcode 16.0 or later
- visionOS 2.0 SDK
- Apple Vision Pro (device or simulator)
- macOS Sonoma 14.0 or later


## Getting Started

```
git clone <repository-url>
cd thesis_visionpro_app
open thesis_visionpro_app.xcodeproj
```

Select the visionOS simulator or a connected Apple Vision Pro. Build and run.

The app launches into the Facility Dashboard. Two units are already in Critical Fault state (BC04H41 with a Logic Trap, BC04H44 with a stuck actuator), two are in Maintenance Planned, and two are Online. Tap "Simulate Fault" on any unit to assign a different fault and explore the diagnostics and repair workflows.


## Thesis Context

This application is the functional prototype for a Design Science Research study conducted as a bachelor thesis at TU Wien. It addresses three research questions:

**RQ1:** To what extent do AR-based support tools enhance decision-making in industrial maintenance, specifically focusing on fault diagnosis and response time?

**RQ2:** What key features and methods in AR maintenance systems improve fault diagnosis accuracy, reduce human error, and minimize downtime?

**RQ3:** What measurable impacts do AR-based maintenance tools have on operator performance, including task completion time, error rates, and system reliability?

The implementation validates the thesis through five algorithms: Logic Trap Detection (Algorithm 1), Context Recognition with Fault-Aware Routing (Algorithm 2), Interactive Maintenance Workflow with Inline Completion (Algorithm 3), Session Recording with Fault State Management (Algorithm 4), and Real-Time Analytics Computation (Algorithm 5).

Full thesis: "Augmented Reality-Driven Decision Support Systems: Applications in Maintenance and Quality Management," Tegshbayar Batbayar, Technische Universitat Wien, January 2026.


## Limitations

This is a research prototype, not a production system. Sensor data is simulated -- there is no connection to a live BMS. The immersive AR overlay is a scaffold; the current prototype operates as a windowed visionOS application. Unit identification is navigation-based rather than camera-based. All state resets when the app relaunches. Repair procedures are representative but not validated against specific manufacturer service manuals.


## Author

**Tegshbayar Batbayar**
Bachelor of Science, Technische Universitat Wien
Institute of Management Science -- Production and Quality Maintenance
Supervised by Univ.-Prof. Dr.-Ing. Fazel Ansari and Dr. Sara Elisabeth Scheffer

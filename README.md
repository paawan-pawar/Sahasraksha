# 🛡️ KAVACH
#     IBVAP --- Intelligent Border Video Analytics Platform

> **Kavach: Transforming existing CCTV infrastructure into an AI-powered
> border intelligence network.**

IBVAP (Intelligent Border Video Analytics Platform) is an AI-driven
software-defined surveillance platform designed for Border Out Posts
(BOPs), check posts, border roads, and other strategic installations.

Instead of replacing existing CCTV cameras with expensive smart-camera
hardware, IBVAP uses **AI, Computer Vision, video analytics, tracking,
and risk intelligence** to turn conventional IP-based CCTV feeds into an
intelligent surveillance system.

The core idea is simple:

**Existing CCTV = Eyes 👁️ → IBVAP = Brain 🧠 → Actionable Intelligence =
Faster Response 🚨**

------------------------------------------------------------------------

## 🚨 The Problem

Conventional CCTV systems can continuously record and display what is
happening, but they largely depend on personnel to watch multiple camera
feeds.

At border locations, this creates several challenges:

-   Continuous human monitoring is difficult across many cameras.
-   Important events can be missed during long monitoring periods.
-   Existing cameras often lack built-in AI capabilities.
-   Dedicated FRS, ANPR, smart cameras, and specialized surveillance
    hardware can increase deployment cost.
-   Remote border locations may have limited connectivity and
    infrastructure.
-   Finding a specific person, vehicle, or number plate in hours of
    recorded footage is slow.
-   Operators need to know **what happened, where it happened, how risky
    it is, and what requires attention first**.

### The gap

> CCTV can **see** the event, but it does not automatically
> **understand, prioritize, retrieve, and respond** to the event.

IBVAP addresses this gap.

------------------------------------------------------------------------

# 💡 Our Solution

IBVAP adds an AI intelligence layer on top of existing CCTV
infrastructure.

``` text
IP CCTV Cameras
       ↓
   Video Streams
       ↓
 AI / Computer Vision
       ↓
Detect → Identify → Classify → Track → Analyze
       ↓
Risk Intelligence
       ↓
Alert → Log → Prioritize → Respond
```

The system continuously analyzes video feeds and converts raw footage
into structured security intelligence.

------------------------------------------------------------------------

# ⭐ Key Features

## 1. 👤 Human Detection & Tracking

Detects people in CCTV footage and tracks their movement across frames.

The system can maintain information such as:

-   Person location
-   Movement direction
-   Entry/exit activity
-   Last-seen location
-   Movement history
-   Camera association

This allows operators to follow a person without manually watching every
camera.

------------------------------------------------------------------------

## 2. 🚙 Vehicle Detection & Classification

Automatically detects vehicles and classifies them based on visual
characteristics.

Possible intelligence includes:

-   Vehicle detection
-   Vehicle type/class
-   Direction of movement
-   Camera/location
-   Time of appearance
-   Last-seen location
-   Cross-camera movement

------------------------------------------------------------------------

## 3. 🔢 Automatic Number Plate Recognition (ANPR)

IBVAP can extract number plates from detected vehicles and associate
them with the corresponding vehicle event.

A number plate can become a searchable identifier:

``` text
Search: "TI-9982"
        ↓
Vehicle detected
        ↓
Camera + timestamp
        ↓
Location + movement history
        ↓
Associated events
```

This reduces the time required to manually search large amounts of
recorded footage.

------------------------------------------------------------------------

## 4. 🔎 AI Scene Search & Retrieval

One of the platform's key intelligence capabilities is
**natural-language search over surveillance footage**.

Operators can search using descriptions rather than manually scanning
recordings.

### Example

> **"Find red-shirt persons near Gate 3 between 2--3 PM."**

The system can retrieve relevant detections and provide:

-   Matching person/vehicle
-   Camera
-   Timestamp
-   Location
-   Last-seen position
-   Movement history
-   Associated events

It can also search using identifiers such as:

> **"Find vehicle with number plate TI-9982."**

### Search. Locate. Track. Investigate.

------------------------------------------------------------------------

# 🧠 Unique Intelligence Layer

IBVAP goes beyond simple object detection by adding an intelligence
layer that helps operators decide **what matters most**.

## 5. 🧬 Border Behavior Fingerprint

The system learns normal movement and activity patterns around monitored
border zones.

Instead of looking only for predefined objects, it can identify
deviations from expected behavior.

Examples:

-   Unusual movement near restricted areas
-   Unexpected movement at unusual times
-   Abnormal activity patterns
-   Repeated suspicious movement
-   Deviations from established movement behavior

> **Normal behavior → Learn patterns → Detect deviation → Flag anomaly**

This helps identify suspicious activity that may not be obvious from
object detection alone.

------------------------------------------------------------------------

## 6. 🎯 Adaptive Risk Score

Every detected event receives a dynamic risk score based on factors such
as:

-   Event type
-   Location
-   Time
-   Behavior
-   Context
-   Severity
-   Relationship with other events

Example:

``` text
Person detected              → Low
Vehicle in restricted zone  → Medium
Person crossing virtual fence → High
Suspicious movement + fence breach → Critical
```

The purpose is not simply to generate more alerts, but to **prioritize
the alerts that deserve attention first**.

------------------------------------------------------------------------

## 7. 👁️ AI Attention Queue

Instead of forcing operators to continuously watch dozens of camera
feeds, IBVAP creates an **AI Attention Queue**.

For example:

``` text
50 CCTV Feeds
      ↓
AI analyzes all feeds
      ↓
Risk scoring
      ↓
┌───────────────────────────────┐
│ 🔴 CAM-37  Risk: 94           │
│ Intrusion detected            │
├───────────────────────────────┤
│ 🟠 CAM-18  Risk: 76           │
│ Suspicious vehicle movement   │
├───────────────────────────────┤
│ 🟡 CAM-09  Risk: 52           │
│ Unusual movement              │
└───────────────────────────────┘
```

The highest-priority camera/event can automatically be surfaced on the
operator dashboard.

### Result

**The operator watches what matters, instead of trying to watch
everything.**

------------------------------------------------------------------------

## 8. 🗺️ Coverage Intelligence

IBVAP analyzes camera coverage and observed movement patterns to
identify potential surveillance gaps.

It can highlight:

-   Camera blind spots
-   Areas with insufficient visibility
-   Frequently used paths outside effective coverage
-   Vulnerable zones
-   Locations where additional camera coverage or personnel deployment
    may be useful

The intelligence can support better placement of:

-   Cameras
-   Patrols
-   Soldiers/security personnel
-   Other monitoring resources

------------------------------------------------------------------------

## 9. 🚧 Virtual Fence / Intrusion Detection

A virtual boundary can be defined inside the camera view.

When a person or vehicle crosses the configured boundary:

``` text
Virtual Boundary
────────────────────────
       👤
        ↓
   🚨 Breach Detected
        ↓
Risk Score
        ↓
Real-Time Alert
        ↓
Event Log
```

This provides automated monitoring of restricted or sensitive zones.

------------------------------------------------------------------------

## 10. 🌙 Night-Time Movement Detection

IBVAP supports surveillance scenarios where movement must be detected
under low-light or nighttime conditions.

The system can flag relevant movement events and prioritize them based
on configured security rules and contextual risk.

------------------------------------------------------------------------

## 11. 🚨 Real-Time Alerts & Event Logging

When a significant event is detected, IBVAP can generate a real-time
alert containing relevant information such as:

-   Event type
-   Camera
-   Timestamp
-   Location
-   Risk score
-   Detection snapshot
-   Associated person/vehicle
-   Event status

Events are also logged for later investigation.

------------------------------------------------------------------------

# 🔄 End-to-End Intelligence Pipeline

IBVAP follows a structured surveillance-to-intelligence workflow:

``` text
┌──────────────────────────┐
│  1. EXISTING CCTV        │
│  The Eyes                │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│  2. IBVAP / KAVACH       │
│  The Brain               │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│  3. DETECT               │
│  Person / Vehicle /      │
│  Intrusion / Object      │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│  4. IDENTIFY             │
│  Face / Number Plate /   │
│  Vehicle / Object        │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│  5. TRACK                │
│  Location / Path /       │
│  Movement History        │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│  6. ANALYZE              │
│  Behavior / Risk /       │
│  Coverage / Context      │
└────────────┬─────────────┘
             ↓
┌──────────────────────────┐
│  7. RESPOND              │
│  Alert / Log / Attention │
│  Queue / Investigation   │
└──────────────────────────┘
```

------------------------------------------------------------------------

# 🏗️ System Architecture

``` text
                     EXISTING CCTV NETWORK
                  ┌──────┬──────┬──────┬──────┐
                  │ Cam1 │ Cam2 │ Cam3 │ ...50+│
                  └───┬──┴───┬──┴───┬──┴──────┘
                      │      │      │
                      └──────┼──────┘
                             ↓
                     RTSP / IP Streams
                             ↓
                ┌─────────────────────────┐
                │ Video Processing Layer  │
                │ OpenCV / Stream Manager │
                └────────────┬────────────┘
                             ↓
                ┌─────────────────────────┐
                │ AI / CV Inference       │
                │ Detection + Tracking     │
                │ ANPR + Analytics         │
                └────────────┬────────────┘
                             ↓
                ┌─────────────────────────┐
                │ Intelligence Engine     │
                │                         │
                │ Risk Score              │
                │ Behavior Analysis       │
                │ Coverage Intelligence   │
                │ Event Correlation       │
                └────────────┬────────────┘
                             ↓
                     ┌───────────────┐
                     │    FastAPI    │
                     │ Backend/API   │
                     └───────┬───────┘
                             │
                 REST API + WebSocket
                             │
                             ↓
                ┌─────────────────────────┐
                │     Flutter Desktop     │
                │    Command Center       │
                ├─────────────────────────┤
                │ Live CCTV Grid           │
                │ AI Attention Queue       │
                │ Risk Dashboard           │
                │ ANPR Search              │
                │ Person/Vehicle Search    │
                │ Map & Tracking           │
                │ Alerts & Event Logs      │
                └─────────────────────────┘
```

------------------------------------------------------------------------

# 🖥️ Command Center

The primary interface is designed as a **desktop surveillance command
center**.

### Core dashboard components

-   Multi-camera CCTV grid
-   Selected/high-risk camera view
-   AI Attention Queue
-   Real-time alerts
-   Adaptive Risk Score
-   Person search
-   Vehicle search
-   Number plate search
-   Movement history
-   Camera/location map
-   Event timeline
-   Evidence/event logs
-   Camera health/status

### Smart monitoring concept

IBVAP does not require an operator to stare at every feed continuously.

Instead:

> **AI monitors → AI prioritizes → Human decides → Security personnel
> respond**

This keeps humans in the decision loop while reducing repetitive
monitoring.

------------------------------------------------------------------------

# ⚙️ Technology Stack

  -----------------------------------------------------------------------
  Layer                               Technology
  ----------------------------------- -----------------------------------
  Desktop UI                          **Flutter**

  Backend API                         **FastAPI / Python**

  AI / Computer Vision                **Python, OpenCV, YOLO-family
                                      detection models, tracking models**

  ANPR                                **OCR + number-plate detection
                                      pipeline**

  Real-time communication             **WebSockets**

  Database                            **PostgreSQL**

  Video input                         **IP CCTV / RTSP**

  Maps                                **Map-based visualization**

  Deployment                          **Docker / Edge or Cloud
                                      infrastructure**
  -----------------------------------------------------------------------

> Specific models and infrastructure components can be replaced or
> upgraded without redesigning the overall platform.

------------------------------------------------------------------------

# 📈 Why This Approach Is Different

### Traditional CCTV

``` text
Camera
  ↓
Video
  ↓
Human watches
  ↓
Human notices event
  ↓
Human investigates
```

### IBVAP

``` text
Camera
  ↓
AI sees
  ↓
AI understands
  ↓
AI identifies
  ↓
AI tracks
  ↓
AI scores risk
  ↓
AI prioritizes
  ↓
Human responds
```

The objective is not to replace CCTV.

The objective is to **make existing CCTV intelligent**.

------------------------------------------------------------------------

# 💰 Cost & Deployment Advantage

IBVAP follows a **software-defined surveillance** approach.

Instead of requiring every location to replace conventional CCTV cameras
with specialized smart hardware, the platform can use existing IP camera
infrastructure wherever the required video streams are available.

### Benefits

-   Reuse existing CCTV infrastructure
-   Reduce dependence on specialized smart-camera hardware
-   Enable phased deployment
-   Scale from a small installation to multiple BOPs
-   Add AI capabilities through software
-   Support edge deployment for remote locations
-   Reduce continuous manual monitoring workload

------------------------------------------------------------------------

# 📦 Scalability

The platform is designed around modular AI services.

``` text
1 BOP
 ↓
10 Cameras
 ↓
50 Cameras
 ↓
100+ Cameras
 ↓
Multiple BOPs / Strategic Locations
```

Additional capabilities can be introduced as independent modules:

``` text
Core Platform
├── Person Detection
├── Vehicle Analytics
├── ANPR
├── Tracking
├── Intrusion Detection
├── Behavior Analytics
├── Risk Engine
├── Coverage Intelligence
├── AI Search
└── Alert & Event Management
```

------------------------------------------------------------------------

# 🔐 Security & Human-in-the-Loop

IBVAP is designed as a decision-support system.

AI-generated detections and alerts should assist security personnel
rather than blindly automate operational decisions.

Important events can be:

-   Reviewed by authorized personnel
-   Verified against video evidence
-   Logged with timestamps
-   Investigated through historical data
-   Escalated according to configured policies

Access control, secure communication, audit logging, retention policies,
and deployment-specific privacy/security requirements should be enforced
in production.

------------------------------------------------------------------------

# 🎯 Expected Impact

### Enhanced Border Security

Continuous AI-assisted monitoring can help identify potential intrusions
and suspicious activity faster.

### Faster Response

High-risk events are surfaced automatically instead of requiring
operators to discover them manually.

### Reduced Manual Monitoring

AI handles repetitive video analysis while personnel focus on decisions
and response.

### Better Situational Awareness

Operators can understand **who, what, where, when, and how** from
surveillance data.

### Faster Investigation

Natural-language search and structured event logs reduce the effort
required to locate relevant footage.

### Cost-Effective Modernization

Existing CCTV infrastructure can become an entry point for advanced
video intelligence without requiring complete camera replacement.

### Scalable Deployment

The modular architecture can be extended across cameras, BOPs, check
posts, border roads, and strategic installations.

------------------------------------------------------------------------

# 🧪 Example Scenarios

## Scenario 1 --- Border Intrusion

``` text
Person approaches restricted zone
        ↓
Person detected
        ↓
Virtual fence crossed
        ↓
Behavior/context evaluated
        ↓
High risk score
        ↓
AI Attention Queue
        ↓
Real-time alert
        ↓
Operator reviews camera
```

## Scenario 2 --- Vehicle Investigation

``` text
Vehicle enters monitored area
        ↓
Vehicle detected + classified
        ↓
Number plate extracted
        ↓
Event stored
        ↓
Operator searches plate
        ↓
Matching events retrieved
        ↓
Movement history displayed
```

## Scenario 3 --- Person Search

``` text
Operator:
"Find red-shirt person near Gate 3, 2–3 PM"
        ↓
AI search
        ↓
Matching detections
        ↓
Camera + timestamp
        ↓
Location
        ↓
Movement history
        ↓
Associated events
```

## Scenario 4 --- Coverage Gap

``` text
Camera footage + movement patterns
              ↓
Coverage analysis
              ↓
Potential blind spot identified
              ↓
Coverage Intelligence
              ↓
Suggested camera / patrol deployment
```

------------------------------------------------------------------------

# 🚀 Project Vision

IBVAP aims to move border surveillance from:

> **"Watching cameras"**

to

> **"Understanding the border."**

The long-term vision is a unified intelligence layer that can transform
existing surveillance infrastructure into a **proactive, searchable,
risk-aware, and scalable security network**.

------------------------------------------------------------------------

# 🛣️ Future Scope

-   Advanced multi-camera re-identification
-   Improved low-light/night analytics
-   More sophisticated behavioral models
-   Edge AI deployment on remote BOPs
-   Offline-first operation with synchronization
-   Integration with existing Command & Control systems
-   Role-based access control
-   Advanced geospatial intelligence
-   Cross-camera entity correlation
-   Historical trend analysis
-   Additional sensor integration
-   Mobile field application for authorized personnel

------------------------------------------------------------------------

# 👥 Project

**Project:** IBVAP --- Intelligent Border Video Analytics Platform\
**Code Name:** Kavach\
**Domain:** AI / Computer Vision / Border Security / Video Analytics

------------------------------------------------------------------------

## ⭐ Core Idea

> **Don't replace the cameras. Upgrade their intelligence.**

**Existing CCTV → AI Understanding → Actionable Border Intelligence**

------------------------------------------------------------------------

## 📄 License

Add your project's selected open-source or proprietary license here.

------------------------------------------------------------------------

### 🛡️ IBVAP --- KAVACH

**From Surveillance to Intelligence.**

------------------------------------------------------------------------

# AI Trailing MVP

AI Trailing is implemented as a separate Python backend under `backend/Ai_trailing/` and a Flutter operator surface at `lib/pages/ai_trailing.dart`. The backend has no fabricated entity seed data: the dashboard reports an empty state until a configured video pipeline writes observations.

## Backend setup

```powershell
cd backend\Ai_trailing
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:PYTHONPATH = (Get-Location).Path
uvicorn app.main:app --reload --port 8000
```

Run the focused tests with `python -m pytest`. The API exposes `/health`, `/entities`, `/entities/{global_id}`, `/entities/{global_id}/trajectory`, `/entities/{global_id}/history`, `/entities/{global_id}/prediction`, `/cameras`, `/cameras/{camera_id}/connections`, and `/ws/tracking`.

## CV pipeline and configuration

`backend/config/cameras.yaml` is the backend-local camera graph and recorded-video configuration. `Yolo11Detector` uses `yolo11x.pt` through Ultralytics and filters person, car, motorcycle, bus, and truck classes. `ByteTrackTracker` keeps IDs scoped to each camera; those IDs are never used as global identity. Add a recorded source under the configured path, call `Yolo11Detector.load()`, and feed frames through the detector/tracker adapters.

`PersonReIDEncoder` and `VehicleReIDEncoder` are explicit adapters for OSNet/FastReID and vehicle embedding/ANPR integrations. Until a trained encoder and observation ingestion worker are wired, no cross-camera identity is claimed. `CrossCameraMatcher` combines appearance, entity type, camera connectivity, and travel-time consistency and returns its evidence and confidence.

Coordinates are image-space by default. A future homography/calibration adapter must mark ground coordinates as `ground`; the trajectory metrics only report metres-per-second when ground positions are available.

`MarkovCameraPredictor` learns transition frequencies from stored entity histories and constrains predictions to non-restricted graph edges. Probabilities are returned for every prediction; it does not present a route as certain. PostgreSQL table definitions are in `backend/Ai_trailing/schema.sql`, ready to replace the current in-memory store.

## Scene Search backend

The natural-language visual event search backend is under `backend/scene_search/`. It provides SQLite event indexing, query parsing, hybrid metadata/scoring search, optional FAISS vectors, plate normalization, behavior features, and an OpenCV sampling interface.

```powershell
cd backend\scene_search
..\..\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:PYTHONPATH = (Get-Location).Path
uvicorn main:app --reload --port 8001
```

Index events with `POST /events`, search with `POST /search`, and inspect the API at `http://127.0.0.1:8001/docs`. Tests run from the repository backend directory with `python -m pytest scene_search/tests -q`.

## Flutter dashboard

```powershell
flutter pub get
flutter run -d windows
```

Open **AI Trailing** or **Scene Search** from the left navigation. Configure backend URLs without editing Dart source:

```powershell
flutter run -d windows --dart-define=IBVAP_AI_TRAILING_API_URL=http://127.0.0.1:8000 --dart-define=IBVAP_SCENE_SEARCH_API_URL=http://127.0.0.1:8001
```

AI Trailing reads `/entities`; Scene Search submits queries to `/search`. Defaults target local development, while deployed/private backend URLs can be supplied through the same `--dart-define` variables.

## Current limitations and next improvements

- The video ingestion worker, homography editor, PostgreSQL repository, and Redis/WebSocket publish hook still need wiring.
- Re-ID model weights and ANPR are intentionally not bundled; install compatible model packages and implement the encoder adapters for production matching.
- Add observation ingestion from OpenCV recorded files first, then RTSP reconnect/backpressure handling.
- Bind trajectory/prediction response models to Flutter and add evidence clip retrieval.



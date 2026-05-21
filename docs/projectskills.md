# HunarLink — Project Skills & Requirements Reference
> This file is the single source of truth for all project requirements, evaluation criteria,
> system specifications, and implementation checklists.
> Agents must cross-check all functions and features against this document.

---

## 1. Challenge Identity

| Field | Value |
|-------|-------|
| Competition | Google Antigravity Hackathon 2026 |
| Challenge | Challenge 2 — AI Service Orchestrator for Informal Economy |
| Team | Ghulam Mustafa (AI + Backend) & Haider (Flutter Mobile) |
| University | SZABIST Islamabad |
| Deadline | May 20, 2026 |
| Project Name | HunarLink |
| Tagline | Book any home service in seconds — in your language |

---

## 2. Problem Statement

Pakistan's informal service economy operates through WhatsApp, phone calls, and word-of-mouth.
This causes:
- Inefficient service matching
- Missed opportunities for providers
- Lack of automation
- Poor user experience
- Users cannot find reliable services quickly
- No real-time availability
- No trusted provider discovery

---

## 3. Mandatory System Requirements

### 3.1 Intent Understanding
The system MUST:
- [ ] Process natural language input
- [ ] Support Urdu language
- [ ] Support Roman Urdu language
- [ ] Support English language
- [ ] Extract service type from input
- [ ] Extract location from input
- [ ] Extract time preference from input

**Verification:** Run these 3 inputs and confirm structured JSON output:
```
Input 1: "Mujhe G-13 mein kal subah AC technician chahiye"  [Roman Urdu]
Input 2: "مجھے کل صبح جی-13 میں اے سی ٹیکنیشن چاہیے"       [Urdu]
Input 3: "Need electrician in I-8 urgent"                   [English]
```

Expected output format:
```json
{
  "service_category": "AC Technician",
  "location": "G-13 Islamabad",
  "time_preference": "tomorrow_morning"
}
```

---

### 3.2 Provider Discovery
The system MUST:
- [ ] Query Google Maps Places API OR use mock dataset
- [ ] Identify nearby providers by location
- [ ] Match providers to service category
- [ ] Return minimum 3 providers per query

**Verification:** Confirm `fetch_maps_data` tool returns providers array with:
- `displayName.text` — provider name
- `formattedAddress` — full address
- `rating` — Google rating
- `estimatedDistanceKm` — calculated distance
- `distanceLabel` — human readable distance

---

### 3.3 Matching & Ranking
The system MUST:
- [ ] Rank providers by distance
- [ ] Rank providers by availability
- [ ] Rank providers by rating
- [ ] Return top 3 ranked providers
- [ ] Provide clear reasoning for selection

**Scoring Formula (MUST match exactly):**
```
Score = (0.40 × proximity_score) + (0.35 × rating_score) + (0.25 × availability_score)

proximity_score:
  1.0 = distance < 2km
  0.8 = distance < 4km
  0.6 = distance < 6km
  0.4 = distance >= 6km

rating_score:
  provider.rating / 5.0

availability_score:
  1.0 = time_preference != today_urgent
  0.5 = flexible
  0.0 = today_urgent
```

**Verification:** Confirm `rank_and_select` tool outputs:
```json
{
  "ranked": [...top 3 providers with scores...],
  "selected": { ...best provider... },
  "reasoning": "Plain English explanation"
}
```

---

### 3.4 Decision & Recommendation
The system MUST:
- [ ] Select the single best provider automatically
- [ ] Show top 3 options to user
- [ ] Explain decision in simple plain terms
- [ ] Reasoning must be human-readable

---

### 3.5 Action Simulation (CRITICAL REQUIREMENT)
The system MUST simulate at least ONE of:
- [ ] Updating a mock booking system ✓ (Firebase Firestore)
- [ ] Creating a confirmation message ✓
- [ ] Writing to a database ✓ (active_bookings collection)
- [ ] Generating a booking receipt ✓ (Flutter success screen)

**Verification:** Confirm Firebase document at `active_bookings/{userId}` contains:
```json
{
  "booking_id": "BK-{timestamp}",
  "user_id": "{userId}",
  "status": "confirmed",
  "provider_name": "{selected provider}",
  "service_category": "{from intent}",
  "service_time": "{human readable}",
  "provider_distance": "{X.X km}",
  "provider_rating": "{rating}",
  "reasoning": "{why selected}",
  "created_at": "{ISO timestamp}",
  "reminder_at": "{ISO timestamp}"
}
```

---

### 3.6 Follow-Up Automation
The system MUST simulate:
- [ ] Reminder notification (1 hour before appointment)
- [ ] Status updates
- [ ] Completion confirmation

**Verification:** Confirm `schedule_followup` tool returns:
```json
{
  "booking_id": "{id}",
  "trigger_at": "{ISO timestamp}",
  "message": "Reminder: {provider} arrives in 1 hour.",
  "status": "reminder_scheduled"
}
```
And Flutter fires local push notification after 10 seconds on booking success screen.

---

### 3.7 Agentic Workflow (MANDATORY)
The system MUST demonstrate:
- [ ] Multiple agents OR structured reasoning pipeline
- [ ] Planning → decision → action → follow-up sequence
- [ ] Traceable logs of decisions
- [ ] Traceable logs of tool usage
- [ ] Traceable logs of action execution

**Verification:** `trace_001.txt` must contain blocks in this exact format:
```json
{
  "agent": "HunarLinkOrchestrator",
  "tool": "{tool_name}",
  "step": {1-5},
  "input": { ... },
  "reasoning": "{explanation}",
  "output": { ... },
  "duration_ms": {number},
  "status": "success"
}
```

---

## 4. Mandatory Google Antigravity Requirements

| Requirement | Implementation | Verification |
|-------------|---------------|--------------|
| Orchestrate agent workflows | `HunarLinkOrchestrator.run()` sequences all 5 tools | Call `antigravityAgent.run()` and confirm 5 tools fire in order |
| Manage multi-step reasoning | `reasoning` field in every trace block | Check trace_001.txt for `reasoning` in each block |
| Integrate tools — Maps API | `fetch_maps_data` tool calls Google Maps Places API | Confirm real provider names returned, not mock |
| Integrate tools — Firebase | `execute_booking` tool writes to Firestore | Check Firebase Console for `active_bookings` document |
| Integrate tools — Gemini LLM | `parse_intent` tool calls Gemini API | Confirm multilingual parsing works |
| Execute actions — booking | Firebase Firestore write confirmed | booking_id generated and stored |
| Execute actions — notifications | Flutter local notification fires | 10-second delay notification visible |
| Antigravity central to logic | All pipeline flows through `antigravityAgent.run()` | No direct tool calls outside agent |

**CRITICAL:** Antigravity must NOT be used superficially.
It must be the orchestrator — not just the IDE where code was written.

---

## 5. Agent Architecture

### 5.1 Agent Name
```
HunarLinkOrchestrator
```

### 5.2 Agent Description
```
End-to-end service booking agent for Pakistan's informal economy.
Orchestrated by Google Antigravity's agent runner framework.
Antigravity manages tool sequencing, state passing, reasoning
emission, and trace logging across all 5 tools.
```

### 5.3 Context Object (State between tools)
```javascript
const context = {
  input:     userInput,   // raw user text
  userId:    userId,      // user identifier
  intent:    null,        // filled by parse_intent
  providers: null,        // filled by fetch_maps_data
  selected:  null,        // filled by rank_and_select
  booking:   null,        // filled by execute_booking
  reminder:  null,        // filled by schedule_followup
  traces:    [],          // all tool traces appended here
};
```

### 5.4 Tool Definitions

| Tool | Step | Input | Output | External API |
|------|------|-------|--------|-------------|
| `parse_intent` | 1 | Raw user text | `{service_category, location, time_preference}` | Gemini LLM |
| `fetch_maps_data` | 2 | service_category + location | Array of 10 providers with distances | Google Maps Places API |
| `rank_and_select` | 3 | Providers array + time_preference | Top 3 ranked + selected + reasoning | None (JS logic) |
| `execute_booking` | 4 | Selected provider + userId + time | Booking payload + Firebase write | Firebase Firestore |
| `schedule_followup` | 5 | Booking payload | Reminder payload | None (JS logic) |

### 5.5 Pipeline Sequence
```
User Input
    ↓
[01] parse_intent      → structured intent JSON
    ↓
[02] fetch_maps_data   → real providers from Google Maps
    ↓
[03] rank_and_select   → top 3 ranked + selected provider
    ↓
[04] execute_booking   → Firebase write + booking_id
    ↓
[05] schedule_followup → reminder payload
    ↓
Final Response to Flutter App
```

---

## 6. API Specification

### Base URL
```
http://localhost:3000
```

### Endpoints

#### GET /health
Check server status.

Response:
```json
{
  "status": "HunarLink API running ✅",
  "mode": "MOCK | LIVE",
  "model": "gemini-2.5-flash",
  "timestamp": "ISO timestamp"
}
```

#### POST /request
Run full agent pipeline.

Request:
```json
{
  "input": "Mujhe G-13 mein kal subah AC technician chahiye",
  "userId": "user_001"
}
```

Success Response:
```json
{
  "success": true,
  "data": {
    "intent": {
      "service_category": "AC Technician",
      "location": "G-13 Islamabad",
      "time_preference": "tomorrow_morning"
    },
    "selected": {
      "name": "Abbasi Electric & AC Repair Center",
      "distance": "1 km",
      "rating": 4.9,
      "score": 0.99,
      "address": "124, G-13/4, Islamabad, Pakistan"
    },
    "booking": {
      "booking_id": "BK-1779016287619",
      "user_id": "user_001",
      "status": "confirmed",
      "provider_name": "Abbasi Electric & AC Repair Center",
      "service_category": "AC Technician",
      "service_time": "10:00 AM Tomorrow",
      "provider_distance": "1 km",
      "provider_rating": "4.9",
      "reasoning": "Selected as the closest available provider with a 4.9 rating.",
      "created_at": "ISO timestamp",
      "reminder_at": "ISO timestamp"
    },
    "reminder": {
      "booking_id": "BK-1779016287619",
      "trigger_at": "ISO timestamp",
      "message": "Reminder: Abbasi Electric & AC Repair Center arrives in 1 hour.",
      "status": "reminder_scheduled"
    }
  }
}
```

Error Response:
```json
{
  "success": false,
  "error": "Error description"
}
```

---

## 7. Firebase Schema

### Collection: `active_bookings`
### Document ID: `{userId}` (e.g. `user_001`)

```
active_bookings/
└── user_001/
    ├── booking_id        String   "BK-1779016287619"
    ├── user_id           String   "user_001"
    ├── status            String   "confirmed"
    ├── provider_name     String   "Abbasi Electric & AC Repair Center"
    ├── service_category  String   "AC Technician"
    ├── service_time      String   "10:00 AM Tomorrow"
    ├── provider_distance String   "1 km"
    ├── provider_rating   String   "4.9"
    ├── reasoning         String   "Selected as closest available..."
    ├── created_at        String   ISO timestamp
    └── reminder_at       String   ISO timestamp
```

---

## 8. Flutter App Requirements

### 8.1 Required Screens

| Screen | Required | Connected To |
|--------|----------|-------------|
| SplashScreen | ✅ | Auto-navigate after 2.5s |
| HomeScreen | ✅ | POST /request on submit |
| ProcessingScreen | ✅ | Shows agent steps during API call |
| ResultsScreen | ✅ | Displays `data.selected` + top 3 |
| BookingConfirmScreen | ✅ | Displays `data.booking` |
| BookingSuccessScreen | ✅ | Firebase StreamBuilder live update |
| MyBookingsScreen | ✅ | Lists booking history |
| ReminderScreen | ✅ | Bottom sheet + local notification |

### 8.2 Firebase Integration Requirements
- [ ] `firebase_options.dart` present in `mobile/lib/`
- [ ] `google-services.json` present in `mobile/android/app/`
- [ ] `Firebase.initializeApp()` called in `main.dart`
- [ ] StreamBuilder in BookingSuccessScreen listening to `active_bookings/{userId}`
- [ ] UI auto-updates when Firestore document changes

### 8.3 API Integration Requirements
- [ ] `AntigravityService.processRequest()` calls `POST /request`
- [ ] Timeout set to 30 seconds
- [ ] Error handling with user-friendly SnackBar
- [ ] `AntigravityService.checkHealth()` calls `GET /health`
- [ ] Base URL configurable via constant

### 8.4 Notification Requirements
- [ ] `flutter_local_notifications` initialized in `initState()`
- [ ] Notification fires 10 seconds after booking confirmed
- [ ] Notification shows provider name and reasoning
- [ ] Guard against duplicate notifications (`_notificationTriggered` flag)

---

## 9. Tech Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Agentic Orchestration | Google Antigravity (Cameo) | Latest | Core agent pipeline |
| Mobile | Flutter | SDK 3.x | Cross-platform app |
| Backend API | Node.js + Express | 18+ | REST gateway |
| AI / NLP | Gemini via Google AI SDK | 2.5 Flash | Intent parsing |
| Provider Data | Google Maps Places API (New) | v1 | Real provider discovery |
| Database | Firebase Firestore | Latest | Booking simulation |
| Notifications | Flutter Local Notifications | ^16.3.0 | Reminder simulation |

---

## 10. Environment Configuration

### agent/.env (required keys)
```
GOOGLE_PLACES_API_KEY=    # Google Cloud Console → Maps Places API
GEMINI_API_KEY=           # Google AI Studio → API Keys
GEMINI_MODEL=             # gemini-2.5-flash (demo) | gemini-2.0-flash (dev)
MOCK_MODE=                # true (dev/testing) | false (demo day)
PORT=3000
```

### Mode Strategy
| Mode | MOCK_MODE | GEMINI_MODEL | When to use |
|------|-----------|-------------|-------------|
| Development | true | gemini-2.0-flash | All testing — saves API quota |
| Demo Day | false | gemini-2.5-flash | Recording demo video only |

---

## 11. Deliverables Checklist

| # | Deliverable | Status | Notes |
|---|-------------|--------|-------|
| 1 | Working Flutter Mobile App | ⬜ | APK or Expo Go |
| 2 | Demo Video 3-5 minutes | ⬜ | Record May 20 |
| 3 | Agent Trace Logs | ✅ | `trace_001.txt` with JSON blocks |
| 4 | README — architecture | ✅ | Complete |
| 4 | README — Antigravity usage | ✅ | Complete |
| 4 | README — APIs/tools used | ✅ | Complete |
| 4 | README — assumptions/limitations | ✅ | Complete |

### Demo Video Must Show (3-5 minutes):
- [ ] User types input in Flutter app
- [ ] System understands and parses intent
- [ ] Provider matching with ranking shown
- [ ] Booking simulation — Firebase write visible
- [ ] Follow-up workflow — reminder notification fires
- [ ] Antigravity trace logs visible (split screen)

---

## 12. Evaluation Criteria & Target Scores

| Criterion | Weight | Target | How to Achieve |
|-----------|--------|--------|---------------|
| Google Antigravity | 25% | 23/25 | Show agent running in Antigravity, trace logs exported |
| Agentic Reasoning & Workflow | 20% | 19/20 | 5-step pipeline, context passing, JSON reasoning visible |
| Matching Quality & Decision Logic | 20% | 19/20 | Real Maps data, weighted formula, top 3 with scores |
| Action Simulation & Execution | 15% | 14/15 | Firebase write, StreamBuilder live update, receipt |
| Technical Implementation | 10% | 8/10 | Clean architecture, real APIs, error handling |
| Innovation & UX | 10% | 8/10 | Multilingual, glassmorphism UI, Pakistan-specific |
| **TOTAL** | **100%** | **91/100** | |

---

## 13. Agent Verification Checklist

When verifying any function, check against ALL of these:

### Backend Verification
```
[ ] parse_intent returns valid JSON with all 3 fields
[ ] parse_intent handles Roman Urdu correctly
[ ] parse_intent handles Urdu correctly
[ ] parse_intent handles English correctly
[ ] fetch_maps_data returns real Google Maps providers
[ ] fetch_maps_data returns maximum 10 results
[ ] fetch_maps_data adds estimatedDistanceKm to each provider
[ ] rank_and_select returns exactly top 3 providers
[ ] rank_and_select uses correct scoring formula
[ ] rank_and_select generates human-readable reasoning
[ ] execute_booking writes to active_bookings collection
[ ] execute_booking generates unique booking_id
[ ] execute_booking sets status = "confirmed"
[ ] schedule_followup sets reminder 24hrs after booking
[ ] schedule_followup message mentions provider name
[ ] agent.run() passes context correctly between all 5 tools
[ ] agent.run() generates trace block for every tool
[ ] trace blocks contain: agent, tool, step, input, reasoning, output, duration_ms, status
[ ] server.js uses antigravityAgent.run() not runHunarLinkPipeline directly
[ ] POST /request returns success:true with all 4 data objects
[ ] GET /health returns server status with mode and model
```

### Flutter Verification
```
[ ] App runs without errors on Android
[ ] HomeScreen submit calls AntigravityService.processRequest()
[ ] ProcessingScreen shows animated steps during API call
[ ] ResultsScreen shows real provider data from API response
[ ] ResultsScreen shows top 3 providers with scores and reasoning
[ ] BookingConfirmScreen shows booking summary correctly
[ ] BookingSuccessScreen has StreamBuilder on active_bookings/{userId}
[ ] BookingSuccessScreen auto-updates when Firebase document written
[ ] Local notification fires 10 seconds after booking confirmed
[ ] Notification is not duplicated on screen rebuilds
[ ] MyBookingsScreen shows booking history
[ ] Error states handled with SnackBar messages
[ ] All screens use consistent dark glassmorphism design
```

---

## 14. Assumptions & Limitations

### Assumptions
1. All service requests are within Islamabad — location defaults to Islamabad if not specified
2. Provider distance estimated from result order (index 0 = 1km, +0.4km per result)
3. Provider availability is simulated — real availability requires two-sided provider app
4. Booking confirmation is a Firestore write simulating real system state change
5. userId is a simple string — no full auth system in hackathon scope
6. Single user session — no persistent history across app restarts

### Limitations
1. No real provider onboarding — providers from Google Maps, not registered database
2. No payment integration — booking is simulated only
3. Gemini free tier — 20 requests/day; paid tier needed for production
4. Local server — API on localhost; needs cloud deployment for production
5. Android only — iOS not configured for hackathon scope
6. Distance is estimated not GPS-calculated — real distance needs Distance Matrix API

### What This Successfully Demonstrates
- End-to-end agentic workflow via Google Antigravity orchestration
- Real multilingual NLP across 3 languages
- Real provider discovery via Google Maps Places API (not mock data)
- Simulated booking with live Firebase state change
- Live Flutter UI updates via StreamBuilder
- Automated follow-up with local push notification
- Complete traceable agent logs in structured JSON format

---

*HunarLink — Google Antigravity Hackathon 2026 — Challenge 2*
*Ghulam Mustafa & Haider — SZABIST Islamabad*
*Last updated: May 18, 2026*

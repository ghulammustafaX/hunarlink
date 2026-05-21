# 🔗 HunarLink

> **Book any home service in seconds with Just a Text**

An AI-powered, multilingual platform that instantly connects users with reliable local professionals, text a request in Urdu, Roman Urdu, or English. HunarLink instantly finds, ranks, and books a verified provider. Live updates + push notifications included.

## 📌 What is HunarLink?

Pakistan's informal service economy — AC technicians, plumbers, electricians, tutors, beauticians — operates almost entirely through WhatsApp, phone calls, and word-of-mouth referrals. There is no unified, intelligent system to connect users with the right provider at the right time.

HunarLink is an **Agentic AI system** that transforms a simple natural-language request into a fully orchestrated service booking — in Urdu, Roman Urdu, or English — without any manual steps.

A user types:
```
"Mujhe G-13 mein kal subah AC technician chahiye"
```

And HunarLink:
1. **Understands** the request in any language
2. **Discovers** real nearby providers via Google Maps Places API
3. **Ranks** them intelligently by distance, rating, and availability
4. **Books** a slot — writes confirmation to Firebase Firestore
5. **Confirms** — Flutter app updates live via StreamBuilder
6. **Reminds** — local push notification fires before appointment

---

## 🧩 Problem It Solves

| User Pain | Provider Pain |
|-----------|--------------|
| Cannot find reliable providers quickly | No structured way to receive bookings |
| No real-time availability info | Miss jobs due to zero digital visibility |
| No trust or rating mechanism | Cannot build a digital reputation |
| Language barrier with formal apps | Excluded from Pakistan's digital economy |
| No booking confirmation or reminders | High no-show rates, wasted trips |

---

## 👥 Team

| Person | Role | Owns |
|--------|------|------| 
| **Ghulam Mustafa** | AI + Backend Lead | Agent orchestration, Node.js API, Google AI integration, trace logging |
| **Muhammad Haider Ali** | Flutter Mobile Lead | Flutter app architecture, Firebase integration, real-time UI updates, local notifications |
| **Sana Abdul Aziz** | Documentation + Testing Lead | README, architecture diagrams, test case design |


---

## 🏗️ System Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                      Flutter Mobile App                          │
│  SplashScreen → HomeScreen → ProcessingScreen → ResultsScreen    │
│       → BookingConfirmScreen → BookingSuccessScreen              │
│              MyBookingsScreen  |  ReminderScreen (Bottom Sheet)  │
└─────────────────────────────┬────────────────────────────────────┘
                              │  POST /request  (90s timeout)
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│           Node.js + Express API Production Server                │
│         https://hunarlink-production.up.railway.app              │
│         GET /health  ·  POST /request                            │
└─────────────────────────────┬────────────────────────────────────┘
                              │  antigravityAgent.run()
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│          HunarLinkOrchestrator  (Google Antigravity)             │
│                                                                  │
│  [01] parse_intent      → Gemini LLM  (EN / UR / Roman UR)      │
│            ↓                                                     │
│  [02] fetch_maps_data   → Google Maps Places API (New)          │
│            ↓                                                     │
│  [03] rank_and_select   → Weighted scoring + reasoning           │
│            ↓                                                     │
│  [04] execute_booking   → Firebase Firestore WRITE               │
│            ↓                                                     │
│  [05] schedule_followup → Reminder payload + trigger_at          │
│                                                                  │
│  ◇ Structured JSON trace emitted after every tool step           │
└─────────────────────────────┬────────────────────────────────────┘
                              │  Firestore write
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│              Firebase Firestore                                  │
│         Collection: active_bookings                             │
│         Document ID: {userId}                                   │
│         Fields: booking_id · service_category · status · ...    │
└─────────────────────────────┬────────────────────────────────────┘
                              │  StreamBuilder (real-time listener)
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│    Flutter UI auto-updates → Confirmed → Completed 🎉            │
│    Local push notification fires (flutter_local_notifications)   │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🤖 How Google Antigravity Is Used

Google Antigravity orchestrates the entire booking workflow as a **5-step pipeline** that runs seamlessly from user input to confirmed booking:

**The Flow:**
1. **Parse Intent** → AI understands "AC technician in G-13 tomorrow morning" in any language (EN/UR/Roman UR)
2. **Fetch Providers** → Calls Google Maps Places API for real nearby businesses
3. **Rank & Select** → Scores providers using weighted formula: 40% distance + 35% rating + 25% availability
4. **Execute Booking** → Writes confirmed booking to Firebase Firestore
5. **Schedule Followup** → Sets reminder notification for the user

**Why Antigravity?** It manages state passing between all 5 tools — the output of step 1 becomes input to step 2, with no manual hand-offs. Every decision emits structured JSON traces for full transparency and auditability.

### Agentic Architecture & Orchestration

Google Antigravity coordinates the workflow by acting as a centralized manager that registers the tools, schedules their execution, and passes the updated state (context) down the pipeline.

#### Shared Memory (State Context)
Rather than hardcoding dependencies between tools, a shared **Context Object** acts as the memory of the agent. Each tool reads from this context, processes its task, and stores its results back into the context for the subsequent tools:

*   **User Input:** The raw text request sent by the user (Urdu, Roman Urdu, or English).
*   **User ID:** A unique identifier for the booking session.
*   **Intent Profile:** The structured intent extracted by `parse_intent` (Category, Location, Time).
*   **Provider List:** The nearby service providers returned by `fetch_maps_data`.
*   **Selected Partner:** The optimal provider chosen by the ranking algorithm in `rank_and_select`.
*   **Booking Record:** The Firestore transaction payload generated during `execute_booking`.
*   **Reminder Schedule:** The notification parameters set up by `schedule_followup`.
*   **Traces:** The step-by-step logs of all operations.


### Agent Pipeline

| Step | Tool | Input | Output | External API |
|------|------|-------|--------|-------------|
| 01 | `parse_intent` | Raw user text | `{service_category, location, time_preference}` | Gemini 2.5 Flash |
| 02 | `fetch_maps_data` | service_category + location | Array of 10 providers with distances | Google Maps Places API |
| 03 | `rank_and_select` | Providers array + time_preference | Top 3 ranked + selected + **reasoning** | JS logic |
| 04 | `execute_booking` | selected + userId + time + **service_category** | Full booking payload + Firebase write | Firebase Firestore |
| 05 | `schedule_followup` | Booking payload | Reminder payload with trigger_at | JS logic |

### Antigravity Trace Format (trace_001.txt)

Every tool emits a structured JSON trace block — this is the submission artifact demonstrating real agentic reasoning:

```json
{
  "agent": "HunarLinkOrchestrator",
  "tool": "parse_intent",
  "step": 1,
  "input": { "userText": "Mujhe G-13 mein kal subah AC technician chahiye" },
  "reasoning": "Detected Roman Urdu. Extracting service, location, time.",
  "output": {
    "service_category": "AC Technician",
    "location": "G-13 Islamabad",
    "time_preference": "tomorrow_morning"
  },
  "duration_ms": 3,
  "status": "success"
}
```

### Ranking Formula (Exact Spec Implementation)

```
Score = (0.40 × proximity_score) + (0.35 × rating_score) + (0.25 × availability_score)

proximity_score:
  1.0  =  distance < 2km
  0.8  =  distance < 4km
  0.6  =  distance < 6km
  0.4  =  distance >= 6km

rating_score:
  provider.rating / 5.0

availability_score:
  1.0  =  tomorrow_morning / today_evening / other
  0.5  =  flexible
  0.0  =  today_urgent  (emergency conflict)
```

**Sample Rankings (from trace_001.txt):**
```
1. Abbasi Electric & AC Repair  — Score: 0.99 | 1.0 km | ⭐ 4.9
2. Raja AC Services Islamabad   — Score: 0.98 | 1.4 km | ⭐ 4.7
3. Khan Brothers Technicians    — Score: 0.97 | 1.8 km | ⭐ 4.6
```

### Submission Artifacts

Our Antigravity traces prove real agentic reasoning and orchestration:
- **`agent/trace_logs/trace_001.txt`** — Full end-to-end execution trace (JSON format)
- Each tool step includes: **input** → **reasoning** → **output** → **duration**
- Ranking scores show weighted calculation at decision points
- All 5 tools execute in sequence with state passing between them

---

## 📱 Flutter App — All 8 Screens

| Screen | Purpose | Key Feature |
|--------|---------|-------------|
| `SplashScreen` | Launch screen | Auto-navigates to HomeScreen after 2.5s |
| `HomeScreen` | Main entry | Multilingual input (EN/UR/RU), bottom nav, service cards |
| `ProcessingScreen` | Loading state | Animated step display during API call |
| `ResultsScreen` | Show results | Top 3 providers with scores and AI reasoning |
| `BookingConfirmScreen` | Confirm booking | Full booking summary before Firebase write |
| `BookingSuccessScreen` | Live tracking | Firestore `StreamBuilder`, reminder notification, completion flow |
| `MyBookingsScreen` | Booking history | Active booking (live Firebase) + past bookings list |
| `ReminderScreen` | Bottom sheet | Reminder details, AI reasoning, "Test Notification Now" button |

### Firebase Integration

- `StreamBuilder` in `BookingSuccessScreen` listens to `active_bookings/{userId}`
- UI auto-updates when Firestore document changes: `confirmed` → `completed`
- Completion triggers star icon swap, green theme, and completion push notification
- `MyBookingsScreen` also streams the active booking in real-time

---

## 🛠️ Tech Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Agentic Orchestration | Google Antigravity (Cameo) | Latest | Core agent pipeline, sequencing, trace logs |
| Mobile | Flutter (Dart) | SDK 3.x | 8-screen app, Firebase StreamBuilder, notifications |
| Backend API | Node.js + Express | 18+ | REST gateway — `POST /request`, `GET /health` |
| AI / NLP | Gemini via Google AI SDK | 2.5 Flash | Multilingual intent parsing (EN/UR/Roman UR) |
| Provider Data | Google Maps Places API (New) | v1 | Real live provider discovery by location |
| Database | Firebase Firestore | Latest | Booking simulation + real-time StreamBuilder |
| Notifications | flutter_local_notifications | ^16.3.0 | Reminder + completion push notifications |

## 🔑 APIs & External Services

| API | Purpose | Free Tier | Auth Method |
|-----|---------|-----------|-------------|
| Google Gemini | Multilingual intent parsing | ~20 requests/day | API Key |
| Google Maps Places API | Real-time provider discovery | 150,000 requests/month | API Key |
| Google Distance Matrix API | Calculate distance between user and providers | 100 elements/day | API Key |
| Firebase Firestore | Booking data + real-time updates | 50k reads/20k writes/day | Service Account JSON |


---

## 📄 Firebase Schema

```
active_bookings/
└── {userId}/
    ├── booking_id        String   "BK-1779016287619"
    ├── user_id           String   "user_001"
    ├── status            String   "confirmed" | "completed"
    ├── provider_name     String   "Abbasi Electric & AC Repair"
    ├── service_category  String   "AC Technician"
    ├── service_time      String   "10:00 AM Tomorrow"
    ├── provider_distance String   "1 km"
    ├── provider_rating   String   "4.9"
    ├── reasoning         String   "Selected as closest available provider..."
    ├── created_at        String   ISO timestamp
    └── reminder_at       String   ISO timestamp (24hrs after booking)
```

---

## 🚀 Live Production & Resiliency Upgrades

We have deployed the backend server live to production and made several updates to ensure it is robust, resilient, and ready for judging:

### 1. Backend Production Deployment (Railway)
*   **Production API URL:** `https://hunarlink-production.up.railway.app/request`
*   **Healthcheck URL:** `https://hunarlink-production.up.railway.app/health`
*   **Railway Binding Configuration:** Configured the express server to listen on `0.0.0.0` and correctly bind to the Railway target networking port (`8080`).

### 2. Resilient Firebase Initialization Fallback
*   In local development, the server uses a physical `serviceAccountKey.json` credentials file.
*   For cloud deployment, we implemented a fallback that loads the credentials dynamically from the `FIREBASE_SERVICE_ACCOUNT_KEY` environment variable as a raw JSON string. If this is unavailable, it gracefully logs warning messages, ensuring the build never crashes the server container.

### 3. Flutter Network & Connectivity Fixes
*   **Internet Access:** Added `<uses-permission android:name="android.permission.INTERNET"/>` inside `AndroidManifest.xml` to allow the mobile app to communicate with the live production backend.
*   **Extended Request Timeout:** Since the complete agentic pipeline (Gemini Intent Parsing → Google Places API Discovery → Google Distance Matrix API Calculation → Firebase Firestore writes) can take up to 20-30 seconds, we extended the mobile app's API request timeout from `30 seconds` to `90 seconds` to avoid premature timeouts.
*   **Dynamic Endpoint Failover:** Rewrote the endpoints configuration to use a runtime getter, prioritizing the live Railway URL while cleanly falling back to local IPs/emulators when offline.

---

## ⚠️ Assumptions & Limitations

### Assumptions
1. All service requests are within Islamabad — location defaults to Islamabad if not specified
2. Provider availability is simulated — real availability requires a two-sided provider app
3. Booking confirmation is a Firestore write simulating a real system state change
4. `userId` is a simple string — no full auth system in hackathon scope

### Limitations
1. No real provider onboarding — providers from Google Maps
2. No payment integration — booking is simulated only
3. Gemini free tier — ~20 requests/day; paid tier needed for production
4. Distance is GPS-calculated via Google Distance Matrix API (driving distance) — falls back to index-estimate if API unavailable

> "Technology should be a bridge, not a barrier. HunarLink is our bridge to connect millions of skilled workers with those who need their services — all powered by the magic of AI."

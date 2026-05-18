# 🔗 HunarLink

> **Book any home service in seconds with Just a Text**

An AI-powered, multilingual platform that instantly connects users with reliable local professionals across Pakistan's informal economy. 

---

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
| **Ghulam Mustafa** | AI + Backend Lead | Google Antigravity, Maps API, Node.js server, Firebase writes |
| **Haider** | Flutter Mobile Lead | All screens, UI/UX, Firebase StreamBuilder, notifications |

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                       │
│         (Home → Processing → Results → Booking → Success)    │
└──────────────────────────┬──────────────────────────────────┘
                           │  POST /request
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Node.js + Express API Server                    │
│                    localhost:3000                            │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│           Google Antigravity Orchestrator                    │
│                                                             │
│  [01] parse_intent     → Gemini LLM (multilingual NLP)      │
│         ↓                                                   │
│  [02] fetch_maps_data  → Google Maps Places API             │
│         ↓                                                   │
│  [03] rank_and_select  → Weighted scoring algorithm         │
│         ↓                                                   │
│  [04] execute_booking  → Firebase Firestore WRITE           │
│         ↓                                                   │
│  [05] schedule_followup→ Reminder payload generation        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Firebase Firestore                              │
│         Collection: active_bookings                         │
│         Document ID: userId                                 │
└──────────────────────────┬──────────────────────────────────┘
                           │  StreamBuilder (real-time)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│         Flutter UI auto-updates to Booking Confirmed        │
└─────────────────────────────────────────────────────────────┘
```

---

## 🤖 How Google Antigravity Is Used

Google Antigravity is the **core orchestration engine** of HunarLink. It manages the entire multi-agent pipeline — from understanding the user's request to writing the booking to Firebase.

### Agent Pipeline

| Step | Agent | Tool | What It Does |
|------|-------|------|-------------|
| 01 | Intent Agent | `parse_intent` | Parses multilingual input (Urdu/Roman Urdu/English) into structured JSON using Gemini LLM |
| 02 | Discovery Agent | `fetch_maps_data` | Queries Google Maps Places API to find real nearby service providers |
| 03 | Ranking Agent | `rank_and_select` | Scores providers using weighted formula, selects best match with reasoning |
| 04 | Booking Agent | `execute_booking` | Writes confirmed booking to Firebase Firestore — the required action simulation |
| 05 | Follow-Up Agent | `schedule_followup` | Generates reminder payload, triggers Flutter local notification |

### Antigravity Trace Log (Sample)
```
[01] parse_intent INVOKED
     Input: "Mujhe G-13 mein kal subah AC technician chahiye"
     Output: { service_category: "AC Technician", location: "G-13 Islamabad", time_preference: "tomorrow_morning" }

[02] fetch_maps_data INVOKED
     Query: "AC Technician" near "G-13 Islamabad"
     Found: 10 providers from Google Maps Places API

[03] rank_and_select INVOKED
     1. Abbasi Electric & AC Repair Center  | Score: 0.99 | 1 km   | 4.9 stars
     2. Mehran Experts                      | Score: 0.99 | 1.8 km | 4.9 stars
     3. Top Tech Cool Engineering           | Score: 0.95 | 1.4 km | 4.3 stars
     Selected: Abbasi Electric & AC Repair Center

[04] execute_booking INVOKED
     Firebase write: active_bookings/user_001 [CONFIRMED]
     booking_id: BK-1779101471453

[05] schedule_followup INVOKED
     Reminder scheduled: 2026-05-19T10:51:11Z
     Message: "Reminder: Abbasi Electric & AC Repair Center arrives in 1 hour."

PIPELINE COMPLETE — Total time: ~3.8 seconds
```

### Ranking Formula
```
Score = (0.40 × proximity_score) + (0.35 × rating_score) + (0.25 × availability_score)

proximity_score:     1.0 if < 2km | 0.8 if < 4km | 0.6 if < 6km | 0.4 if further
rating_score:        provider.rating / 5.0
availability_score:  1.0 if available | 0.5 if flexible | 0.0 if urgent conflict
```

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Agentic Orchestration | Google Antigravity | Core agent pipeline, tool execution, trace logs |
| Mobile App | Flutter (Dart) | Cross-platform UI, Firebase StreamBuilder |
| Backend API | Node.js + Express | REST API gateway between Flutter and Antigravity |
| AI / NLP | Gemini 2.5 Flash via Antigravity | Multilingual intent parsing |
| Real-World Data | Google Maps Places API (New) | Live provider discovery by location |
| Simulation Backend | Firebase Firestore | Booking write = required action simulation |
| Notifications | Flutter Local Notifications | Simulated reminder push notification |

---

## 🚀 How to Run Locally

### Prerequisites
- Node.js v18+
- Flutter SDK 3.x
- Firebase project (hunarlink-496521)
- Google Maps API key
- Gemini API key

### 1. Clone the repo
```bash
git clone https://github.com/ghulammustafaX/hunarlink.git
cd hunarlink
```

### 2. Set up the Agent / API Server
```bash
cd agent
npm install
```

Create `.env` file:
```
GOOGLE_PLACES_API_KEY=your_google_maps_key
GEMINI_API_KEY=your_gemini_key
GEMINI_MODEL=gemini-2.5-flash
MOCK_MODE=true
PORT=3000
```

Start the server:
```bash
node server.js
```

### 3. Test the pipeline
```bash
node scratch.js
```

### 4. Set up Flutter app
```bash
cd mobile
flutter pub get
```

Add `firebase_options.dart` to `mobile/lib/` (generated via `flutterfire configure`).

Update API URL in `mobile/lib/services/antigravity_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000';
```

Run the app:
```bash
flutter run
```

---

## 📡 API Endpoints

### `GET /health`
Check server status.

**Response:**
```json
{
  "status": "HunarLink API running ✅",
  "mode": "MOCK",
  "model": "gemini-2.5-flash",
  "timestamp": "2026-05-18T10:00:00.000Z"
}
```

---

### `POST /request`
Run the full agent pipeline for a user request.

**Request Body:**
```json
{
  "input": "Mujhe G-13 mein kal subah AC technician chahiye",
  "userId": "user_001"
}
```

**Success Response:**
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
      "status": "confirmed",
      "provider_name": "Abbasi Electric & AC Repair Center",
      "service_time": "10:00 AM Tomorrow",
      "provider_distance": "1 km",
      "provider_rating": "4.9",
      "reasoning": "Selected as the closest available provider with a 4.9 rating."
    },
    "reminder": {
      "message": "Reminder: Abbasi Electric & AC Repair Center arrives in 1 hour.",
      "trigger_at": "2026-05-19T10:00:00.000Z",
      "status": "reminder_scheduled"
    }
  }
}
```

---

## 📁 Project Structure

```
hunarlink/
├── agent/                      
│   ├── tools/
│   │   ├── parse_intent.js       # Tool 1: Multilingual NLP via Gemini
│   │   ├── fetch_maps_data.js    # Tool 2: Google Maps Places API
│   │   ├── rank_and_select.js    # Tool 3: Weighted scoring algorithm
│   │   ├── execute_booking.js    # Tool 4: Firebase Firestore write
│   │   └── schedule_followup.js  # Tool 5: Reminder payload generation
│   ├── prompts/
│   │   ├── intent_agent.txt      # Active — sent to Gemini API
│   │   ├── ranking_agent.txt     # Reference — documents scoring logic
│   │   └── booking_agent.txt     # Reference — documents Firebase write
│   ├── trace_logs/
│   │   └── trace_001.txt         # Exported Antigravity pipeline logs
│   ├── agent.js                  # Master orchestrator pipeline
│   ├── server.js                 # Express REST API server
│   ├── scratch.js                # Pipeline test runner
│   └── .env                      # API keys (gitignored)
│
├── mobile/                      
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── processing_screen.dart
│   │   │   ├── results_screen.dart
│   │   │   ├── booking_confirm_screen.dart
│   │   │   └── booking_success_screen.dart
│   │   ├── widgets/
│   │   │   ├── provider_card.dart
│   │   │   └── agent_step_tile.dart
│   │   └── services/
│   │       ├── antigravity_service.dart
│   │       └── firebase_service.dart
│   └── pubspec.yaml
│
├── docs/                         # Documentation
├── README.md
└── .gitignore
```

---

## ⚠️ Assumptions & Limitations

### Assumptions
- All service requests are within Islamabad — location context defaults to Islamabad if not specified
- Provider distance is estimated based on result order from Google Maps (index 0 = 1km, increments of 0.4km per result) — real geocoding would require a separate Distance Matrix API call
- Provider availability is simulated — real availability would require a two-sided provider app
- Booking confirmation is a Firestore document write simulating a real booking system state change
- User identity is simplified to a string userId — no full auth system for hackathon scope

### Limitations
- **No real provider onboarding** — providers are discovered from Google Maps, not a registered provider database
- **No payment integration** — booking is simulated, no real transaction occurs
- **Single user session** — no persistent user accounts or booking history across sessions
- **Gemini free tier** — 20 requests/day on free tier; paid tier needed for production use
- **Local server** — API runs on localhost; needs deployment (Render/Railway) for production
- **Android only** — iOS configuration not set up for hackathon scope

### What This Demonstrates
Despite these limitations, HunarLink successfully demonstrates:
- End-to-end agentic workflow via Google Antigravity
- Real multilingual NLP (Urdu, Roman Urdu, English)
- Real provider discovery via Google Maps Places API
- Simulated booking execution with Firebase state change
- Live UI updates via Flutter StreamBuilder
- Automated follow-up scheduling

---

*HunarLink — Connecting Pakistan's skilled workforce, one booking at a time.*

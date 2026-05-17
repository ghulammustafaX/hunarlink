# HunarLink — AI-Powered Home Services Booking

> "Apni Zaroorat Batayein" — Just tell us what you need.

HunarLink is an agentic AI system that automates the end-to-end lifecycle of informal service requests in Pakistan. Speak or type in English, Urdu, or Roman Urdu — the AI does the rest.

---

## The Problem

Millions of Pakistanis need home services daily — AC technicians, plumbers, electricians. Finding them involves calling around, asking neighbors, and hoping for the best. There's no discovery, no transparency, no confirmation.

## Our Solution

A single intelligent interface powered by Google Antigravity. You describe what you need in any language. The agent understands, searches real local businesses, picks the best match, and confirms a booking — all autonomously in under 10 seconds.

---

## Demo Video

> [Link to be added before submission]

The demo shows a split screen:
- **Left:** Flutter app running on Android
- **Right:** Google Antigravity logs showing the agent's live reasoning

---

## Architecture

```
User Input (Roman Urdu / Urdu / English)
    ↓
Flutter App (chat-style UI)
    ↓
Google Antigravity Orchestrator
    ├── parse_intent       → extracts service, location, time
    ├── fetch_google_maps  → finds real local providers
    ├── rank_and_select    → scores and picks the best
    └── execute_booking    → writes to Firebase Firestore
    ↓
Firebase Firestore (active_bookings)
    ↓
Flutter StreamBuilder detects write → UI updates instantly
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter (Dart) |
| AI Orchestrator | Google Antigravity |
| Provider Discovery | Google Maps Places API |
| Simulation Backend | Firebase Firestore |
| Push Notifications | flutter_local_notifications |

---

## How Google Antigravity Is Used

Antigravity is the core of HunarLink — not a wrapper around a simple prompt, but a true multi-tool agentic pipeline:

1. **parse_intent** — Custom multilingual NLP tool. Handles Roman Urdu, Urdu, and English. Extracts structured JSON (service, location, time) from free-form text.

2. **fetch_google_maps_data** — Autonomous API tool. Constructs and fires a Google Maps Places API query based on parsed intent. Returns real businesses with ratings and coordinates.

3. **rank_and_select** — Logic tool. Applies a weighted scoring formula `(rating × 0.6 + (10 - distance) × 0.4)` to rank providers. Generates a human-readable reasoning string.

4. **execute_firebase_booking** — Action tool. Fires an HTTP POST to Firebase Firestore, writing the confirmed booking. This triggers a real-time UI update in Flutter.

Every step is logged. The agent's reasoning trace is surfaced directly in the Flutter UI as animated steps — giving users (and judges) full transparency into the AI's decision-making.

---

## How Booking Simulation Works

We simulate a two-sided marketplace without building one:

1. Antigravity selects a provider from real Maps data
2. Antigravity writes a booking document to Firestore
3. Flutter's StreamBuilder detects the Firestore write instantly
4. UI transitions from "Searching..." to "Booking Confirmed 🎉"
5. A local push notification fires 10 seconds later as a reminder

No seller needs to "accept" anything. The state change in Firebase IS the simulation.

---

## Supported Languages

- ✅ English
- ✅ Urdu
- ✅ Roman Urdu

Example inputs:
- `"Kal subah G-13 mein AC technician chahiye"`
- `"Need a plumber in F-8 today"`
- `"Electrician urgent I-8"`

---

## Team

| Name | Role |
|---|---|
| Ghulam | Google Antigravity + Backend + Maps API |
| Haider | Flutter Frontend + Firebase Integration |

---

## Firebase Project

- **Project:** HunarLink
- **Project ID:** hunarlink-496521
- **Collection:** active_bookings

---

## Running Locally

### Flutter App
```bash
git clone https://github.com/ghulammustafaX/hunarlink.git
cd hunarlink
git checkout haider/flutter
cd mobile
flutter pub get
flutterfire configure --project=hunarlink-496521
flutter run
```

### Antigravity Agent
> See `02_ANTIGRAVITY_AGENT.md` for full setup instructions.

---

## Future Roadmap (Post-Hackathon)

- Real seller app — providers receive and accept bookings on their own device
- Live GPS tracking of provider en route
- In-app payments via JazzCash / Easypaisa
- Review and rating system after service completion
- Expansion beyond Islamabad to Lahore, Karachi, Peshawar
- Voice input support (speak in any language)
- WhatsApp integration for booking confirmations

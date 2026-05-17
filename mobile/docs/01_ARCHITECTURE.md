# HunarLink — System Architecture

## What We Are Building

HunarLink (codename: Khidmat AI) is an **Agentic AI booking system** for informal home services in Pakistan — plumbers, AC technicians, electricians, tutors, beauticians, and more.

A user types or speaks a request in **English, Urdu, or Roman Urdu**. The AI agent understands it, finds real nearby providers using Google Maps, picks the best one, and simulates a confirmed booking — all autonomously, in under 10 seconds.

---

## The "One App, Two Worlds" Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        USER                                  │
│           types: "Kal subah G-13 mein AC chahiye"           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                  FLUTTER APP (Frontend)                      │
│   • Chat-style input UI                                      │
│   • Processing screen (live agent steps)                     │
│   • Results screen (provider cards)                          │
│   • Booking confirmation receipt                             │
│   • Firebase real-time listener (StreamBuilder)              │
└───────────────────────┬─────────────────────────────────────┘
                        │  raw text string
                        ▼
┌─────────────────────────────────────────────────────────────┐
│           GOOGLE ANTIGRAVITY (AI Orchestrator)               │
│                                                              │
│   Tool 1: parse_intent                                       │
│     └─ Extracts service, location, time from any language    │
│                                                              │
│   Tool 2: fetch_google_maps_data                             │
│     └─ Hits Places API, returns real local businesses        │
│                                                              │
│   Tool 3: rank_and_select                                    │
│     └─ Ranks by distance + rating, picks the best           │
│                                                              │
│   Tool 4: execute_firebase_booking                           │
│     └─ Writes confirmed booking JSON to Firestore            │
└──────────┬────────────────────────────┬──────────────────────┘
           │                            │
           ▼                            ▼
┌──────────────────┐        ┌───────────────────────┐
│  Google Maps     │        │  Firebase Firestore    │
│  Places API      │        │  (active_bookings)     │
│                  │        │                        │
│  Returns real    │        │  Flutter listens here  │
│  businesses with │        │  UI updates instantly  │
│  coords, ratings │        │  when agent writes     │
└──────────────────┘        └───────────────────────┘
```

---

## Tech Stack

| Layer | Technology | Owner |
|---|---|---|
| Frontend / Mobile | Flutter (Dart) | Haider |
| AI Orchestrator | Google Antigravity | Ghulam |
| Provider Discovery | Google Maps Places API | Ghulam |
| Simulation Backend | Firebase Firestore | Both |
| Notifications | flutter_local_notifications | Haider |

---

## Core Design Principles

1. **Decoupled by design** — Flutter and Antigravity are independent. They only share a single agreed JSON contract. Either side can be developed and tested in isolation.

2. **Agent-first, not form-first** — There are no dropdowns, no category pickers. The user speaks naturally and the agent figures it out.

3. **Simulation over complexity** — We don't need a real seller app. Firebase acts as the shared state layer. Antigravity writes to it, Flutter reads from it. That IS the two-sided marketplace simulation.

4. **Traceable reasoning** — Every agent decision is logged and surfaced in the UI. The user sees what the agent is thinking. Judges see it too.

---

## Data Flow Summary

```
User Input (text)
    → Antigravity parses intent (JSON)
    → Antigravity queries Google Maps (real businesses)
    → Antigravity ranks and selects best provider
    → Antigravity writes booking to Firebase
    → Flutter StreamBuilder detects the write
    → UI transitions: Searching → Confirmed
    → Local push notification fires after 10 seconds
```

---

## Firebase Collection Structure

**Collection:** `active_bookings`

**Document fields:**
```json
{
  "user_id": "123",
  "status": "confirmed",
  "provider_name": "Ali AC Services",
  "service_time": "10:00 AM",
  "provider_distance": "2.1 km",
  "rating": "4.8",
  "reasoning": "Closest available provider with a 4.8 rating.",
  "reminder_time": "09:00 AM",
  "agent_steps": [
    "Received input in Roman Urdu",
    "Parsed: AC Technician · G-13 · Tomorrow Morning",
    "Called Maps API → Found 4 providers",
    "Ranked by distance + rating",
    "Selected: Ali AC Services (4.8⭐, 2.1km)",
    "Booking written to Firebase ✅"
  ]
}
```

The `agent_steps` array is critical — Flutter animates these steps live on the Processing Screen so the user sees the agent's exact reasoning chain.

---

## Project IDs & Identifiers

| Item | Value |
|---|---|
| Firebase Project Name | HunarLink |
| Firebase Project ID | hunarlink-496521 |
| Firestore Collection | active_bookings |
| GitHub Repo | github.com/ghulammustafaX/hunarlink |
| Flutter Branch | haider/flutter |
| App Name (Display) | Khidmat AI |

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


```
*HunarLink — Connecting Pakistan's skilled workforce, one booking at a time.*

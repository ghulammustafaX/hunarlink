# Antigravity Agent — Setup & Tool Definitions

## Role of Antigravity in This Project

Antigravity is the **brain of HunarLink**. The Flutter app is just the face. Every intelligent decision — understanding what the user wants, finding providers, picking the best one, and executing the booking — happens inside Antigravity.

This document is the complete specification for setting up the Antigravity Orchestrator Agent.

---

## Agent Overview

**Agent Name:** HunarLink Orchestrator  
**Agent Type:** Orchestrator  
**Language Support:** English, Urdu, Roman Urdu  
**Domain:** Home services booking in Pakistani cities (Islamabad focus for MVP)

---

## The 4 Tools

### Tool 1: `parse_intent`

**Purpose:** Extract structured data from a free-form, multilingual user request.

**Instruction to paste into Antigravity:**

```
You are a multilingual service request parser for Pakistan.
Extract exactly three fields from the user input.
Input can be in English, Urdu, or Roman Urdu.
Return ONLY valid JSON, no extra text, no markdown, no explanation.

Schema:
{
  "service_category": "<e.g. AC Technician, Plumber, Electrician, Tutor, Beautician>",
  "location": "<area name, e.g. G-13 Islamabad>",
  "time_preference": "<one of: today_urgent | today | today_evening | tomorrow_morning | tomorrow | weekend | flexible>"
}

Examples:
Input: "Kal subah G-13 mein AC technician chahiye"
Output: {"service_category": "AC Technician", "location": "G-13 Islamabad", "time_preference": "tomorrow_morning"}

Input: "Need a plumber in F-8 today"
Output: {"service_category": "Plumber", "location": "F-8 Islamabad", "time_preference": "today"}

Input: "I-8 mein electrician chahiye abhi"
Output: {"service_category": "Electrician", "location": "I-8 Islamabad", "time_preference": "today_urgent"}

Input: "G-11 mein tutor chahiye weekend pe"
Output: {"service_category": "Tutor", "location": "G-11 Islamabad", "time_preference": "weekend"}

Input: "Beautician chahiye F-6 mein kal"
Output: {"service_category": "Beautician", "location": "F-6 Islamabad", "time_preference": "tomorrow"}
```

**Test inputs (run all 5 before proceeding):**
1. "Kal subah G-13 mein AC technician chahiye"
2. "Need a plumber in F-8 today"
3. "G-11 mein tutor chahiye weekend pe"
4. "Electrician urgent I-8"
5. "Beautician chahiye F-6 mein kal"

**Expected behavior:** All 5 return clean JSON matching the schema. No extra text.

---

### Tool 2: `fetch_google_maps_data`

**Purpose:** Query the Google Maps Places API with the parsed intent and return a list of real nearby providers.

**Input:** The JSON output from `parse_intent`

**API Call to construct:**
```
GET https://maps.googleapis.com/maps/api/place/textsearch/json
  ?query={service_category}+near+{location}
  &key={MAPS_API_KEY}
```

**Example call:**
```
query = "AC repair near G-13 Islamabad"
```

**What to extract from the API response (for each result in `results[]`):**
```json
{
  "name": "place.name",
  "address": "place.formatted_address",
  "rating": "place.rating",
  "user_ratings_total": "place.user_ratings_total",
  "lat": "place.geometry.location.lat",
  "lng": "place.geometry.location.lng"
}
```

**Edge case handling:**
- If `results` array is empty → return `{"error": "no_providers_found", "message": "Koi provider nahi mila is area mein."}`
- If API key fails → log the error and return a fallback mock provider list (for demo resilience)

**Fallback mock provider list (use if Maps API fails):**
```json
[
  {"name": "Ali AC Services", "rating": 4.8, "distance_km": 2.1},
  {"name": "Khan Cooling Works", "rating": 4.5, "distance_km": 3.4},
  {"name": "Quick Fix AC", "rating": 4.1, "distance_km": 5.0}
]
```

---

### Tool 3: `rank_and_select`

**Purpose:** Apply scoring logic to the provider list and select the single best provider.

**Instruction to paste into Antigravity:**

```
You are a provider ranking engine.

Given a list of providers with 'rating' (out of 5) and 'distance_km' fields, 
score each provider using this formula:

  score = (rating * 0.6) + ((10 - distance_km) * 0.4)

Sort by score descending. Take the top 3.
Mark the first as best_match: true.

Generate a human-readable reasoning string for the best match:
  "Closest available provider with a {rating}⭐ rating at {distance_km}km."

Return ONLY valid JSON:
{
  "top_providers": [
    {
      "name": "...",
      "rating": 4.8,
      "distance_km": 2.1,
      "score": 3.52,
      "best_match": true,
      "reasoning": "Closest available provider with a 4.8⭐ rating at 2.1km."
    },
    ...
  ],
  "selected": { ... } // the best_match provider object
}
```

---

### Tool 4: `execute_firebase_booking`

**Purpose:** Write the confirmed booking to Firebase Firestore and return the final structured response to Flutter.

**Action:** HTTP POST to Firebase REST API

**Endpoint:**
```
POST https://firestore.googleapis.com/v1/projects/hunarlink-496521/databases/(default)/documents/active_bookings
```

**Payload to write:**
```json
{
  "fields": {
    "user_id":          { "stringValue": "123" },
    "status":           { "stringValue": "confirmed" },
    "provider_name":    { "stringValue": "{selected.name}" },
    "service_time":     { "stringValue": "10:00 AM" },
    "provider_distance":{ "stringValue": "{selected.distance_km} km" },
    "rating":           { "stringValue": "{selected.rating}" },
    "reasoning":        { "stringValue": "{selected.reasoning}" },
    "reminder_time":    { "stringValue": "09:00 AM" },
    "agent_steps":      { "arrayValue": { "values": [
      { "stringValue": "Received input in Roman Urdu" },
      { "stringValue": "Parsed: {service_category} · {location} · {time_preference}" },
      { "stringValue": "Called Maps API → Found {n} providers" },
      { "stringValue": "Ranked by distance + rating" },
      { "stringValue": "Selected: {selected.name} ({selected.rating}⭐, {selected.distance_km}km)" },
      { "stringValue": "Booking written to Firebase ✅" }
    ]}}
  }
}
```

**After writing, return this final JSON to Flutter:**
```json
{
  "booking_id": "BK-2025-001",
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
  ],
  "top_providers": [
    {"name": "Ali AC Services", "distance": "2.1 km", "rating": "4.8", "best": true},
    {"name": "Khan Cooling Works", "distance": "3.4 km", "rating": "4.5", "best": false},
    {"name": "Quick Fix AC", "distance": "5.0 km", "rating": "4.1", "best": false}
  ]
}
```

---

## Agent Execution Order

```
User Input
    ↓
parse_intent         → returns { service_category, location, time_preference }
    ↓
fetch_google_maps_data → returns [ list of providers ]
    ↓
rank_and_select      → returns { top_providers[], selected }
    ↓
execute_firebase_booking → writes to Firestore, returns final JSON
```

**The agent must log at every step.** These logs appear on the demo split-screen.

---

## Required Antigravity Logs (For Demo)

Make sure these exact log lines print at each step:

```
[1] Received input: "{raw user text}"
[2] Language detected: Roman Urdu / English / Urdu
[3] Calling parse_intent...
[4] Parsed → service: {service_category} | location: {location} | time: {time_preference}
[5] Calling Google Maps API for "{service_category}" near "{location}"...
[6] Found {n} providers. Starting ranking...
[7] Scores calculated. Top pick: {name} (Score: {score})
[8] Triggering Firebase booking for user_id: 123...
[9] ✅ Booking confirmed. Document written to active_bookings/{doc_id}
```

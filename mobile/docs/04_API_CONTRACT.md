# API Contract — Flutter ↔ Antigravity

This document defines the single agreed interface between Haider's Flutter app and Ghulam's Antigravity agent. Both sides must conform to this contract exactly.

---

## Endpoint

**Method:** `POST`  
**URL:** `{ANTIGRAVITY_ENDPOINT}` ← Ghulam fills this in once the agent is deployed  
**Content-Type:** `application/json`

---

## Request (Flutter → Antigravity)

Flutter sends one field — the raw user input string, exactly as typed:

```json
{
  "input": "Kal subah G-13 mein AC technician chahiye"
}
```

No preprocessing. No language detection. The agent handles everything.

---

## Response (Antigravity → Flutter)

Antigravity returns this complete JSON object after running all 4 tools:

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
    {
      "name": "Ali AC Services",
      "distance": "2.1 km",
      "rating": "4.8",
      "best": true
    },
    {
      "name": "Khan Cooling Works",
      "distance": "3.4 km",
      "rating": "4.5",
      "best": false
    },
    {
      "name": "Quick Fix AC",
      "distance": "5.0 km",
      "rating": "4.1",
      "best": false
    }
  ]
}
```

---

## Field Descriptions

| Field | Type | Used By | Description |
|---|---|---|---|
| `booking_id` | string | Confirm screen | Unique booking reference |
| `status` | string | Firebase check | Always `"confirmed"` for MVP |
| `provider_name` | string | Confirm + Success screen | Name of selected provider |
| `service_time` | string | Confirm + Success screen | Scheduled service time |
| `provider_distance` | string | Results + Confirm screen | Distance from user |
| `rating` | string | Results + Confirm screen | Provider star rating |
| `reasoning` | string | Results + Confirm screen | Agent's explanation for the pick |
| `reminder_time` | string | Success screen notification | Time for push notification |
| `agent_steps` | string[] | Processing screen | Animated step-by-step log |
| `top_providers` | object[] | Results screen | All 3 ranked providers |
| `top_providers[].best` | boolean | Results screen | Marks the BEST MATCH card |

---

## Error Response

If something goes wrong (Maps API fails, no providers found, etc.):

```json
{
  "status": "error",
  "error_code": "no_providers_found",
  "message": "Koi provider nahi mila is area mein. Dobara try karein.",
  "agent_steps": [
    "Received input",
    "Parsed intent successfully",
    "Called Maps API → No results returned",
    "❌ Could not complete booking"
  ]
}
```

Flutter should check `status === "error"` and show an error state on the Processing Screen.

---

## Handshake Sequence

```
1. Flutter sends POST with { "input": "..." }
2. Antigravity runs parse_intent → fetch_google_maps_data → rank_and_select
3. Antigravity writes booking to Firestore (active_bookings collection)
4. Antigravity returns full JSON response to Flutter
5. Flutter uses agent_steps[] to animate Processing Screen
6. Flutter uses top_providers[] to populate Results Screen
7. Flutter uses booking fields to populate Confirm Screen
8. Flutter's StreamBuilder independently detects the Firestore write (backup confirmation)
```

Steps 4 and 8 both confirm the booking — the API response and the Firestore stream are two independent sources of truth. This makes the demo more robust.

---

## Notes for Ghulam (Antigravity Side)

- The `agent_steps` array must always have **exactly 6 entries** so Haider's animation timing is consistent
- `top_providers` must always return **exactly 3 providers** (use fallback mock data if Maps returns fewer)
- The `best: true` flag must appear on **exactly one** provider — the top-ranked one
- Response must return within **8 seconds** for a smooth UX — if Maps API is slow, cache or mock

## Notes for Haider (Flutter Side)

- Don't hardcode the endpoint URL in the code — store it in a `config.dart` constants file
- The `agent_steps[]` array drives the Processing Screen — once the API response arrives, start animating immediately
- Firebase StreamBuilder should run in parallel with the API call, not after it — both are independent
- If API response arrives before user finishes reading Processing Screen, hold on the last step for 1 extra second before navigating

# Sprint Timeline — What's Done, What's Next

## 5-Day Sprint Overview

| Day | Focus | Owner |
|---|---|---|
| Day 1 | Setup + Scaffold + Dummy UI | Haider + Ghulam |
| Day 2 | Logic Engine + Firebase wiring | Haider + Ghulam |
| Day 3 | Full Integration (The Handshake) | Both |
| Day 4 | Polish + Edge Cases + Notifications | Both |
| Day 5 | Demo Recording + README | Both |

---

## Day 1 — Current Day

### Ghulam's Tasks (Antigravity + Backend)

- [ ] Create Antigravity project and Orchestrator Agent
- [ ] Add 4 tools: `parse_intent`, `fetch_google_maps_data`, `rank_and_select`, `execute_firebase_booking`
- [ ] Paste `parse_intent` prompt and test with 5 Roman Urdu inputs
- [ ] Enable Google Maps Places API in Cloud Console
- [ ] Generate Maps API key and test with browser URL
- [ ] Create Firebase project `hunarlink-496521`
- [ ] Create Firestore collection `active_bookings`
- [ ] Manually add one test document to `active_bookings`
- [ ] Share Firebase config object with Haider tonight

### Haider's Tasks (Flutter)

- [ ] Install Flutter SDK + Android Studio
- [ ] Set up Android emulator (Pixel 6, API 33)
- [ ] Clone repo and checkout `haider/flutter` branch
- [ ] Run `flutter create mobile` and confirm app boots on emulator
- [ ] Install dependencies: firebase_core, cloud_firestore, http, flutter_local_notifications
- [ ] Create folder structure (screens/, widgets/, services/)
- [ ] Build Home Screen (input + submit button)
- [ ] Build Processing Screen (animated dummy steps)
- [ ] Build Results Screen (3 hardcoded provider cards)

### Tonight — Sync Point (Both)

- [ ] Ghulam shares Firebase config JSON with Haider
- [ ] Both confirm their parts work independently
- [ ] Agree on API contract JSON (see `04_API_CONTRACT.md`)
- [ ] Haider runs `flutterfire configure --project=hunarlink-496521`

---

## Day 2 — Logic Engine

### Ghulam
- [ ] Connect `fetch_google_maps_data` tool to real Maps API
- [ ] Build `rank_and_select` scoring logic (rating × 0.6 + distance × 0.4)
- [ ] Test the full Antigravity pipeline end-to-end (input → Maps → ranked output)
- [ ] Expose the agent as an HTTP endpoint Flutter can call

### Haider
- [ ] Wire Firebase into Flutter (add `google-services.json`)
- [ ] Implement `firebase_service.dart` StreamBuilder
- [ ] Implement `api_service.dart` HTTP POST stub (hardcoded response for now)
- [ ] Build Booking Confirm Screen
- [ ] Build Booking Success Screen

---

## Day 3 — The Handshake (Critical Integration Day)

**Goal:** Type in Flutter → Agent Thinks → Firebase Updated → Flutter UI Changes

- [ ] Replace `api_service.dart` stub with real Antigravity endpoint call
- [ ] Flutter Processing Screen reads `agent_steps[]` from live API response
- [ ] Flutter Results Screen reads `top_providers[]` from live API response
- [ ] Flutter Booking Confirm Screen reads from Firestore StreamBuilder
- [ ] Full end-to-end test: one real booking from type to confirmation
- [ ] Fix anything that breaks

---

## Day 4 — Polish & Edge Cases

- [ ] Implement local push notification on Booking Success Screen (10-second delay)
- [ ] Handle error state: what shows when Maps returns no results
- [ ] Handle slow API: show loading state if response takes > 5 seconds
- [ ] UI cleanup and font/color consistency
- [ ] Test on actual physical Android device (not just emulator)

---

## Day 5 — Demo Production

- [ ] Record 3-5 minute demo video
  - Split screen: Flutter app on left, Antigravity logs on right
  - Show full flow: type request → agent logs → UI updates → confirmed
- [ ] Write README.md (see `05_README_TEMPLATE.md`)
- [ ] Final code cleanup and push to GitHub
- [ ] Submit

---

## Pending — Blocked On Ghulam

These Flutter tasks cannot be started until Ghulam delivers:

| Flutter Task | Blocked On |
|---|---|
| Wire real API call in `api_service.dart` | Antigravity endpoint URL |
| Animate live `agent_steps[]` on Processing Screen | Endpoint returning correct JSON |
| Populate live `top_providers[]` on Results Screen | Endpoint returning correct JSON |
| Firestore StreamBuilder | Firebase config object (`google-services.json`) |
| `flutterfire configure` | Firebase Project ID (already known: `hunarlink-496521`) |

---

## Pending — Blocked On Haider

These backend tasks need Haider's confirmation:

| Backend Task | Blocked On |
|---|---|
| Finalize API response schema | Haider confirms JSON contract is sufficient |
| Push notification timing | Haider confirms `reminder_time` field format |

---

## What's Already Decided (No Changes Needed)

- Firebase Project ID: `hunarlink-496521`
- Firestore collection name: `active_bookings`
- Flutter branch: `haider/flutter`
- Primary color: `#0B7B6B`
- App name: `Khidmat AI`
- Scoring formula: `(rating × 0.6) + ((10 - distance_km) × 0.4)`
- Always return exactly 3 providers
- Always return exactly 6 agent_steps

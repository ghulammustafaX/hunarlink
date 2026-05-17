# Flutter Frontend — Screens, Tasks & Current Status

## Overview

The Flutter app is the user-facing layer of HunarLink. It handles:
- Accepting natural language input from the user
- Showing the agent's live reasoning steps
- Displaying ranked provider results
- Confirming the booking in a receipt-style UI
- Firing a local reminder push notification

**Primary color:** `#0B7B6B` (teal)  
**App display name:** Khidmat AI 🇵🇰  
**Target platform:** Android (MVP), iOS later  

---

## Folder Structure

```
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── processing_screen.dart
│   ├── results_screen.dart
│   ├── booking_confirm_screen.dart
│   └── booking_success_screen.dart
├── widgets/
│   ├── provider_card.dart
│   └── agent_step_tile.dart
└── services/
    ├── api_service.dart        ← calls Antigravity endpoint
    └── firebase_service.dart   ← Firestore StreamBuilder
```

---

## Screen 1 — Home Screen (`home_screen.dart`)

**What it shows:**
- App bar: "Khidmat AI 🇵🇰"
- Bold tagline: "Apni Zaroorat Batayein"
- Full-width rounded text input, placeholder: `"Koi bhi service dhundein... (e.g. AC technician G-13)"`
- Small badge: `"✅ EN / UR / Roman UR supported"`
- Teal submit button: `"Dhundein →"` using `Color(0xFF0B7B6B)`

**On submit:** Navigate to Processing Screen, passing the raw input text as an argument.

**Current status:** ⬜ To be built (dummy navigation, no API yet)

---

## Screen 2 — Processing Screen (`processing_screen.dart`)

**What it shows:**
- Dark background (dark teal `#0A3D35` or near-black)
- Title: "Agent is working..."
- Animated pulsing ring or thinking indicator at top
- Vertical list of agent steps appearing one by one with 1-second delay
- Each step shows a teal checkmark ✅ once complete
- After all steps complete → auto-navigate to Results Screen

**Phase 1 — Hardcoded dummy steps (build this first):**
```dart
final List<String> steps = [
  "Understanding your request...",
  "Detecting language: Roman Urdu",
  "Parsed: AC Technician · G-13 · Tomorrow Morning",
  "Searching nearby providers...",
  "Found 3 providers. Ranking by distance + rating...",
  "Selected best provider. Preparing booking...",
];
```

**Phase 2 — Live steps from API (wire up after Ghulam's API is ready):**
Replace hardcoded list with `agent_steps[]` array from the Antigravity API response. Animate them with the same 1-second delay.

**Current status:** ⬜ To be built (Phase 1 first)

---

## Screen 3 — Results Screen (`results_screen.dart`)

**What it shows:**
- Title: "Top Providers Found"
- 3 provider cards (using `provider_card.dart` widget)
- Each card contains:
  - Provider name (bold)
  - Distance badge: `"📍 2.1 km"`
  - Star rating: `"⭐ 4.8"`
  - Teal "Book Now" button
- First card only: green `"BEST MATCH ✅"` chip top-right + reasoning text below name

**Phase 1 — Hardcoded dummy data (build this first):**
```dart
final providers = [
  {"name": "Ali AC Services", "distance": "2.1 km", "rating": "4.8", "best": true},
  {"name": "Khan Cooling Works", "distance": "3.4 km", "rating": "4.5", "best": false},
  {"name": "Quick Fix AC", "distance": "5.0 km", "rating": "4.1", "best": false},
];
```

**Phase 2 — Live data from API (wire up after Ghulam's API is ready):**
Replace with `top_providers[]` array from the final Antigravity JSON response.

**On "Book Now" tap:** Navigate to Booking Confirm Screen.

**Current status:** ⬜ To be built (Phase 1 first)

---

## Screen 4 — Booking Confirm Screen (`booking_confirm_screen.dart`)

**What it shows:**
- Soft light teal background wash
- Receipt-style white card in center
- Title: "Booking Confirmed 🎉"
- Fields displayed on the card:
  - Provider Name
  - Service Time
  - Distance
  - Rating
  - Reasoning (agent's explanation)
- Teal "Done" button at bottom

**Phase 1:** Show hardcoded data from the dummy provider  
**Phase 2:** Populate from the confirmed booking document in Firestore (StreamBuilder in `firebase_service.dart`)

**Current status:** ⬜ To be built

---

## Screen 5 — Booking Success Screen (`booking_success_screen.dart`)

**What it shows:**
- Large ✅ checkmark (animated if possible)
- Bold text: "You're all set!"
- Subtext: "Ali AC Services will arrive tomorrow at 10:00 AM. A reminder has been set for 9:00 AM."
- Outline button: "Book Another Service" → navigates back to Home Screen

**Push notification:** 10 seconds after this screen loads, fire a local push notification using `flutter_local_notifications`:
```
Title: "Reminder — Khidmat AI"
Body:  "Ali AC Services arrives tomorrow at 10:00 AM."
```

**Current status:** ⬜ To be built

---

## Reusable Widgets

### `provider_card.dart`
Props:
```dart
String name
String distance
String rating
bool isBestMatch
String? reasoning
VoidCallback onBookNow
```

### `agent_step_tile.dart`
Props:
```dart
String stepText
bool isComplete
```
Shows the step text with a teal checkmark when `isComplete = true`, or a subtle loading indicator when not yet complete.

---

## Services

### `api_service.dart`
**Phase 1:** Not used — all data is hardcoded.  
**Phase 2 (after Ghulam's API is ready):**
```dart
Future<Map<String, dynamic>> submitRequest(String userInput) async {
  final response = await http.post(
    Uri.parse("{ANTIGRAVITY_ENDPOINT}"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"input": userInput}),
  );
  return jsonDecode(response.body);
}
```

### `firebase_service.dart`
**Phase 1:** Not used.  
**Phase 2 (after Ghulam shares Firebase config):**
```dart
Stream<DocumentSnapshot> listenToBooking(String userId) {
  return FirebaseFirestore.instance
    .collection('active_bookings')
    .where('user_id', isEqualTo: userId)
    .snapshots()
    .map((snap) => snap.docs.first);
}
```

---

## Flutter Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: latest
  cloud_firestore: latest
  http: latest
  flutter_local_notifications: latest
```

Install command:
```bash
flutter pub add firebase_core cloud_firestore http flutter_local_notifications
```

---

## Firebase Setup (Haider's side — run after getting config from Ghulam)

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=hunarlink-496521
```

This auto-generates `firebase_options.dart` and wires it into the Flutter project.

---

## Current Build Status

| Screen | Phase 1 (Dummy) | Phase 2 (Live API) |
|---|---|---|
| Home Screen | ⬜ Not started | ⏳ Waiting on API endpoint |
| Processing Screen | ⬜ Not started | ⏳ Waiting on agent_steps from API |
| Results Screen | ⬜ Not started | ⏳ Waiting on top_providers from API |
| Booking Confirm | ⬜ Not started | ⏳ Waiting on Firebase config |
| Booking Success | ⬜ Not started | ⏳ Waiting on Firebase config |

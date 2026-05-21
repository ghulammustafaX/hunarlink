# 📱 HunarLink — Flutter Integration Guide
> **For Haider only** — Everything you need to connect the Flutter app to Ghulam's backend.

---

## ⚡ Quick Summary

| What | Value |
|------|-------|
| API Base URL | `http://GHULAM_IP:3000` |
| Health Check | `GET /health` |
| Main Endpoint | `POST /request` |
| Firebase Collection | `active_bookings` |
| Document ID | `userId` (e.g. `user_001`) |

---

## 🔥 Step 1: Firebase Setup

### Get `firebase_options.dart` from Ghulam
Ghulam runs this on his machine:
```bash
cd mobile
flutterfire configure --project=hunarlink-496521
```
This generates `mobile/lib/firebase_options.dart`.  
**Ghulam sends you this file directly.**

### Place it here:
```
mobile/lib/firebase_options.dart
```

### Update `main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HunarLinkApp());
}
```

---

## 📡 Step 2: API Endpoints

### Base URL
```
http://GHULAM_IP:3000
```
Replace `GHULAM_IP` with Ghulam's IPv4 address (he runs `ipconfig` to get it).  
Both phones must be on the **same WiFi network**.

---

### `GET /health`
Check if the server is running.

**Request:**
```
GET http://GHULAM_IP:3000/health
```

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

### `POST /request` ← Main endpoint
Sends user input, runs full pipeline, returns booking.

**Request:**
```
POST http://GHULAM_IP:3000/request
Content-Type: application/json
```

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
      "user_id": "user_001",
      "status": "confirmed",
      "provider_name": "Abbasi Electric & AC Repair Center",
      "service_category": "AC Technician",
      "service_time": "10:00 AM Tomorrow",
      "provider_distance": "1 km",
      "provider_rating": "4.9",
      "reasoning": "Selected as the closest available provider with a 4.9 rating.",
      "created_at": "2026-05-18T10:00:00.000Z",
      "reminder_at": "2026-05-19T10:00:00.000Z"
    },
    "reminder": {
      "booking_id": "BK-1779016287619",
      "trigger_at": "2026-05-19T10:00:00.000Z",
      "message": "Reminder: Abbasi Electric & AC Repair Center arrives in 1 hour.",
      "status": "reminder_scheduled"
    }
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Pipeline failed — check server terminal for details"
}
```

---

## 🛠️ Step 3: Update `antigravity_service.dart`

Replace the placeholder URL with Ghulam's real IP:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AntigravityService {
  // Replace with Ghulam's actual IP address
  static const String baseUrl = 'http://GHULAM_IP:3000';

  static Future<Map<String, dynamic>?> processRequest(String userInput, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'input': userInput,
          'userId': userId,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      print('API Error: ${response.statusCode} — ${response.body}');
      return null;
    } catch (e) {
      print('AntigravityService error: $e');
      return null;
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

---

## 🔥 Step 4: Firebase StreamBuilder

This is the most important part — Flutter must listen to Firestore and auto-update when Ghulam's agent writes a booking.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// In your BookingSuccessScreen or wherever you show confirmation:

StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
    .collection('active_bookings')
    .doc('user_001')           // use the actual userId
    .snapshots(),
  builder: (context, snapshot) {
    // Still waiting
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // Document exists — booking confirmed
    if (snapshot.hasData && snapshot.data!.exists) {
      final booking = snapshot.data!.data() as Map<String, dynamic>;
      return BookingConfirmedCard(booking: booking);
    }

    // No booking yet
    return const Center(child: Text('Waiting for booking...'));
  },
)
```

---

## 🗄️ Step 5: Firestore Schema

Collection: `active_bookings`  
Document ID: `userId` (e.g. `user_001`)

```
active_bookings/
└── user_001/
    ├── booking_id        → "BK-1779016287619"
    ├── user_id           → "user_001"
    ├── status            → "confirmed"
    ├── provider_name     → "Abbasi Electric & AC Repair Center"
    ├── service_category  → "AC Technician"
    ├── service_time      → "10:00 AM Tomorrow"
    ├── provider_distance → "1 km"
    ├── provider_rating   → "4.9"
    ├── reasoning         → "Selected as closest available..."
    ├── created_at        → "2026-05-18T10:00:00.000Z"
    └── reminder_at       → "2026-05-19T10:00:00.000Z"
```

---

## 📱 Step 6: Screen → API Mapping

| Screen | What it does | Data source |
|--------|-------------|-------------|
| `home_screen.dart` | User types request | User input only |
| `processing_screen.dart` | Shows agent steps | Hardcoded animation (API runs in background) |
| `results_screen.dart` | Shows ranked providers | `data.selected` from POST /request |
| `booking_confirm_screen.dart` | User confirms booking | `data.booking` from POST /request |
| `booking_success_screen.dart` | Shows confirmation | **Firebase StreamBuilder** on `active_bookings` |

---

## 🔄 Step 7: Full Flow in Code

Here's how to wire the complete flow in `home_screen.dart`:

```dart
void _submit() async {
  if (_controller.text.trim().isEmpty) return;

  // Navigate to processing screen immediately
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => ProcessingScreen(userInput: _controller.text.trim()),
  ));
}
```

In `processing_screen.dart` — call API while showing animation:

```dart
@override
void initState() {
  super.initState();
  _runStepsAndCallAPI();
}

Future<void> _runStepsAndCallAPI() async {
  // Start animation
  _startStepAnimation();

  // Call API in parallel
  final result = await AntigravityService.processRequest(
    widget.userInput,
    'user_001',
  );

  // Wait for animation to finish (min 5 seconds for demo effect)
  await Future.delayed(const Duration(seconds: 5));

  if (!mounted) return;

  if (result != null) {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => ResultsScreen(apiData: result),
    ));
  } else {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to find providers. Try again.')),
    );
    Navigator.pop(context);
  }
}
```

---

## ⚠️ Common Issues & Fixes

| Problem | Fix |
|---------|-----|
| `Connection refused` | Ghulam's server not running — tell him to start `node server.js` |
| `Network error` | Not on same WiFi — connect both phones to same network |
| `Timeout` | Server taking too long — check Ghulam's terminal for errors |
| `Firebase permission denied` | Firestore rules blocking — set to test mode in Firebase Console |
| `StreamBuilder not updating` | Check userId matches exactly — `user_001` on both sides |

---

## ✅ Integration Checklist

- [ ] Received `firebase_options.dart` from Ghulam
- [ ] Placed `firebase_options.dart` in `mobile/lib/`
- [ ] Updated `main.dart` with Firebase initialization
- [ ] Updated `baseUrl` in `antigravity_service.dart` with Ghulam's IP
- [ ] Tested `/health` endpoint — returns 200
- [ ] Tested `/request` endpoint — returns booking JSON
- [ ] `ResultsScreen` shows real provider data
- [ ] `BookingSuccessScreen` has StreamBuilder wired
- [ ] Firebase write detected — UI updates automatically
- [ ] Full flow tested end-to-end

---

## 📞 If Something Breaks

1. First check: is Ghulam's server running? (`node server.js`)
2. Test health: open `http://GHULAM_IP:3000/health` in browser
3. Check same WiFi network
4. Check Firestore rules are in test mode
5. Call Ghulam 😄

---

*HunarLink — Google Antigravity Hackathon, Challenge 2*  
*Ghulam Mustafa (Backend) & Haider (Flutter)*

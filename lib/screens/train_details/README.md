# Train Details Screen (Member 3)

## 1. Screen Purpose
The **Train Details Screen** (`TrainDetailsScreen`) displays in-depth schedule information, live delay status, telemetry diagnostics, and checkpoint progress for an individual train service. It bridges search/planning results (Member 2) with real-time GPS map tracking (Member 3) and delay alerting (Member 4).

---

## 2. Data Model & Fields Used
The screen receives and consumes a `TrainModel` instance (`lib/models/train_model.dart`).

| Field | Source / Usage | Fallback Handling |
| :--- | :--- | :--- |
| `trainNumber` | Train header badge (e.g. `#1005`) | Defaults to generic train label if empty |
| `name` | Express / train service title | Defaults to "Express Train" |
| `status` | Status badge styling (`on-time`, `delayed`, `stopped`, `cancelled`, `scheduled`) | Defaults to `scheduled` |
| `delayMinutes` | Delay badge tag calculation | Hidden when 0 or on-time |
| `scheduledDeparture` | Scheduled departure time info | Displays "N/A" if empty |
| `actualDeparture` | Recorded departure time info | Omitted if not available |
| `currentStation` | Current or last cleared station stop | Displays "Not Available" if empty |
| `nextStation` | Upcoming arrival station | Displays "Terminal / N/A" if omitted |
| `routeId` | Route identifier badge & metadata | Displays "N/A" if empty |
| `speedKmH` | Real-time speed telemetry chip | Displays "No active telemetry" if null |
| `latitude` / `longitude` | GPS coordinates readout in telemetry card | Handled gracefully if null |
| `lastUpdated` | Last telemetry update timestamp | Omitted if null |

---

## 3. Navigation & GoRouter Integration
* **Route Path:** `AppRoutes.trainDetails` (`/train-details`)
* **Parameter Passing:** The screen receives the selected `TrainModel` via GoRouter's `extra` parameter:
  ```dart
  // From Search Results or Journey Planner:
  context.push(AppRoutes.trainDetails, extra: train);
  ```
* **Deep-Link & Empty State Fallback:** If accessed directly without an `extra` payload (e.g., deep linking or testing), the screen gracefully displays an informative "No Train Selected" state with a button to return safely.
* **Outbound Navigation:**
  * **"Live Map Tracking"**: Navigates to `AppRoutes.liveTracking` (`/live-tracking`) forwarding the current `TrainModel` as `extra`.

---

## 4. Guest Authentication & Modal Trigger
* **Actions Impacted:**
  * **"Save Favorite"**
  * **"Enable Notification"**
* **Behavior:**
  * When a user taps either action, the screen checks `AuthService.instance.isAuthenticated`.
  * If the user is unauthenticated (guest), `AuthService.showContextualLogin(context, reason: ...)` is triggered to present a bottom-sheet login without discarding the user's current view.
  * If the user dismisses or cancels the login dialog, the action cleanly aborts without error.
  * If the user successfully signs in (or is already authenticated), the state toggles and provides immediate visual SnackBar confirmation.

---

## 5. Limitations & Stubs
* **Live Telemetry Streams:** Live telemetry rendering is currently bound to the static/initial `TrainModel` properties passed from search. Real-time Firebase Realtime Database stream attachment will be activated in `LiveTrackingProvider` during the Live Map tracking implementation.
* **Favorites & Notification Persistence:** Toggling favorites and notifications currently updates local UI state and displays feedback notifications. Remote persistence to Firestore (`users/{uid}/favorites`) and FCM topic subscriptions are stubbed with TODO annotations for Member 4 & integration phases.

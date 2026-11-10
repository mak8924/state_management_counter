# Advanced State Management Counter App

A Flutter application built with **Flutter and Dart** to demonstrate, compare, and implement modern reactive state management patterns. The project implements an interactive periodic timer counter across two distinct state management architectures: **GetX** and **Modern Riverpod 2.x**.

The application features a centralized navigation menu directing users to dedicated counter implementations, allowing for isolated state handling, periodic timer controls, and complete lifecycle teardown management.

> **Project scope:** This is an educational front-end application focused on state management architecture, reactive UI rendering, and explicit lifecycle memory leak prevention upon component disposal.

---

## Table of Contents

- [Features](#features)
- [Screens and User Flow](#screens-and-user-flow)
- [State Management Comparison](#state-management-comparison)
- [Architecture & Lifecycle Teardown](#architecture--lifecycle-teardown)
- [Project Structure](#project-structure)
- [Technologies](#technologies)
- [Getting Started](#getting-started)
- [Testing the Application](#testing-the-application)
- [Current Limitations](#current-limitations)
- [License](#license)

---

## Features

### Centralized Navigation Hub
- Serves as the landing menu for selecting the target state management strategy.
- Uses GetX navigation (`GetMaterialApp`) and Flutter route management to route to dedicated counter screens.
- Maintains complete state isolation between different architecture modules.

### GetX Counter Module
- Manages state using a dedicated `GetxController` subclass with reactive observables (`.obs`).
- Dynamically updates the user interface using the lightweight `Obx` widget without triggering full screen rebuilds.
- Features interactive periodic timer actions (**Start**, **Pause**, and **Reset**).
- Handles automatic teardown through `onClose()` to prevent memory leaks when navigating away.

### Modern Riverpod 2.x Counter Module
- Implements state management using `StateNotifier` bound to a `StateNotifierProvider`.
- Consumes application state within the UI via `ConsumerWidget` and `WidgetRef` (`ref.watch`).
- Enforces predictable state mutations through integer state notifications.
- Manages explicit timer resource cleanup within the notifier's `dispose()` lifecycle callback.

### Timer Control System
- **Start:** Initiates an active periodic timer (`Timer.periodic`) running at 1-second intervals.
- **Pause:** Halts the active timer while preserving the existing counter value.
- **Reset:** Cancels any active timer instance and restores the counter state to zero (`0`).

---

## Screens and User Flow

The application consists of three primary screens:

1. **Main Navigation Page** — The starting landing page containing navigation options.
2. **GetX Counter Page** — Dedicated counter screen consuming `GetXCounterController`.
3. **Riverpod Counter Page** — Dedicated counter screen consuming `CounterNotifier`.

### Main User Flow

```text
Main Navigation Screen
   ├── Navigate to GetX ───────> GetX Counter Screen (GetxController + Obx)
   └── Navigate to Riverpod ────> Riverpod Counter Screen (StateNotifier + ConsumerWidget)
```

---

## State Management Comparison

| Feature / Criteria | GetX Implementation | Modern Riverpod 2.x Implementation |
|---|---|---|
| **Base Controller Class** | `GetxController` | `StateNotifier<int>` |
| **State Observability** | Reactive primitives (`.obs`) | Immutable integer state (`state`) |
| **UI Consumer Widget** | `Obx` | `ConsumerWidget` with `WidgetRef` |
| **Provider / Injection** | `Get.put()` dependency injection | `ProviderScope` & `StateNotifierProvider` |
| **Lifecycle Teardown** | `onClose()` override | `dispose()` override |

---

## Architecture & Lifecycle Teardown

Asynchronous background timers require strict cleanup mechanisms to prevent CPU and memory overhead after a screen is removed from the navigation stack.

### GetX Teardown Execution
When navigating away from `GetXCounterScreen`, GetX disposes of the registered `GetXCounterController` instance, triggering `onClose()`. The internal periodic timer (`timer?.cancel()`) is canceled immediately.

### Riverpod Teardown Execution
When `RiverpodCounterScreen` is unmounted or its context disposed, Riverpod disposes of the associated `StateNotifier` instance. The overridden `dispose()` callback executes `_timer?.cancel()`, ensuring zero background activity.

---

## Project Structure

```text
state_management_counter/
├── lib/
│   └── main.dart          # Unified application entry point, routing, and all 3 screens
├── pubspec.yaml           # Project dependencies (get, flutter_riverpod)
└── README.md              # Detailed project documentation
```

---

## Technologies

- **Dart**
- **Flutter**
- **GetX (`get: ^4.6.6`)** for reactive state updates and route navigation.
- **Riverpod (`flutter_riverpod: ^2.5.1`)** for scoped, compile-safe state management.
- **Dart Async (`Timer`)** for periodic background counting.

---

## Getting Started

### Prerequisites

- Flutter SDK installed.
- Dart SDK (included with Flutter).
- Visual Studio Code or Android Studio.
- An active mobile emulator, simulator, or connected device.

### 1. Clone the Repository

```bash
git clone https://github.com/mak8924/state_management_counter
```

### 2. Navigate to Project Directory

```bash
cd state_management_counter
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the Application

```bash
flutter run
```

---

## Testing the Application

1. Launch the application to open the **Main Navigation Menu**.
2. Select **عداد باستخدام GetX**:
   - Press **تشغيل** (Start) to initiate counting.
   - Verify that the count increments every second.
   - Press **إيقاف** (Pause) to pause the counter at its current value.
   - Press **تصفير** (Reset) to reset the counter to zero.
   - Navigate back to the menu to trigger `onClose()` memory teardown.
3. Select **عداد باستخدام Riverpod**:
   - Verify identical interactive counter functionality powered by `StateNotifier`.
   - Confirm independent state isolation between both implementations.

---

## Current Limitations

- **Single File Structure:** All components are consolidated within `lib/main.dart` for simplified assignment delivery.
- **In-Memory State:** Counter states are stored in temporary application memory and reset when the app restarts.
- **Local Application Scope:** Designed for local state comparison without external network or API storage.

---

## License

This project was developed for academic and educational purposes.
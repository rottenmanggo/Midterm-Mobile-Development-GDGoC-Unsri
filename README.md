# noted! — Smart Pastel Bento Notes App

> A productivity notes & to-do app with a soft pastel bento grid UI, powered by Flutter + Firebase.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 Auth | Email/password register & login via Firebase Auth |
| 🔄 Auto-login | Session restored automatically on app launch |
| 📝 Notes CRUD | Create, read, update, delete notes in real-time |
| 🗂 Bento Grid | Staggered masonry grid with Normal / Wide / Tall card sizes |
| 📌 Pin Notes | Pin important notes to always appear first |
| 🎨 Pastel Colors | 5 card color families: Blue, Green, Amber, Mauve, Cream |
| ✅ Tasks | Full checklist with toggle, swipe-to-delete, and pending/done sections |
| 👤 Profile | User info display + sign out |
| 🌑 Dark Mode | Hue-preserving dark theme (30% darkened cards) |
| ✨ Animations | Entry animations, press scale, card color transitions |
| 💀 Shimmer | Shimmer skeleton loading while data fetches |

---

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK (stable channel)
- Firebase project
- FlutterFire CLI

### Step 1 — Clone & Install
```bash
# Navigate to project directory
cd d:/Profile/Study/coding/mobdev_project

# Install dependencies
flutter pub get
```

### Step 2 — Firebase Setup
```bash
# Install FlutterFire CLI (if not already installed)
dart pub global activate flutterfire_cli

# Configure Firebase (creates lib/firebase_options.dart automatically)
flutterfire configure
```

> ⚠️ **IMPORTANT**: After running `flutterfire configure`, delete the placeholder `lib/firebase_options.dart` (already in the project) — FlutterFire will regenerate it with your real credentials.

### Step 3 — Enable Firebase Services
In the [Firebase Console](https://console.firebase.google.com):
1. **Authentication** → Sign-in method → Enable **Email/Password**
2. **Firestore Database** → Create database (start in production mode)

### Step 4 — Firestore Security Rules
In Firebase Console → Firestore → Rules, paste:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      allow read, update, delete: if request.auth != null
        && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    match /tasks/{taskId} {
      allow read, update, delete: if request.auth != null
        && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

### Step 5 — Run the App
```bash
flutter run
```

---

## 📁 Folder Structure

```
lib/
├── main.dart                        # Entry point, Firebase init, MultiProvider
├── app.dart                         # MaterialApp, theme, routes, AuthGate
├── firebase_options.dart            # ⚠️ Replace with flutterfire configure output
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # Pastel palette + color key helpers
│   │   └── app_routes.dart          # Named route constants
│   ├── theme/
│   │   └── app_theme.dart           # Light & dark ThemeData (Inter font)
│   └── widgets/
│       ├── loading_indicator.dart   # Shimmer bento skeleton
│       └── error_widget.dart        # Reusable error display
├── data/
│   ├── models/
│   │   ├── note_model.dart          # Firestore note model (Timestamp)
│   │   ├── task_model.dart          # Firestore task model
│   │   └── user_model.dart          # Firebase User wrapper
│   ├── datasources/
│   │   ├── firebase_auth_datasource.dart
│   │   └── firestore_datasource.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── note_repository.dart
│       └── task_repository.dart
├── domain/
│   ├── entities/
│   │   ├── note.dart                # Pure Dart Note entity
│   │   └── task.dart                # Pure Dart Task entity
│   └── usecases/
│       ├── create_note_usecase.dart
│       ├── get_notes_usecase.dart
│       └── delete_note_usecase.dart
└── presentation/
    ├── auth/
    │   ├── auth_provider.dart
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── notes/
    │   ├── notes_provider.dart
    │   ├── home_screen.dart
    │   ├── add_note_screen.dart
    │   ├── note_detail_screen.dart
    │   └── widgets/
    │       ├── bento_card.dart
    │       └── bento_grid.dart
    ├── tasks/
    │   ├── tasks_provider.dart
    │   └── tasks_screen.dart
    └── profile/
        └── profile_screen.dart
```

---

## 🎨 Color Palette

| Color | Background | Text | FAB |
|-------|-----------|------|-----|
| Blue  | `#C8D8E8` | `#2A4A60` | `#A8C0D4` |
| Green | `#D4E8C2` | `#2A4A20` | `#B8D4A0` |
| Amber | `#E8D8C0` | `#5A3A10` | `#D4C0A0` |
| Mauve | `#E0C8D8` | `#5A2040` | `#CCACC0` |
| Cream | `#E8E0C0` | `#5A4010` | `#D4CC9C` |

---

## 📸 Screenshot

_Coming soon — run the app and take a screenshot!_

---

## 🧰 Tech Stack

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^3.6.0 | Firebase initialization |
| `firebase_auth` | ^5.3.1 | Authentication |
| `cloud_firestore` | ^5.4.4 | Real-time database |
| `provider` | ^6.1.2 | State management |
| `flutter_staggered_grid_view` | ^0.7.0 | Bento masonry grid |
| `shimmer` | ^3.0.0 | Loading skeleton |
| `google_fonts` | ^6.2.1 | Inter font |
| `uuid` | ^4.5.1 | Unique IDs |
| `intl` | ^0.19.0 | Date formatting |
| `shared_preferences` | ^2.3.2 | Local persistence |

---

## 📄 License

MIT © 2024 noted!

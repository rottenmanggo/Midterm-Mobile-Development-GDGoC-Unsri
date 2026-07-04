# noted! 📝

a minimalist notes and to-do app build with Flutter and Firebase
---

## ✨ Features

- **Bento Grid Style** — Notes are displayed in a Pinterest-style, variable-sized card grid (normal, wide, tall) for a visually engaging overview.
- **Drag & Drop Reordering** — Long-press and drag any note to rearrange your grid; the order is saved automatically.
- **Pinned Notes** — Pin important notes to keep them at the top of the grid.
- **Task Management** — A dedicated Tasks tab for simple to-do tracking, separate from notes.
- **Categories & Custom Colors** — Organize notes by category (Study, Personal, Work, Idea) and assign custom card colors and sizes.
- **Authentication** — Email/password sign-in and account creation powered by Firebase Auth.
- **Real-Time Sync** — All notes and tasks sync instantly across sessions via Cloud Firestore.
- **Profile** — View account details and app info at a glance.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Backend | Firebase (Authentication + Cloud Firestore) |
| Architecture | Clean layered structure — `data` / `domain` / `presentation` |
| Fonts | Google Fonts (Caveat for display titles) |

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/       # App colors, routes
│   └── widgets/         # Shared widgets (loading, error states)
├── data/
│   ├── datasources/     # FirestoreDatasource — raw Firestore calls
│   ├── models/          # NoteModel, TaskModel
│   └── repositories/    # NoteRepository, TaskRepository
├── domain/
│   └── usecases/        # CreateNoteUsecase, GetNotesUsecase, etc.
├── presentation/
│   ├── auth/            # Sign in / Sign up
│   ├── notes/           # Notes tab, bento grid, add/edit/detail screens
│   ├── tasks/           # Tasks tab
│   ├── profile/         # Profile screen
│   └── home/             # Root navigation shell
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.38 or later)
- Android Studio with an emulator, or a physical Android device
- A Firebase project with **Authentication** (Email/Password) and **Cloud Firestore** enabled
- [Firebase CLI](https://firebase.google.com/docs/cli) installed globally

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mobdev_project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Connect Firebase**
   ```bash
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` and registers the app in `firebase.json`.

4. **Deploy Firestore indexes and rules**
   ```bash
   firebase deploy --only firestore:indexes
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔥 Firestore Data Model

### `notes` collection
| Field | Type | Description |
|---|---|---|
| `title` | string | Note title |
| `content` | string | Note body |
| `category` | string | `study` \| `personal` \| `work` \| `idea` |
| `cardColor` | string | `blue` \| `green` \| `amber` \| `mauve` \| `cream` |
| `cardType` | string | `normal` \| `wide` \| `tall` |
| `isPinned` | bool | Whether the note is pinned to the top |
| `order` | int | Custom sort position (drag-and-drop) |
| `createdAt` | timestamp | Creation time |
| `userId` | string | Owner's UID |

### `tasks` collection
| Field | Type | Description |
|---|---|---|
| `title` | string | Task name |
| `isCompleted` | bool | Completion status |
| `createdAt` | timestamp | Creation time |
| `userId` | string | Owner's UID |

**Required composite indexes** (see `firestore.indexes.json`):
- `notes`: `userId` ASC, `isPinned` DESC, `order` ASC
- `tasks`: `userId` ASC, `createdAt` DESC

---

## 🎨 Design

**Theme:** Bento Style
**Primary palette:** `#F1E2A7` (light yellow) · `#E4A038` (accent yellow)
**Card palette:** Blue, Green, Amber, Mauve, Cream

---

## 📌 Roadmap

- [ ] Search and filter notes by category
- [ ] Rich text formatting in notes
- [ ] Reminders/notifications for tasks
- [ ] Dark mode
- [ ] iOS support

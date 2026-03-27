# 📅 Your Days
> **Turn your daily routine into a visual journey.** 🚀

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org)

**Your Days** is a sophisticated Flutter application designed to help users track their daily moods and preserve their most cherished moments (Highlights). It uses a robust local-first approach with seamless cloud synchronization.

---

## ✨ Key Features

* **🎭 Mood Tracking:** Select and log your daily emotional state with ease.
* **📸 Visual Highlights:** Attach multiple images and captions to every daily entry.
* **💾 Offline-First:** Fully functional without internet using a highly optimized **SQLite** core.
* **🔄 Intelligent Sync:** Automatic background synchronization with **Firebase Cloud Firestore**.
* **🛡️ Data Integrity:** Advanced SQL logic using `ConflictAlgorithm.replace` and Composite Primary Keys to prevent duplicate entries.

---

## 🏗️ Technical Architecture
The project follows a **Feature-Driven Clean Architecture**. This ensures that the codebase remains maintainable, testable, and scalable as new features are added.



### Structure Breakdown:
* **Core:** Contains global services like Database initialization, Firebase configurations, Theme, and shared Utilities.
* **Features:** Each functional module (e.g., `days`, `auth`, `profile`) is self-contained with its own:
    * **Data:** Models and Local/Remote Data Providers.
    * **Logic:** State Management using **Cubit (Bloc)**.
    * **UI:** Feature-specific Screens and Widgets.

---

## 📸 App Preview
*(Add your actual screenshots here to showcase the UI!)*

| Daily List | Add Highlight | Profile View |
| :---: | :---: | :---: |
| ![List](https://via.placeholder.com/200x400) | ![Add](https://via.placeholder.com/200x400) | ![Profile](https://via.placeholder.com/200x400) |

---

## 🛠️ Tech Stack & Dependencies

* **State Management:** `flutter_bloc` (Cubit) - Separation of Business Logic from UI.
* **Local Database:** `sqflite` - Reliable local relational storage.
* **Notifications:** `awesome_notifications` - Local scheduling and alerts.
* **Backend:** `firebase_core`, `firebase_auth`, `cloud_firestore`.
* **UI Enhancements:** `font_awesome_flutter`, `google_fonts`.

---

## 📧 Contact
**Saif Eldien** - [GitHub Profile](https://github.com/SaifEldien)

---
*Created with ❤️ by Saif Eldien - 2026*

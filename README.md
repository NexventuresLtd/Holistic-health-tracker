# **Holistic Health Tracker – Family Wellness Companion**

A Flutter-based mobile app built by the **Nexventures Tech Team** to simplify and enhance family healthcare coordination. From medication reminders to emergency alerts, the app helps users track wellness in real-time using Firebase, FastAPI, and thoughtful UI/UX.

---

## **Features**

* Role-based family access: caregivers, patients, children
* Smart medication scheduler with push notifications
* Emergency SOS with real-time location tracking
* Health history: digital records, appointments, vitals
* Android, iOS, and web-ready with modern UI (BLoC pattern)

---

## **Tech Stack**

| Category   | Technology                     |
| ---------- | ------------------------------ |
| Frontend   | Flutter (Dart)                 |
| Backend    | Firebase + FastAPI             |
| State Mgmt | BLoC + Cubit                   |
| APIs       | Google Maps, Calendar          |
| Auth & DB  | Firebase Auth & Firestore      |
| Testing    | Unit, Widget, Integration      |
| Tools      | Figma, VS Code, Android Studio |

---

## **Setup Instructions**

### 1. Clone the Repo

```bash
git clone https://github.com/NexventuresLtd/Holistic-health-tracker.git
cd Holistic-health-tracker/client
flutter pub get
```

### 2. Firebase Setup

* Add `google-services.json` to `/android/app/`
* Add `GoogleService-Info.plist` to `/ios/Runner/`
* Enable **Firestore**, **Auth**, **Storage** in Firebase Console

### 3. Run the App

```bash
flutter run        # Android or emulator
flutter run -d chrome  # Web build
```

---

## **Project Structure**

```
client/
├── lib/
│   ├── models/
│   ├── providers/
│   ├── screens/
│   ├── services/
│   ├── utils/
│   └── widgets/
├── assets/
├── android/
├── ios/
└── test/
```

---

## **Testing**

```bash
flutter test test/unit/
flutter test test/widget/
flutter test test/integration/
```

---

## **Screenshots**

| Dashboard                                                                                     | Medication Tracker                                                                             | SOS Button                                                                              |
| --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| ![Dashboard](https://github.com/user-attachments/assets/15df9537-217e-4b47-88d1-d3650eb07865)
| ![Medication](https://github.com/user-attachments/assets/a5ed8545-b317-410c-9c7b-45bfad3cf012)
 | ![SOS](https://github.com/user-attachments/assets/6e62c7ab-1b99-42d0-81f2-fbe9aeb81304)
 |

---

## **Nexventures Tech Team**

| Name                       | Role                  |
| -------------------------- | --------------------- |
| **Alain Muhirwa Michael**  | Flutter Dev / Backend |
| **Loue Sauveur Christian** | UI/UX & Flutter Dev   |
| **Daniel Iryivuze**        | Firebase & Docs Lead  |

[info@nexventures.net](mailto:info@nexventures.net)
[Live GitHub Repo](https://github.com/NexventuresLtd/Holistic-health-tracker)
[Official Website](https://www.nexventures.net)

---

## **Resources**

* [Flutter Docs](https://flutter.dev/docs)
* [Firebase Docs](https://firebase.google.com/docs)
* [FastAPI Docs](https://fastapi.tiangolo.com)
* [Bloc Pattern](https://bloclibrary.dev/#/)

---

## Feedback

> *"This tracker brought peace of mind to our caregiving routine."*
> — **Family Member in Kigali**

---
**Nexventures Ltd – Building Purpose-Driven Tech**
---

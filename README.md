# ![Nexventures Logo](https://github.com/user-attachments/assets/6d96fe51-d566-4fb7-acb1-cacc764af8a4)


# **Holistic Health Tracker – Family Wellness Companion**

A Flutter-based mobile app by the **Nexventures Tech Team**, designed to simplify and enhance family healthcare coordination. From medication reminders to emergency alerts, this intuitive solution helps users monitor wellness in real-time using **Firebase**, **FastAPI**, and thoughtful **UI/UX**.

**Graphics and App Design** by the Nexventures Tech Team

---

## **Features**

- Role-based family access: caregivers, patients, children  
- Smart medication scheduler with push notifications  
- Emergency SOS with real-time location tracking  
- Health history: digital records, appointments, vitals  
- Android, iOS, and web-ready with modern UI (BLoC pattern)

---

## **Tech Stack**

| Category     | Technology                     |
| ------------ | ------------------------------ |
| Frontend     | Flutter (Dart)                 |
| Backend      | Firebase + FastAPI             |
| State Mgmt   | BLoC + Cubit                   |
| APIs         | Google Maps, Calendar          |
| Auth & DB    | Firebase Auth & Firestore      |
| Testing      | Unit, Widget, Integration      |
| Design Tools | Figma, VS Code, Android Studio |

---

## **Setup Instructions**

### 1. Clone the Repository

```bash
git clone https://github.com/NexventuresLtd/Holistic-health-tracker.git
cd Holistic-health-tracker/client
flutter pub get
````

### 2. Firebase Setup

* Add `google-services.json` to `/android/app/`
* Add `GoogleService-Info.plist` to `/ios/Runner/`
* Enable **Firestore**, **Auth**, and **Storage** in Firebase Console

### 3. Run the App

```bash
flutter run           # Android or emulator
flutter run -d chrome # Web build
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
| ![Dashboard](https://github.com/user-attachments/assets/15df9537-217e-4b47-88d1-d3650eb07865) | ![Medication](https://github.com/user-attachments/assets/a5ed8545-b317-410c-9c7b-45bfad3cf012) | ![SOS](https://github.com/user-attachments/assets/6e62c7ab-1b99-42d0-81f2-fbe9aeb81304) |

---

## **Nexventures Tech Team**

| Name                       | Role                  |
| -------------------------- | --------------------- |
| **Alain Muhirwa Michael**  | Flutter Dev / Backend |
| **Loue Sauveur Christian** | UI/UX & Flutter Dev   |
| **Daniel Iryivuze**        | Firebase & Docs Lead  |

Email: [info@nexventures.net](mailto:info@nexventures.net)
GitHub: [Live GitHub Repo](https://github.com/NexventuresLtd/Holistic-health-tracker)
Website: [https://www.nexventures.net](https://www.nexventures.net)

---

## **Resources**

* [Flutter Documentation](https://flutter.dev/docs)
* [Firebase Documentation](https://firebase.google.com/docs)
* [FastAPI Documentation](https://fastapi.tiangolo.com)
* [BLoC Pattern Guide](https://bloclibrary.dev/#/)

---

## **Feedback**

> "This tracker brought peace of mind to our caregiving routine."
> — **Family Member in Kigali**

---

**Nexventures Ltd – Building Purpose-Driven Tech**

---

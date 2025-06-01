# 🏙️ Civic SPhere - A Community Civic Issue Tracker

A modern, real-time mobile app built with **Flutter** and **Firebase** to empower local communities to **report**, **track**, and **discuss** civic issues — all from their phones.

---

## 📱 About the Project

The app enables users to:
- Report civic problems (e.g., potholes, broken street lights)
- Track issue status in real time
- Engage in meaningful community discussion via threaded replies
- View and manage their own reports
- Empower admins with moderation tools

Built with a strong focus on **accessibility**, **intuitive design**, and **community engagement**, this project brings transparency and accountability to neighbourhood problems.

---

## 🌟 Features

- 🔒 **Authentication** with Firebase Auth
- 📝 **Real-time issue reporting** with timestamps
- 📊 **Status tracking**: Open / In Progress / Resolved (colour coded)
- 💬 **Threaded replies** on posts
- 🧹 **Smart deletion**: deleting a post auto-deletes its replies
- 🙋‍♂️ **Filter for 'My Posts'**
- 🛡️ **Admin Panel** (for users with `admin@gmail.com`)
- 🎨 **Clean dark theme** with responsive UI and Cupertino design
- ⚡ **Animated page transitions** and splash screen

---

## 🧪 Evaluation Criteria

### 🔬 Innovation
- Smart cascade deletion of replies with posts
- Seamless toggle to view only your contributions
- Admin-only access implemented via email check
- Real-time updates without refresh

### ⚙️ Feasibility of Implementation
- Built entirely in Flutter with Firebase (no backend server required)
- Works on Android & iOS
- Lightweight, real-time data sync via Firestore
- Cloud-based and scalable

### 🔧 Functionality
- Users can post issues quickly
- Replies allow discussion within the app
- Toggle for filtering personal posts
- Admin tools for content moderation

### 🎨 Design
- Minimalist black-and-white theme
- Cupertino-styled icons and navigation
- Smooth animated transitions between pages
- Accessible and mobile-friendly interface

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed
- Firebase project with Firestore and Authentication enabled
- Android Studio or Visual Studio Code

### Run Locally

```bash
git clone https://github.com/your-username/community-civic-issue-tracker.git
cd community-civic-issue-tracker
flutter pub get
flutter run
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)
2. Enable Firestore and Authentication (Email/Password)
3. Add `google-services.json` to `android/app/`
4. Add `GoogleService-Info.plist` to `ios/Runner/`
5. Create Firestore indexes for nested replies when prompted

---

## 📁 Folder Structure

```bash
lib/
│
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── splash_wrapper.dart
│   ├── report_issue.dart
│   ├── track_issue.dart
│   └── admin.dart
│
├── widgets/
│   └── community_feed.dart
│
└── main.dart
```

---

## 🛠️ Tech Stack

- **Flutter** – for frontend
- **Dart** – core language
- **Firebase Auth** – user authentication
- **Cloud Firestore** – real-time database
- **Cupertino & Material** – UI components

---

## 📷 Screenshots

<div align="center">
  <img src="https://github.com/user-attachments/assets/a13913f9-e438-4b0d-91cd-a22cf7d467e0" width="200"/>
  <img src="https://github.com/user-attachments/assets/5331cd63-ae4f-4172-b414-c52ef7a707dc" width="200"/>
  <img src="https://github.com/user-attachments/assets/1748ea0f-2b8d-4a26-b3b9-d96a2f0c7e22" width="200"/>
  <br/>
  <img src="https://github.com/user-attachments/assets/2dfded9d-f5b7-48d2-88a4-a1949c5980f6" width="200"/>
  <img src="https://github.com/user-attachments/assets/7fa5659c-2893-44cc-a6e8-fb79aee62bb9" width="200"/>
  <img src="https://github.com/user-attachments/assets/087204d5-3ced-486c-93b2-e6640ed82fee" width="200"/>
  <br/>
  <img src="https://github.com/user-attachments/assets/07f4b48d-44b9-4ae9-a445-649473becbdb" width="200"/>
  <img src="https://github.com/user-attachments/assets/97e1a383-5c0d-4f4e-a65e-d55061dd865b" width="200"/>
  <img src="https://github.com/user-attachments/assets/98dd476e-fcf2-481f-ad00-854665aeca7d" width="200"/>
  <br/>
  <img src="https://github.com/user-attachments/assets/efd9eb9c-07e0-4c8b-94b2-8c4648615271" width="200"/>
</div>


---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.



## ✨ Made with love and coffee by Siddharth Rajpal for HacktheBronx Hackathon

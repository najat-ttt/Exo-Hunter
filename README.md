# Exo-Hunter 🚀

**Hunting Exoplanets with AI** - A Flutter application for discovering worlds beyond our solar system.

*Developed for NASA Space Apps Challenge*

## 🌟 Features

### 🔐 Authentication System
- **Scientist Registration & Verification**: Scientists can register and await admin approval
- **Admin Dashboard**: Comprehensive verification system for managing scientist accounts
- **Role-based Access Control**: Different access levels for scientists, admins, and students
- **Password Reset**: Secure password recovery for all user types

### 🔬 Scientist Portal
- Verified scientists get access to advanced research tools
- Dashboard for exoplanet research and data analysis
- Collaboration features with other scientists

### 👨‍💼 Admin Features
- Review and approve/deny scientist verification requests
- Manage user accounts and permissions
- Monitor platform activity

### 🎓 Student Explorer
- Educational content about exoplanets
- Interactive learning modules
- Simplified interface for younger users

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Authentication (Firebase Auth)
  - Database (Cloud Firestore)
  - Hosting
- **Fonts**: Google Fonts (Orbitron, Inter)
- **UI**: Custom cosmic-themed design with animations

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.1.0 or higher)
- Dart SDK
- Firebase CLI
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/exo-hunter.git
   cd exo-hunter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication and Firestore
   - Download and replace the configuration files:
     - `android/app/google-services.json`
     - Update `lib/firebase_options.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Supported Platforms

- ✅ Web
- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase configuration
├── screens/                           # UI screens
│   ├── welcome_page.dart              # Landing page
│   ├── login_page.dart                # Login functionality
│   ├── scientist_signup_page.dart     # Scientist registration
│   ├── scientist_dashboard_page.dart  # Scientist main dashboard
│   ├── admin_verification_page.dart   # Admin approval system
│   └── ...
├── theme/
│   └── app_theme.dart                 # App-wide theming
└── widgets/
    ├── cosmic_background.dart         # Animated background
    └── glowing_button.dart            # Custom button component
```

## 🎨 Design Philosophy

Exo-Hunter features a **cosmic-themed design** that reflects the mystery and beauty of space exploration:

- **Dark cosmic background** with animated stars
- **Glowing UI elements** that pulse like distant galaxies
- **Space-inspired color palette**: Midnight Blue, Nebula Cyan, Cosmic Purple, Supernova Orange
- **Typography**: Orbitron for headlines (futuristic feel) and Inter for body text (readability)

## 🔐 User Roles

### 👩‍🔬 Scientist
- Register with academic credentials
- Await admin verification
- Access research tools upon approval
- Collaborate with other verified scientists

### 👨‍💼 Admin
- Review scientist applications
- Approve/deny verification requests
- Manage platform users
- Access verification dashboard

### 🎓 Student
- Educational access to exoplanet content
- No verification required
- Age-appropriate interface

## 🌌 Firebase Collections

```
scientists/          # Scientist user profiles and verification status
├── {userId}
│   ├── name: string
│   ├── email: string
│   ├── institution: string
│   ├── researchField: string
│   ├── credentials: string
│   ├── verified: boolean
│   ├── verificationStatus: string
│   └── createdAt: timestamp

admins/              # Admin user accounts
notifications/       # System notifications
users/              # General user data
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is part of the NASA Space Apps Challenge and is open source.

## 🙏 Acknowledgments

- **NASA Space Apps Challenge** for the inspiration
- **Firebase** for the backend infrastructure
- **Flutter team** for the amazing framework
- **Google Fonts** for typography
- **Unsplash** for cosmic background imagery

## 🔗 Links

- [NASA Space Apps Challenge](https://www.spaceappschallenge.org/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)

---

*"The cosmos is not only stranger than we imagine, it is stranger than we can imagine."* - J.B.S. Haldane

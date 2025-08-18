# Blookia Clinic Assistant

An offline-first mobile clinic assistant prototype that showcases core clinical workflows using mock data and on-device storage.

## Overview

This Flutter application demonstrates a comprehensive clinic management system designed for aesthetic/medical clinics. It features modern UI/UX design, offline-first architecture, and covers the complete patient journey from scheduling to payment.

## Features

### Core Functionality
- **Multi-tenant & Role-based Access**: Switch between different clinics and user roles (Admin/Professional/Reception)
- **Offline-First Architecture**: Work without internet connection with automatic sync when back online
- **Multilingual Support**: Available in English, Portuguese, and Spanish
- **Modern Animated UI**: Trendy design with animated backgrounds and smooth transitions

### Key Features to be Implemented
1. **Smart Scheduling & Waitlist Management**
   - Appointment status tracking (Confirmed/Waitlist/No-Show)
   - Waitlist-based slot recovery with countdown timers
   - Auto-message templates in multiple languages

2. **Patient Management**
   - Comprehensive patient profiles
   - Private clinical notes (not included in exports)
   - Pre-appointment mini-dossiers with recent procedures and flags
   - Loyalty points system

3. **In-Consultation Mode**
   - Do-Not-Disturb mode with timer
   - Interactive pain mapping (SVG-based body/face diagrams)
   - Private clinical notes storage

4. **Consent & Recording Workflows**
   - Digital consent capture
   - Audio recording with transcription
   - Version-controlled transcript editing
   - PDF export capabilities

5. **Payment Integration**
   - QR code and payment link generation
   - Payment status tracking
   - Automatic appointment confirmation upon payment

6. **Omnichannel AI Assistant**
   - Intent detection (booking/cancellation/pricing/etc.)
   - Sentiment analysis (happy/angry/urgent)
   - Smart handoff to human operators

7. **Teleconsult Gateway**
   - Pre-consultation document uploads
   - Payment verification before room entry
   - Integrated video room access

8. **3D Viewer Foundation**
   - GLB model loading
   - Interactive marker placement
   - Future expansion ready for scanning/measurements

9. **Compliance & Security**
   - HIPAA/GDPR/LGPD compliance badges
   - Audit log tracking
   - MFA and session timeout controls

## Technical Architecture

### Tech Stack
- **Frontend**: Flutter/Dart with Material Design 3
- **State Management**: Provider pattern
- **Local Storage**: Hive for offline-first data persistence
- **UI Components**: Custom animated widgets, charts, and interactive elements
- **Audio**: Recording and playback capabilities
- **PDF Generation**: Custom document generation
- **QR Codes**: Generation and scanning
- **3D Rendering**: GLB model viewer

### Data Models
- `Tenant`: Clinic information and settings
- `User`: Staff members with role-based permissions
- `Patient`: Complete patient profiles with medical history
- `Appointment`: Scheduling with status tracking and metadata
- `MessageTemplate`: Multilingual communication templates
- `Payment`: Financial transaction tracking
- `Transcript`: Audio transcription with versioning
- `WaitlistInvite`: Slot recovery system
- `ChatMessage`: AI assistant conversations
- `Marker3D`: Spatial annotations on 3D models

### Offline Architecture
- All data stored locally using Hive
- Operation queue for offline actions
- Automatic synchronization when connectivity returns
- Visual indicators for offline status

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd blookia_clinic
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters** (if needed)
   ```bash
   dart run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### First Time Setup
1. The app will automatically seed demo data on first launch
2. Select your role (Professional/Reception/Admin)
3. Choose a clinic from the available tenants
4. Explore the dashboard and various features

## Demo Walkthrough (6-8 Minutes)

### Recommended Demo Script
1. **Authentication & Setup**
   - Role/Tenant selection
   - Toggle offline mode demonstration

2. **Dashboard Overview**
   - KPI metrics display
   - Quick actions and recent activity

3. **Scheduling & Waitlist**
   - View appointments with status indicators
   - Demonstrate slot recovery countdown
   - Auto-message preview

4. **Patient Management**
   - Patient profile with private notes
   - Pre-visit mini-dossier trigger

5. **Consultation Mode**
   - DND activation and timer
   - Interactive pain mapping
   - Private note taking

6. **Consent & Recording**
   - Digital consent capture
   - Mock recording and transcription
   - PDF export demonstration

7. **Payment Flow**
   - QR code generation
   - Payment status updates
   - Appointment confirmation

8. **AI Assistant**
   - Intent/sentiment detection
   - Escalation to human handoff

9. **Compliance Features**
   - Security badges
   - Audit log demonstration
   - Settings overview

## Development Status

### ✅ Completed
- Project structure and dependencies
- Data models and local storage setup
- Authentication and role selection
- Dashboard with animated UI and KPI cards
- Offline-first architecture foundation
- Modern UI theme and animated backgrounds

### 🚧 In Progress
- Documentation and README
- Core feature implementations

### 📋 Planned
- Patient management screens
- Schedule management with auto-messaging
- Waitlist slot recovery system
- Consultation mode with pain mapping
- Consent and recording workflows
- Payment system with QR generation
- Omnichannel AI assistant
- Teleconsult gating system
- 3D viewer with marker system
- Settings screen with compliance badges
- Comprehensive testing suite

## Design Philosophy

### User Experience
- **Intuitive Navigation**: Bottom tab navigation with clear icons
- **Progressive Disclosure**: Information revealed as needed
- **Accessibility First**: Large tap targets, clear contrast, screen reader support
- **Responsive Design**: Adapts to different screen sizes and orientations

### Data Privacy
- **Field-level Privacy**: Private notes never included in exports
- **Audit Trails**: All actions logged with timestamps
- **Consent Tracking**: Digital consent capture with version control
- **Secure Storage**: All data encrypted at rest

### Performance
- **Offline First**: Full functionality without network
- **Optimistic Updates**: Immediate UI feedback
- **Background Sync**: Seamless data synchronization
- **Efficient Rendering**: Smooth animations and transitions

## Contributing

This is a prototype application designed to demonstrate clinic management workflows. The codebase serves as a foundation for future development and can be extended with real backend integration, additional features, and production-ready security measures.

### Code Structure
```
lib/
├── models/          # Data models with Hive annotations
├── providers/       # State management with Provider
├── screens/         # UI screens organized by feature
├── widgets/         # Reusable UI components
├── services/        # Business logic and data services
└── utils/           # Utilities and theme definitions
```

## License

This project is a prototype for demonstration purposes. Please ensure compliance with healthcare regulations (HIPAA, GDPR, LGPD) when adapting for production use.

---

**Note**: This is a prototype application using mock data only. No real patient information is stored or transmitted. All compliance badges and security features are for demonstration purposes and would require proper implementation for production use.
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and Code Generation
- `flutter pub get` - Install dependencies
- `dart run build_runner build` - Generate Hive type adapters (*.g.dart files)
- `build_runner.bat` - Windows batch script to generate Hive adapters

### Development 
- `flutter run` - Run the application
- `flutter test` - Run unit and widget tests
- `flutter analyze` - Run static analysis with custom lint rules
- `flutter clean` - Clean build artifacts

### Testing
- `flutter test test/widget_test.dart` - Run specific test file
- Tests include widget tests for UI components and unit tests for business logic

## Architecture

### Offline-First Design
- **Local Storage**: Uses Hive for all data persistence (patients, appointments, users, tenants)
- **Sync Queue**: Operations are queued when offline and synced when connectivity returns
- **Mock Data**: Uses SeedService to populate demo data on first launch
- **Boxes**: patients, appointments, users, tenants, settings, offline_queue

### State Management
- **Provider Pattern**: All state managed through ChangeNotifier providers
- **Key Providers**: AppProvider, AuthProvider, PatientProvider, AppointmentProvider, SettingsProvider
- **Services**: SyncService, LocalizationService, AccessibilityService

### Data Models (Hive TypeAdapters)
- All models use Hive annotations with generated adapters (*.g.dart)
- **Core Models**: Tenant, User (with UserRole enum), Patient, Appointment
- **Supporting Models**: MessageTemplate, Payment, Transcript, WaitlistInvite, ChatMessage, Marker3D
- Models include toJson/fromJson for API compatibility

### Multi-tenancy
- Role-based access: Admin, Professional, Reception (UserRole enum)
- Tenant switching capability with separate data isolation
- Multi-language support (EN, PT, ES) with locale-based message templates

### Key Features Architecture
- **Pain Mapping**: SVG-based interactive body diagrams with coordinate tracking
- **AI Assistant**: Context-aware chat with intent detection and sentiment analysis
- **Consultation Mode**: Do-Not-Disturb timer with private clinical notes
- **Waitlist Recovery**: Automatic slot competition with countdown timers
- **Digital Consent**: Audio recording with transcript versioning
- **Payment Integration**: QR code generation and status tracking
- **3D Viewer**: GLB model loading with interactive marker placement

### Screens Organization
```
screens/
├── auth/ - Role and tenant selection
├── dashboard/ - Main KPI dashboard
├── patients/ - Patient management and details
├── schedule/ - Calendar, waitlist, and auto-messaging  
├── consultation/ - Consultation mode with DND
├── consent/ - Digital consent and recording
├── payments/ - Payment processing and QR codes
├── ai_assistant/ - AI chat interface
├── teleconsult/ - Video consultation gateway
├── viewer_3d/ - 3D model viewer
└── settings/ - Comprehensive settings with compliance
```

### Styling and UI
- **Material Design 3** with custom AppTheme
- **Animated Backgrounds**: Floating medical icons
- **Custom Widgets**: Reusable components for appointments, patients, KPIs
- **Accessibility**: WCAG 2.1 AA compliance with text scaling and high contrast
- **Inter Font Family**: Custom typography with multiple weights

## Development Notes

### Code Generation
- Always run `dart run build_runner build` after modifying Hive model classes
- Generated files (*.g.dart) should not be manually edited
- Use `build_runner.bat` on Windows for convenience

### Lint Rules
- Enforces `prefer_single_quotes`, `prefer_relative_imports`, `prefer_const_constructors`
- Uses `flutter_lints` package with custom analysis_options.yaml
- Private notes fields should never be included in exports for HIPAA compliance

### Testing Strategy
- Widget tests for UI components and user interactions
- Unit tests for business logic like risk calculations and template resolution
- Mock data and calculations for prototype demonstration

### Assets Structure
- `assets/images/` - UI graphics and medical diagrams
- `assets/animations/` - Lottie and Rive animations
- `assets/models/` - 3D GLB files for viewer
- `assets/icons/` - Custom medical and UI icons
- `assets/audio/` - Sound effects and voice samples

### Internationalization
- Message templates support EN, PT, ES with fallback to English
- LocalizationService handles dynamic language switching
- All user-facing strings should support multiple locales
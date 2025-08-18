import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/settings_provider.dart';
import 'services/sync_service.dart';
import 'services/localization_service.dart';
import 'services/accessibility_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'models/user.dart';
import 'models/patient.dart';
import 'models/appointment.dart';
import 'models/tenant.dart';
import 'services/seed_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(TenantAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(UserRoleAdapter());
  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(AppointmentAdapter());
  
  // Open boxes
  await Hive.openBox('users');
  await Hive.openBox('patients');
  await Hive.openBox('appointments');
  await Hive.openBox('tenants');
  await Hive.openBox('settings');
  await Hive.openBox('offline_queue');
  
  // Seed data
  await SeedService.seedData();
  
  // Initialize services
  SyncService().initialize();
  await LocalizationService().initialize();
  await AccessibilityService().initialize();
  
  runApp(const BlookiaClinicApp());
}

class BlookiaClinicApp extends StatelessWidget {
  const BlookiaClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => SyncService()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
        ChangeNotifierProvider(create: (_) => AccessibilityService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Blookia Clinic',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(settings.locale),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
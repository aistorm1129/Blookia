import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _locale = 'en';
  bool _isMfaRequired = false;
  int _sessionTimeoutMinutes = 30;

  bool get isDarkMode => _isDarkMode;
  String get locale => _locale;
  bool get isMfaRequired => _isMfaRequired;
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;

  Map<String, String> get localeNames => {
    'en': 'English',
    'pt': 'Português',
    'es': 'Español',
  };

  Map<String, String> get localeDisplayNames => {
    'en': 'English',
    'pt': 'Portuguese',
    'es': 'Spanish',
  };

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final box = Hive.box('settings');
    _isDarkMode = box.get('dark_mode', defaultValue: false);
    _locale = box.get('locale', defaultValue: 'en');
    _isMfaRequired = box.get('mfa_required', defaultValue: false);
    _sessionTimeoutMinutes = box.get('session_timeout', defaultValue: 30);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final box = Hive.box('settings');
    await box.put('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setLocale(String newLocale) async {
    if (localeNames.containsKey(newLocale)) {
      _locale = newLocale;
      final box = Hive.box('settings');
      await box.put('locale', _locale);
      notifyListeners();
    }
  }

  Future<void> toggleMfaRequired() async {
    _isMfaRequired = !_isMfaRequired;
    final box = Hive.box('settings');
    await box.put('mfa_required', _isMfaRequired);
    notifyListeners();
  }

  Future<void> setSessionTimeout(int minutes) async {
    _sessionTimeoutMinutes = minutes;
    final box = Hive.box('settings');
    await box.put('session_timeout', _sessionTimeoutMinutes);
    notifyListeners();
  }

  String translate(String key) {
    // Simple translation mapping for demo
    final translations = {
      'en': {
        'welcome': 'Welcome to Blookia',
        'dashboard': 'Dashboard',
        'patients': 'Patients',
        'schedule': 'Schedule',
        'settings': 'Settings',
        'offline_mode': 'Offline Mode',
        'online': 'Online',
        'offline': 'Working Offline',
        'consultation': 'Consultation',
        'waitlist': 'Waitlist',
        'confirmed': 'Confirmed',
        'no_show': 'No Show',
        'cancelled': 'Cancelled',
        'completed': 'Completed',
        'payment': 'Payment',
        'transcript': 'Transcript',
        'consent': 'Consent',
        'private_notes': 'Private Notes',
        'internal_notes': 'Internal Notes (Not exported)',
        'pain_map': 'Pain Map',
        'start_consultation': 'Start Consultation',
        'end_consultation': 'End Consultation',
        'do_not_disturb': 'Do Not Disturb Mode',
        'timer': 'Timer',
        'loyalty_points': 'Loyalty Points',
        'handoff_to_human': 'Handoff to Human',
        'enter_room': 'Enter Room',
        'generate_qr': 'Generate QR Code',
        'mark_as_paid': 'Mark as Paid',
      },
      'pt': {
        'dashboard': 'Painel',
        'patients': 'Pacientes',
        'schedule': 'Agenda',
        'settings': 'Configurações',
        'offline_mode': 'Modo Offline',
        'online': 'Online',
        'offline': 'Trabalhando Offline',
        'consultation': 'Consulta',
        'waitlist': 'Lista de Espera',
        'confirmed': 'Confirmado',
        'no_show': 'Não Compareceu',
        'cancelled': 'Cancelado',
        'completed': 'Concluído',
        'payment': 'Pagamento',
        'transcript': 'Transcrição',
        'consent': 'Consentimento',
        'private_notes': 'Notas Privadas',
        'internal_notes': 'Notas Internas (Não exportadas)',
        'pain_map': 'Mapa da Dor',
        'start_consultation': 'Iniciar Consulta',
        'end_consultation': 'Finalizar Consulta',
        'do_not_disturb': 'Modo Não Perturbe',
        'timer': 'Cronômetro',
        'loyalty_points': 'Pontos de Fidelidade',
        'handoff_to_human': 'Transferir para Humano',
        'enter_room': 'Entrar na Sala',
        'generate_qr': 'Gerar Código QR',
        'mark_as_paid': 'Marcar como Pago',
      },
      'es': {
        'dashboard': 'Tablero',
        'patients': 'Pacientes',
        'schedule': 'Horario',
        'settings': 'Configuración',
        'offline_mode': 'Modo Sin Conexión',
        'online': 'En Línea',
        'offline': 'Trabajando Sin Conexión',
        'consultation': 'Consulta',
        'waitlist': 'Lista de Espera',
        'confirmed': 'Confirmado',
        'no_show': 'No Asistió',
        'cancelled': 'Cancelado',
        'completed': 'Completado',
        'payment': 'Pago',
        'transcript': 'Transcripción',
        'consent': 'Consentimiento',
        'private_notes': 'Notas Privadas',
        'internal_notes': 'Notas Internas (No exportadas)',
        'pain_map': 'Mapa del Dolor',
        'start_consultation': 'Iniciar Consulta',
        'end_consultation': 'Finalizar Consulta',
        'do_not_disturb': 'Modo No Molestar',
        'timer': 'Temporizador',
        'loyalty_points': 'Puntos de Fidelidad',
        'handoff_to_human': 'Transferir a Humano',
        'enter_room': 'Entrar a la Sala',
        'generate_qr': 'Generar Código QR',
        'mark_as_paid': 'Marcar como Pagado',
      },
    };

    return translations[_locale]?[key] ?? translations['en']?[key] ?? key;
  }
}
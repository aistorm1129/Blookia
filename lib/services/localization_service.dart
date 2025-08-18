import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  String _currentLocale = 'en';
  Map<String, dynamic> _localizedStrings = {};
  Map<String, Map<String, dynamic>> _allTranslations = {};
  
  // Supported locales
  final List<LocaleInfo> supportedLocales = [
    LocaleInfo('en', 'English', '🇺🇸'),
    LocaleInfo('pt', 'Português', '🇧🇷'),
    LocaleInfo('es', 'Español', '🇪🇸'),
  ];

  String get currentLocale => _currentLocale;
  Map<String, dynamic> get localizedStrings => _localizedStrings;

  Future<void> initialize() async {
    // Load saved locale
    final box = await Hive.openBox('settings');
    _currentLocale = box.get('locale', defaultValue: 'en');
    
    // Load all translations
    await _loadAllTranslations();
    
    // Set current translations
    _localizedStrings = _allTranslations[_currentLocale] ?? _allTranslations['en']!;
    
    notifyListeners();
  }

  Future<void> _loadAllTranslations() async {
    for (final locale in supportedLocales) {
      try {
        final jsonString = await rootBundle.loadString('assets/translations/${locale.code}.json');
        _allTranslations[locale.code] = json.decode(jsonString);
      } catch (e) {
        if (locale.code == 'en') {
          // Fallback for English if file doesn't exist
          _allTranslations['en'] = _getDefaultEnglishTranslations();
        }
        debugPrint('Failed to load translations for ${locale.code}: $e');
      }
    }
    
    // Ensure we have at least English translations
    if (_allTranslations.isEmpty) {
      _allTranslations['en'] = _getDefaultEnglishTranslations();
    }
  }

  Future<void> setLocale(String localeCode) async {
    if (_allTranslations.containsKey(localeCode)) {
      _currentLocale = localeCode;
      _localizedStrings = _allTranslations[localeCode]!;
      
      // Save to storage
      final box = await Hive.openBox('settings');
      await box.put('locale', localeCode);
      
      notifyListeners();
    }
  }

  String translate(String key, {Map<String, String>? params}) {
    String translation = _getNestedTranslation(key) ?? key;
    
    // Replace parameters
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        translation = translation.replaceAll('{$paramKey}', paramValue);
      });
    }
    
    return translation;
  }

  String? _getNestedTranslation(String key) {
    final keys = key.split('.');
    dynamic current = _localizedStrings;
    
    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        // Fallback to English if key not found in current locale
        current = _allTranslations['en'];
        for (final fallbackKey in keys) {
          if (current is Map<String, dynamic> && current.containsKey(fallbackKey)) {
            current = current[fallbackKey];
          } else {
            return null;
          }
        }
        break;
      }
    }
    
    return current is String ? current : null;
  }

  // Shorthand method
  String t(String key, {Map<String, String>? params}) {
    return translate(key, params: params);
  }

  // Pluralization support
  String plural(String key, int count, {Map<String, String>? params}) {
    final pluralKey = count == 1 ? '$key.singular' : '$key.plural';
    String translation = translate(pluralKey, params: params);
    
    if (translation == pluralKey) {
      // Fallback to base key if plural form doesn't exist
      translation = translate(key, params: params);
    }
    
    return translation.replaceAll('{count}', count.toString());
  }

  // Date and number formatting
  String formatDate(DateTime date) {
    switch (_currentLocale) {
      case 'pt':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'es':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'en':
      default:
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  String formatCurrency(double amount) {
    switch (_currentLocale) {
      case 'pt':
        return 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';
      case 'es':
        return '\$${amount.toStringAsFixed(2)}';
      case 'en':
      default:
        return '\$${amount.toStringAsFixed(2)}';
    }
  }

  String formatTime(DateTime dateTime) {
    switch (_currentLocale) {
      case 'pt':
      case 'es':
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      case 'en':
      default:
        final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
        final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
        return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
    }
  }

  // Default English translations if file loading fails
  Map<String, dynamic> _getDefaultEnglishTranslations() {
    return {
      "app": {
        "name": "Blookia",
        "welcome": "Welcome to Blookia",
        "loading": "Loading...",
        "error": "An error occurred",
        "retry": "Retry",
        "cancel": "Cancel",
        "save": "Save",
        "delete": "Delete",
        "edit": "Edit",
        "add": "Add",
        "search": "Search",
        "filter": "Filter",
        "close": "Close",
        "continue": "Continue",
        "back": "Back",
        "next": "Next",
        "finish": "Finish",
        "ok": "OK",
        "yes": "Yes",
        "no": "No"
      },
      "auth": {
        "select_role": "Select Your Role",
        "select_clinic": "Select Clinic",
        "doctor": "Doctor",
        "nurse": "Nurse",
        "assistant": "Assistant",
        "coordinator": "Coordinator",
        "continue_as": "Continue as {role}"
      },
      "dashboard": {
        "title": "Dashboard",
        "overview": "Overview",
        "today_appointments": "Today's Appointments",
        "patients_seen": "Patients Seen",
        "revenue": "Revenue",
        "satisfaction": "Satisfaction",
        "quick_actions": "Quick Actions",
        "view_all": "View All"
      },
      "patients": {
        "title": "Patients",
        "add_patient": "Add Patient",
        "patient_details": "Patient Details",
        "name": "Name",
        "phone": "Phone",
        "email": "Email",
        "date_of_birth": "Date of Birth",
        "allergies": "Allergies",
        "medications": "Medications",
        "notes": "Notes",
        "timeline": "Timeline",
        "payments": "Payments",
        "no_patients": "No patients found"
      },
      "appointments": {
        "title": "Appointments",
        "schedule": "Schedule",
        "new_appointment": "New Appointment",
        "consultation": "Consultation",
        "procedure": "Procedure",
        "follow_up": "Follow-up",
        "emergency": "Emergency",
        "confirmed": "Confirmed",
        "waitlist": "Waitlist",
        "cancelled": "Cancelled",
        "completed": "Completed",
        "no_show": "No Show"
      },
      "consultation": {
        "title": "Consultation",
        "pain_mapping": "Pain Mapping",
        "private_notes": "Private Notes",
        "start_consultation": "Start Consultation",
        "end_consultation": "End Consultation",
        "pain_level": "Pain Level",
        "no_pain": "No Pain",
        "mild": "Mild",
        "moderate": "Moderate",
        "severe": "Severe"
      },
      "payments": {
        "title": "Payments",
        "amount": "Amount",
        "method": "Payment Method",
        "status": "Status",
        "pending": "Pending",
        "completed": "Completed",
        "failed": "Failed",
        "pix": "PIX",
        "credit_card": "Credit Card",
        "debit_card": "Debit Card",
        "cash": "Cash",
        "bank_transfer": "Bank Transfer"
      },
      "ai": {
        "title": "AI Assistant",
        "ask_anything": "Ask me anything...",
        "clinical_mode": "Clinical Mode",
        "general_mode": "General Mode",
        "analytics_mode": "Analytics Mode",
        "consultation_mode": "Consultation Mode"
      },
      "teleconsult": {
        "title": "Teleconsult",
        "start_session": "Start Session",
        "end_session": "End Session",
        "connection_quality": "Connection Quality",
        "excellent": "Excellent",
        "good": "Good",
        "poor": "Poor"
      },
      "sync": {
        "syncing": "Syncing",
        "synced": "Synced",
        "offline": "Offline",
        "pending": "Pending",
        "conflicts": "Conflicts",
        "last_sync": "Last sync",
        "sync_now": "Sync Now",
        "auto_sync": "Auto Sync"
      },
      "settings": {
        "title": "Settings",
        "language": "Language",
        "theme": "Theme",
        "notifications": "Notifications",
        "privacy": "Privacy",
        "about": "About",
        "logout": "Logout"
      },
      "accessibility": {
        "increase_text_size": "Increase text size",
        "decrease_text_size": "Decrease text size",
        "high_contrast": "High contrast",
        "voice_over": "Voice over",
        "screen_reader": "Screen reader support"
      }
    };
  }
}

// Create translation files
Future<void> createTranslationFiles() async {
  final localizationService = LocalizationService();
  
  // Portuguese translations
  final ptTranslations = {
    "app": {
      "name": "Blookia",
      "welcome": "Bem-vindo ao Blookia",
      "loading": "Carregando...",
      "error": "Ocorreu um erro",
      "retry": "Tentar novamente",
      "cancel": "Cancelar",
      "save": "Salvar",
      "delete": "Excluir",
      "edit": "Editar",
      "add": "Adicionar",
      "search": "Pesquisar",
      "filter": "Filtrar",
      "close": "Fechar",
      "continue": "Continuar",
      "back": "Voltar",
      "next": "Próximo",
      "finish": "Finalizar",
      "ok": "OK",
      "yes": "Sim",
      "no": "Não"
    },
    "auth": {
      "select_role": "Selecione seu Cargo",
      "select_clinic": "Selecione a Clínica",
      "doctor": "Médico",
      "nurse": "Enfermeiro",
      "assistant": "Assistente",
      "coordinator": "Coordenador",
      "continue_as": "Continuar como {role}"
    },
    "dashboard": {
      "title": "Painel",
      "overview": "Visão Geral",
      "today_appointments": "Consultas de Hoje",
      "patients_seen": "Pacientes Atendidos",
      "revenue": "Receita",
      "satisfaction": "Satisfação",
      "quick_actions": "Ações Rápidas",
      "view_all": "Ver Todos"
    },
    "patients": {
      "title": "Pacientes",
      "add_patient": "Adicionar Paciente",
      "patient_details": "Detalhes do Paciente",
      "name": "Nome",
      "phone": "Telefone",
      "email": "E-mail",
      "date_of_birth": "Data de Nascimento",
      "allergies": "Alergias",
      "medications": "Medicamentos",
      "notes": "Anotações",
      "timeline": "Histórico",
      "payments": "Pagamentos",
      "no_patients": "Nenhum paciente encontrado"
    },
    "appointments": {
      "title": "Consultas",
      "schedule": "Agenda",
      "new_appointment": "Nova Consulta",
      "consultation": "Consulta",
      "procedure": "Procedimento",
      "follow_up": "Retorno",
      "emergency": "Emergência",
      "confirmed": "Confirmado",
      "waitlist": "Lista de Espera",
      "cancelled": "Cancelado",
      "completed": "Concluído",
      "no_show": "Faltou"
    },
    "consultation": {
      "title": "Consulta",
      "pain_mapping": "Mapeamento da Dor",
      "private_notes": "Notas Privadas",
      "start_consultation": "Iniciar Consulta",
      "end_consultation": "Finalizar Consulta",
      "pain_level": "Nível da Dor",
      "no_pain": "Sem Dor",
      "mild": "Leve",
      "moderate": "Moderada",
      "severe": "Severa"
    },
    "payments": {
      "title": "Pagamentos",
      "amount": "Valor",
      "method": "Método de Pagamento",
      "status": "Status",
      "pending": "Pendente",
      "completed": "Concluído",
      "failed": "Falhou",
      "pix": "PIX",
      "credit_card": "Cartão de Crédito",
      "debit_card": "Cartão de Débito",
      "cash": "Dinheiro",
      "bank_transfer": "Transferência Bancária"
    }
  };
  
  // Spanish translations
  final esTranslations = {
    "app": {
      "name": "Blookia",
      "welcome": "Bienvenido a Blookia",
      "loading": "Cargando...",
      "error": "Ocurrió un error",
      "retry": "Reintentar",
      "cancel": "Cancelar",
      "save": "Guardar",
      "delete": "Eliminar",
      "edit": "Editar",
      "add": "Agregar",
      "search": "Buscar",
      "filter": "Filtrar",
      "close": "Cerrar",
      "continue": "Continuar",
      "back": "Atrás",
      "next": "Siguiente",
      "finish": "Finalizar",
      "ok": "OK",
      "yes": "Sí",
      "no": "No"
    },
    "auth": {
      "select_role": "Seleccione su Rol",
      "select_clinic": "Seleccione Clínica",
      "doctor": "Doctor",
      "nurse": "Enfermero",
      "assistant": "Asistente",
      "coordinator": "Coordinador",
      "continue_as": "Continuar como {role}"
    },
    "dashboard": {
      "title": "Tablero",
      "overview": "Resumen",
      "today_appointments": "Citas de Hoy",
      "patients_seen": "Pacientes Atendidos",
      "revenue": "Ingresos",
      "satisfaction": "Satisfacción",
      "quick_actions": "Acciones Rápidas",
      "view_all": "Ver Todos"
    }
  };
  
  debugPrint('Translation files structure created');
}

class LocaleInfo {
  final String code;
  final String name;
  final String flag;

  LocaleInfo(this.code, this.name, this.flag);
}
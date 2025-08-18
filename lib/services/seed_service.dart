import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/tenant.dart';
import '../models/user.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../models/message_template.dart';
import '../models/payment.dart';

class SeedService {
  static const _uuid = Uuid();

  static Future<void> seedData() async {
    // Check if already seeded
    final settingsBox = Hive.box('settings');
    if (settingsBox.get('seeded', defaultValue: false)) {
      return;
    }

    await _seedTenants();
    await _seedUsers();
    await _seedPatients();
    await _seedAppointments();
    await _seedMessageTemplates();
    await _seedPayments();

    await settingsBox.put('seeded', true);
  }

  static Future<void> _seedTenants() async {
    final box = Hive.box('tenants');
    
    final tenants = [
      Tenant(
        id: 'tenant_1',
        name: 'Aesthetic Clinic Brazil',
        country: 'BR',
        address: 'Av. Paulista, 1000 - São Paulo, SP',
        phone: '+55 11 9999-0001',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      Tenant(
        id: 'tenant_2',
        name: 'Beauty Center Miami',
        country: 'US',
        address: '1234 Ocean Drive - Miami, FL',
        phone: '+1 305 555-0001',
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      Tenant(
        id: 'tenant_3',
        name: 'Clínica Bella Madrid',
        country: 'ES',
        address: 'Calle Serrano, 45 - Madrid',
        phone: '+34 91 555-0001',
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
    ];

    for (final tenant in tenants) {
      await box.put(tenant.id, tenant.toJson());
    }
  }

  static Future<void> _seedUsers() async {
    final box = Hive.box('users');
    
    final users = [
      // Tenant 1 - Brazil
      User(
        id: 'user_1',
        name: 'Dr. Ana Silva',
        role: UserRole.professional,
        tenantId: 'tenant_1',
        email: 'ana.silva@clinic.br',
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
      User(
        id: 'user_2',
        name: 'Maria Santos',
        role: UserRole.reception,
        tenantId: 'tenant_1',
        email: 'maria.santos@clinic.br',
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
      ),
      User(
        id: 'user_3',
        name: 'Carlos Admin',
        role: UserRole.admin,
        tenantId: 'tenant_1',
        email: 'admin@clinic.br',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      
      // Tenant 2 - US
      User(
        id: 'user_4',
        name: 'Dr. Jennifer Smith',
        role: UserRole.professional,
        tenantId: 'tenant_2',
        email: 'jennifer@beautycenter.com',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      User(
        id: 'user_5',
        name: 'Lisa Johnson',
        role: UserRole.reception,
        tenantId: 'tenant_2',
        email: 'lisa@beautycenter.com',
        createdAt: DateTime.now().subtract(const Duration(days: 160)),
      ),
      
      // Tenant 3 - Spain
      User(
        id: 'user_6',
        name: 'Dr. Carmen López',
        role: UserRole.professional,
        tenantId: 'tenant_3',
        email: 'carmen@clinicabella.es',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      User(
        id: 'user_7',
        name: 'Isabella García',
        role: UserRole.reception,
        tenantId: 'tenant_3',
        email: 'isabella@clinicabella.es',
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
      ),
      User(
        id: 'user_8',
        name: 'Dr. Rafael Torres',
        role: UserRole.professional,
        tenantId: 'tenant_3',
        email: 'rafael@clinicabella.es',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];

    for (final user in users) {
      await box.put(user.id, user.toJson());
    }
  }

  static Future<void> _seedPatients() async {
    final box = Hive.box('patients');
    
    final patientNames = [
      'Sofia Rodriguez', 'Isabella Martínez', 'Camila González', 'Valentina López',
      'Mariana Silva', 'Lucía Fernández', 'Emma Thompson', 'Olivia Wilson',
      'Ava Davis', 'Charlotte Brown', 'Mia Johnson', 'Harper Garcia',
      'Evelyn Miller', 'Abigail Martinez', 'Emily Anderson', 'Elizabeth Taylor',
      'Sofia Pereira', 'Ana Costa', 'Beatriz Santos', 'Carolina Oliveira',
      'Daniela Almeida', 'Fernanda Lima', 'Gabriela Souza', 'Helena Barbosa',
      'Juliana Gomes', 'Larissa Rocha', 'Natália Carvalho', 'Patricia Ribeiro'
    ];

    for (int i = 0; i < patientNames.length; i++) {
      final patient = Patient(
        id: 'patient_${i + 1}',
        name: patientNames[i],
        docType: 'CPF',
        docNumber: '${(11111111111 + i * 1111).toString().padLeft(11, '0')}',
        phone: '+55 11 9999-${(1000 + i).toString()}',
        email: '${patientNames[i].toLowerCase().replaceAll(' ', '.')}@email.com',
        address: 'Rua ${i + 1}, ${(100 + i * 10)} - São Paulo, SP',
        internalNotes: i % 5 == 0 ? ['High-maintenance client', 'Prefers morning appointments'] : [],
        allergies: i % 7 == 0 ? ['Lidocaine', 'Latex'] : [],
        medications: i % 8 == 0 ? ['Aspirin'] : [],
        createdAt: DateTime.now().subtract(Duration(days: 365 - i * 10)),
        updatedAt: DateTime.now().subtract(Duration(days: i * 2)),
        loyaltyPoints: i * 25,
        dateOfBirth: DateTime.now().subtract(Duration(days: 365 * (25 + i))),
      );
      await box.put(patient.id, patient.toJson());
    }
  }

  static Future<void> _seedAppointments() async {
    final box = Hive.box('appointments');
    
    final now = DateTime.now();
    final statuses = [
      AppointmentStatus.confirmed,
      AppointmentStatus.waitlist,
      AppointmentStatus.confirmed,
      AppointmentStatus.confirmed,
      AppointmentStatus.noShow,
    ];

    final types = [
      AppointmentType.consultation,
      AppointmentType.procedure,
      AppointmentType.followUp,
      AppointmentType.consultation,
      AppointmentType.procedure,
    ];

    for (int i = 0; i < 40; i++) {
      final startDate = now.add(Duration(days: i % 14 - 7));
      final appointment = Appointment(
        id: 'appointment_${i + 1}',
        patientId: 'patient_${(i % 20) + 1}',
        professionalId: 'user_${i % 3 == 0 ? 1 : i % 3 == 1 ? 4 : 6}',
        start: DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          9 + (i % 8),
          (i % 4) * 15,
        ),
        end: DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          9 + (i % 8),
          (i % 4) * 15 + 60,
        ),
        type: types[i % types.length],
        status: statuses[i % statuses.length],
        channel: Channel.inPerson,
        noShowRisk: (i % 10) / 10,
        notes: i % 3 == 0 ? 'Regular maintenance appointment' : null,
        privateNotes: i % 5 == 0 ? 'Patient mentioned sensitivity to pain' : null,
        createdAt: now.subtract(Duration(days: 30 - i)),
        updatedAt: now.subtract(Duration(days: i)),
        durationMinutes: 60,
        isUrgent: i % 10 == 0,
      );
      await box.put(appointment.id, appointment.toJson());
    }
  }

  static Future<void> _seedMessageTemplates() async {
    final box = Hive.box('message_templates');
    
    final templates = [
      MessageTemplate(
        id: 'template_confirm',
        kind: MessageKind.confirm,
        textByLocale: {
          'en': 'Hi {patientName}! Your appointment is confirmed for {date} at {time}. See you soon!',
          'pt': 'Olá {patientName}! Seu agendamento está confirmado para {date} às {time}. Te esperamos!',
          'es': '¡Hola {patientName}! Tu cita está confirmada para {date} a las {time}. ¡Nos vemos pronto!',
        },
        tenantId: 'tenant_1',
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        updatedAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
      MessageTemplate(
        id: 'template_reminder',
        kind: MessageKind.reminder,
        textByLocale: {
          'en': 'Reminder: You have an appointment tomorrow at {time}. Reply CONFIRM to confirm.',
          'pt': 'Lembrete: Você tem um agendamento amanhã às {time}. Responda CONFIRMAR para confirmar.',
          'es': 'Recordatorio: Tienes una cita mañana a las {time}. Responde CONFIRMAR para confirmar.',
        },
        tenantId: 'tenant_1',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      MessageTemplate(
        id: 'template_thankyou',
        kind: MessageKind.thankyou,
        textByLocale: {
          'en': 'Thank you for visiting us today, {patientName}! We hope you\'re happy with the results.',
          'pt': 'Obrigado por nos visitar hoje, {patientName}! Esperamos que esteja feliz com os resultados.',
          'es': '¡Gracias por visitarnos hoy, {patientName}! Esperamos que estés feliz con los resultados.',
        },
        tenantId: 'tenant_1',
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];

    for (final template in templates) {
      await box.put(template.id, template.toJson());
    }
  }

  static Future<void> _seedPayments() async {
    final box = Hive.box('payments');
    
    for (int i = 0; i < 15; i++) {
      final payment = Payment(
        id: 'payment_${i + 1}',
        patientId: 'patient_${(i % 15) + 1}',
        amount: [150.0, 250.0, 350.0, 500.0, 750.0][i % 5],
        method: PaymentMethod.values[i % PaymentMethod.values.length],
        status: i % 6 == 0 ? PaymentStatus.pending : PaymentStatus.completed,
        txId: 'TX${DateTime.now().millisecondsSinceEpoch + i}',
        timestamp: DateTime.now().subtract(Duration(days: i * 3)),
        appointmentId: 'appointment_${i + 1}',
        description: 'Aesthetic treatment payment',
      );
      await box.put(payment.id, payment.toJson());
    }
  }
}
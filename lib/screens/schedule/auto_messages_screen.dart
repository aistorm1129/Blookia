import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/message_template.dart';

class AutoMessagesScreen extends StatefulWidget {
  const AutoMessagesScreen({super.key});

  @override
  State<AutoMessagesScreen> createState() => _AutoMessagesScreenState();
}

class _AutoMessagesScreenState extends State<AutoMessagesScreen> {
  String _selectedLocale = 'en';
  MessageKind _selectedTemplate = MessageKind.confirm;
  bool _confirmAttendance = true;

  // Mock message templates
  final Map<MessageKind, Map<String, String>> _templates = {
    MessageKind.confirm: {
      'en': 'Hi {patientName}! Your appointment is confirmed for {date} at {time}. Please confirm your attendance by replying YES. See you soon at {clinicName}!',
      'pt': 'Olá {patientName}! Seu agendamento está confirmado para {date} às {time}. Por favor, confirme sua presença respondendo SIM. Te esperamos na {clinicName}!',
      'es': '¡Hola {patientName}! Tu cita está confirmada para {date} a las {time}. Confirma tu asistencia respondiendo SÍ. ¡Nos vemos en {clinicName}!',
    },
    MessageKind.reminder: {
      'en': 'Reminder: You have an appointment tomorrow at {time} with Dr. {professionalName}. Reply CONFIRM to confirm or CANCEL to reschedule.',
      'pt': 'Lembrete: Você tem um agendamento amanhã às {time} com Dr(a). {professionalName}. Responda CONFIRMAR para confirmar ou CANCELAR para reagendar.',
      'es': 'Recordatorio: Tienes una cita mañana a las {time} con Dr. {professionalName}. Responde CONFIRMAR para confirmar o CANCELAR para reprogramar.',
    },
    MessageKind.thankyou: {
      'en': 'Thank you for visiting {clinicName} today, {patientName}! We hope you\'re happy with your treatment. Your next appointment is scheduled for {nextDate}.',
      'pt': 'Obrigado por visitar a {clinicName} hoje, {patientName}! Esperamos que esteja satisfeito(a) com seu tratamento. Seu próximo agendamento é em {nextDate}.',
      'es': '¡Gracias por visitar {clinicName} hoy, {patientName}! Esperamos que estés feliz con tu tratamiento. Tu próxima cita está programada para {nextDate}.',
    },
    MessageKind.cancel: {
      'en': 'Your appointment on {date} at {time} has been cancelled. We apologize for any inconvenience. Please call us to reschedule: {phone}.',
      'pt': 'Seu agendamento do dia {date} às {time} foi cancelado. Pedimos desculpas pelo inconveniente. Ligue para reagendar: {phone}.',
      'es': 'Tu cita del {date} a las {time} ha sido cancelada. Nos disculpamos por las molestias. Llámanos para reprogramar: {phone}.',
    },
    MessageKind.rebook: {
      'en': 'We have an available slot on {date} at {time}. Would you like to book this appointment? Reply YES to confirm or NO to decline.',
      'pt': 'Temos um horário disponível no dia {date} às {time}. Gostaria de agendar? Responda SIM para confirmar ou NÃO para recusar.',
      'es': 'Tenemos un horario disponible el {date} a las {time}. ¿Te gustaría reservar esta cita? Responde SÍ para confirmar o NO para declinar.',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Auto Messages'),
            actions: [
              TextButton(
                onPressed: () => _sendMessage(context),
                child: const Text('SEND'),
              ),
            ],
          ),
          body: Column(
            children: [
              // Controls Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Message Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Template Type Selection
                    Row(
                      children: [
                        const Icon(Icons.message, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('Template:', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<MessageKind>(
                            value: _selectedTemplate,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                _selectedTemplate = value!;
                              });
                            },
                            items: MessageKind.values.map((kind) {
                              return DropdownMenuItem(
                                value: kind,
                                child: Text(_getTemplateDisplayName(kind)),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Language Selection
                    Row(
                      children: [
                        const Icon(Icons.language, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Language:', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedLocale,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                _selectedLocale = value!;
                              });
                            },
                            items: settings.localeDisplayNames.entries.map((entry) {
                              return DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Confirm Attendance Toggle
                    if (_selectedTemplate == MessageKind.confirm)
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text('Confirm Attendance:', style: TextStyle(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Switch(
                            value: _confirmAttendance,
                            onChanged: (value) {
                              setState(() {
                                _confirmAttendance = value;
                              });
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              // Message Preview
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Message Preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Preview Card
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Message Header
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.medical_services,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Blookia Clinic',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'now',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Icon(
                                    _getChannelIcon(),
                                    color: _getChannelColor(),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Message Content
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      _getPreviewText(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Channel Indicators
                              Wrap(
                                spacing: 8,
                                children: [
                                  _buildChannelChip('WhatsApp', Icons.chat, Colors.green),
                                  _buildChannelChip('SMS', Icons.sms, Colors.blue),
                                  _buildChannelChip('Email', Icons.email, Colors.orange),
                                  _buildChannelChip('Instagram', Icons.camera_alt, Colors.purple),
                                  _buildChannelChip('Telegram', Icons.telegram, Colors.cyan),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Send Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _sendMessage(context),
                          icon: const Icon(Icons.send),
                          label: const Text('Send Message'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChannelChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color,
    );
  }

  String _getTemplateDisplayName(MessageKind kind) {
    switch (kind) {
      case MessageKind.confirm:
        return 'Confirmation';
      case MessageKind.reminder:
        return 'Reminder';
      case MessageKind.thankyou:
        return 'Thank You';
      case MessageKind.cancel:
        return 'Cancellation';
      case MessageKind.rebook:
        return 'Rebook Offer';
    }
  }

  String _getPreviewText() {
    final template = _templates[_selectedTemplate]?[_selectedLocale] ?? '';
    
    // Replace placeholders with example data
    return template
        .replaceAll('{patientName}', 'Sofia Rodriguez')
        .replaceAll('{date}', 'Monday, March 15th')
        .replaceAll('{time}', '2:30 PM')
        .replaceAll('{clinicName}', 'Blookia Aesthetic Clinic')
        .replaceAll('{professionalName}', 'Dr. Ana Silva')
        .replaceAll('{phone}', '+55 11 9999-0001')
        .replaceAll('{nextDate}', 'April 15th');
  }

  IconData _getChannelIcon() {
    switch (_selectedTemplate) {
      case MessageKind.confirm:
        return Icons.check_circle;
      case MessageKind.reminder:
        return Icons.alarm;
      case MessageKind.thankyou:
        return Icons.favorite;
      case MessageKind.cancel:
        return Icons.cancel;
      case MessageKind.rebook:
        return Icons.event_available;
    }
  }

  Color _getChannelColor() {
    switch (_selectedTemplate) {
      case MessageKind.confirm:
        return Colors.green;
      case MessageKind.reminder:
        return Colors.orange;
      case MessageKind.thankyou:
        return Colors.pink;
      case MessageKind.cancel:
        return Colors.red;
      case MessageKind.rebook:
        return Colors.blue;
    }
  }

  void _sendMessage(BuildContext context) {
    // Mock sending message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Sent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Your ${_getTemplateDisplayName(_selectedTemplate).toLowerCase()} message has been sent successfully!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Channels: WhatsApp, SMS, Email',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/appointment.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  Appointment? _selectedAppointment;
  DateTime _selectedDate = DateTime.now();
  bool _isConsultationMode = false;
  int _consultationTimer = 0;

  List<Appointment> get appointments => _appointments;
  Appointment? get selectedAppointment => _selectedAppointment;
  DateTime get selectedDate => _selectedDate;
  bool get isConsultationMode => _isConsultationMode;
  int get consultationTimer => _consultationTimer;

  List<Appointment> get todayAppointments {
    final today = DateTime.now();
    return _appointments.where((apt) {
      return apt.start.year == today.year &&
             apt.start.month == today.month &&
             apt.start.day == today.day;
    }).toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments.where((apt) {
      return apt.start.isAfter(now) && 
             apt.status != AppointmentStatus.cancelled;
    }).toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  List<Appointment> get waitlistAppointments {
    return _appointments.where((apt) => 
        apt.status == AppointmentStatus.waitlist
    ).toList();
  }

  List<Appointment> get highRiskAppointments {
    return _appointments.where((apt) => 
        apt.noShowRisk >= 0.7 && apt.status == AppointmentStatus.confirmed
    ).toList();
  }

  AppointmentProvider() {
    _loadAppointments();
  }

  void _loadAppointments() async {
    final box = Hive.box('appointments');
    _appointments = box.values
        .map((data) => Appointment.fromJson(Map<String, dynamic>.from(data)))
        .toList();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void selectAppointment(Appointment appointment) {
    _selectedAppointment = appointment;
    notifyListeners();
  }

  void clearSelection() {
    _selectedAppointment = null;
    notifyListeners();
  }

  Future<void> addAppointment(Appointment appointment) async {
    final box = Hive.box('appointments');
    await box.put(appointment.id, appointment.toJson());
    
    _appointments.add(appointment);
    notifyListeners();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final box = Hive.box('appointments');
    appointment.updatedAt = DateTime.now();
    await box.put(appointment.id, appointment.toJson());
    
    final index = _appointments.indexWhere((a) => a.id == appointment.id);
    if (index != -1) {
      _appointments[index] = appointment;
      
      if (_selectedAppointment?.id == appointment.id) {
        _selectedAppointment = appointment;
      }
    }
    notifyListeners();
  }

  Future<void> deleteAppointment(String appointmentId) async {
    final box = Hive.box('appointments');
    await box.delete(appointmentId);
    
    _appointments.removeWhere((a) => a.id == appointmentId);
    
    if (_selectedAppointment?.id == appointmentId) {
      _selectedAppointment = null;
    }
    notifyListeners();
  }

  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    final appointment = _appointments.firstWhere((a) => a.id == appointmentId);
    appointment.status = status;
    await updateAppointment(appointment);
  }

  Future<void> addPrivateNotes(String appointmentId, String notes) async {
    final appointment = _appointments.firstWhere((a) => a.id == appointmentId);
    appointment.privateNotes = notes;
    await updateAppointment(appointment);
  }

  Future<void> updatePainMapScores(String appointmentId, Map<String, int> scores) async {
    final appointment = _appointments.firstWhere((a) => a.id == appointmentId);
    appointment.painMapScores = scores;
    await updateAppointment(appointment);
  }

  Future<void> giveConsent(String appointmentId, bool consent) async {
    final appointment = _appointments.firstWhere((a) => a.id == appointmentId);
    appointment.consentGiven = consent;
    await updateAppointment(appointment);
  }

  void startConsultation() {
    _isConsultationMode = true;
    _consultationTimer = 0;
    notifyListeners();
    
    // Start timer (simplified - in real app would use proper timer)
    _startTimer();
  }

  void endConsultation() {
    _isConsultationMode = false;
    _consultationTimer = 0;
    notifyListeners();
  }

  void _startTimer() {
    // Simplified timer implementation
    Future.delayed(const Duration(seconds: 1), () {
      if (_isConsultationMode) {
        _consultationTimer++;
        notifyListeners();
        _startTimer();
      }
    });
  }

  String get formattedTimer {
    final minutes = _consultationTimer ~/ 60;
    final seconds = _consultationTimer % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  List<Appointment> getAppointmentsForDate(DateTime date) {
    return _appointments.where((apt) {
      return apt.start.year == date.year &&
             apt.start.month == date.month &&
             apt.start.day == date.day;
    }).toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  List<Appointment> getAppointmentsForPatient(String patientId) {
    return _appointments.where((apt) => 
        apt.patientId == patientId
    ).toList()..sort((a, b) => b.start.compareTo(a.start));
  }

  double calculateNoShowRisk(String patientId) {
    // Simplified risk calculation
    final patientAppointments = getAppointmentsForPatient(patientId);
    if (patientAppointments.isEmpty) return 0.1;
    
    final noShowCount = patientAppointments.where((apt) => 
        apt.status == AppointmentStatus.noShow
    ).length;
    
    return (noShowCount / patientAppointments.length).clamp(0.0, 1.0);
  }
}
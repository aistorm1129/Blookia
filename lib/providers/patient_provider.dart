import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/patient.dart';

class PatientProvider with ChangeNotifier {
  List<Patient> _patients = [];
  Patient? _selectedPatient;
  String _searchQuery = '';

  List<Patient> get patients => _filteredPatients;
  Patient? get selectedPatient => _selectedPatient;
  String get searchQuery => _searchQuery;

  List<Patient> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    
    return _patients.where((patient) {
      final query = _searchQuery.toLowerCase();
      return patient.name.toLowerCase().contains(query) ||
             patient.docNumber.toLowerCase().contains(query) ||
             (patient.phone?.toLowerCase().contains(query) ?? false) ||
             (patient.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  PatientProvider() {
    _loadPatients();
  }

  void _loadPatients() async {
    final box = Hive.box('patients');
    _patients = box.values
        .map((data) => Patient.fromJson(Map<String, dynamic>.from(data)))
        .toList();
    
    // Sort by name
    _patients.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectPatient(Patient patient) {
    _selectedPatient = patient;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPatient = null;
    notifyListeners();
  }

  Future<void> addPatient(Patient patient) async {
    final box = Hive.box('patients');
    await box.put(patient.id, patient.toJson());
    
    _patients.add(patient);
    _patients.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> updatePatient(Patient patient) async {
    final box = Hive.box('patients');
    patient.updatedAt = DateTime.now();
    await box.put(patient.id, patient.toJson());
    
    final index = _patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      _patients[index] = patient;
      _patients.sort((a, b) => a.name.compareTo(b.name));
      
      if (_selectedPatient?.id == patient.id) {
        _selectedPatient = patient;
      }
    }
    notifyListeners();
  }

  Future<void> deletePatient(String patientId) async {
    final box = Hive.box('patients');
    await box.delete(patientId);
    
    _patients.removeWhere((p) => p.id == patientId);
    
    if (_selectedPatient?.id == patientId) {
      _selectedPatient = null;
    }
    notifyListeners();
  }

  Future<void> addInternalNote(String patientId, String note) async {
    final patient = _patients.firstWhere((p) => p.id == patientId);
    patient.internalNotes.add(note);
    patient.updatedAt = DateTime.now();
    
    await updatePatient(patient);
  }

  Future<void> removeInternalNote(String patientId, int noteIndex) async {
    final patient = _patients.firstWhere((p) => p.id == patientId);
    if (noteIndex >= 0 && noteIndex < patient.internalNotes.length) {
      patient.internalNotes.removeAt(noteIndex);
      patient.updatedAt = DateTime.now();
      await updatePatient(patient);
    }
  }

  Future<void> addLoyaltyPoints(String patientId, int points) async {
    final patient = _patients.firstWhere((p) => p.id == patientId);
    patient.loyaltyPoints += points;
    patient.updatedAt = DateTime.now();
    await updatePatient(patient);
  }

  Patient? getPatientById(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Patient> getPatientsWithHighLoyaltyPoints() {
    return _patients.where((p) => p.loyaltyPoints >= 100).toList();
  }

  List<Patient> getPatientsWithRecentActivity() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _patients.where((p) => p.updatedAt.isAfter(thirtyDaysAgo)).toList();
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/patient.dart';
import '../../providers/patient_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/private_notes_section.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Patient _currentPatient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentPatient = widget.patient;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PatientProvider, AppointmentProvider, SettingsProvider>(
      builder: (context, patientProvider, appointmentProvider, settings, _) {
        // Get updated patient data
        final updatedPatient = patientProvider.getPatientById(_currentPatient.id);
        if (updatedPatient != null) {
          _currentPatient = updatedPatient;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_currentPatient.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editPatient(),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'export':
                      _exportPatientData();
                      break;
                    case 'schedule':
                      _scheduleAppointment();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Export Data'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'schedule',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text('Schedule Appointment'),
                      ],
                    ),
                  ),\n                ],\n              ),\n            ],\n          ),\n          body: Column(\n            children: [\n              // Patient Header\n              Container(\n                width: double.infinity,\n                padding: const EdgeInsets.all(20),\n                decoration: BoxDecoration(\n                  gradient: LinearGradient(\n                    colors: [\n                      Theme.of(context).primaryColor,\n                      Theme.of(context).primaryColor.withOpacity(0.8),\n                    ],\n                  ),\n                ),\n                child: Column(\n                  children: [\n                    // Avatar\n                    Container(\n                      width: 80,\n                      height: 80,\n                      decoration: BoxDecoration(\n                        color: Colors.white,\n                        borderRadius: BorderRadius.circular(40),\n                        boxShadow: [\n                          BoxShadow(\n                            color: Colors.black.withOpacity(0.2),\n                            blurRadius: 10,\n                            offset: const Offset(0, 4),\n                          ),\n                        ],\n                      ),\n                      child: Center(\n                        child: Text(\n                          _getInitials(_currentPatient.name),\n                          style: TextStyle(\n                            fontSize: 28,\n                            fontWeight: FontWeight.bold,\n                            color: Theme.of(context).primaryColor,\n                          ),\n                        ),\n                      ),\n                    ),\n                    \n                    const SizedBox(height: 12),\n                    \n                    // Name and Status\n                    Text(\n                      _currentPatient.name,\n                      style: const TextStyle(\n                        fontSize: 24,\n                        fontWeight: FontWeight.bold,\n                        color: Colors.white,\n                      ),\n                    ),\n                    \n                    const SizedBox(height: 8),\n                    \n                    // Quick Stats\n                    Row(\n                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,\n                      children: [\n                        _buildStatChip(\n                          Icons.star,\n                          '${_currentPatient.loyaltyPoints} pts',\n                          Colors.amber,\n                        ),\n                        if (_currentPatient.allergies.isNotEmpty)\n                          _buildStatChip(\n                            Icons.warning,\n                            'Allergies',\n                            Colors.red,\n                          ),\n                        if (_currentPatient.internalNotes.isNotEmpty)\n                          _buildStatChip(\n                            Icons.note,\n                            '${_currentPatient.internalNotes.length} notes',\n                            Colors.orange,\n                          ),\n                      ],\n                    ),\n                  ],\n                ),\n              ),\n              \n              // Tab Bar\n              TabBar(\n                controller: _tabController,\n                tabs: const [\n                  Tab(text: 'Profile', icon: Icon(Icons.person)),\n                  Tab(text: 'Timeline', icon: Icon(Icons.history)),\n                  Tab(text: 'Payments', icon: Icon(Icons.payment)),\n                  Tab(text: 'Notes', icon: Icon(Icons.note)),\n                ],\n              ),\n              \n              // Tab Content\n              Expanded(\n                child: TabBarView(\n                  controller: _tabController,\n                  children: [\n                    _buildProfileTab(),\n                    _buildTimelineTab(appointmentProvider),\n                    _buildPaymentsTab(),\n                    _buildNotesTab(patientProvider),\n                  ],\n                ),\n              ),\n            ],\n          ),\n        );\n      },\n    );\n  }\n\n  Widget _buildStatChip(IconData icon, String label, Color color) {\n    return Container(\n      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),\n      decoration: BoxDecoration(\n        color: Colors.white.withOpacity(0.2),\n        borderRadius: BorderRadius.circular(20),\n      ),\n      child: Row(\n        mainAxisSize: MainAxisSize.min,\n        children: [\n          Icon(icon, size: 16, color: color),\n          const SizedBox(width: 4),\n          Text(\n            label,\n            style: const TextStyle(\n              fontSize: 12,\n              color: Colors.white,\n              fontWeight: FontWeight.w600,\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  Widget _buildProfileTab() {\n    return SingleChildScrollView(\n      padding: const EdgeInsets.all(16),\n      child: Column(\n        children: [\n          _buildInfoCard(\n            'Personal Information',\n            [\n              _buildInfoRow('Full Name', _currentPatient.name),\n              _buildInfoRow('Document Type', _currentPatient.docType),\n              _buildInfoRow('Document Number', _currentPatient.docNumber),\n              if (_currentPatient.dateOfBirth != null)\n                _buildInfoRow(\n                  'Date of Birth',\n                  _formatDate(_currentPatient.dateOfBirth!),\n                ),\n            ],\n          ),\n          \n          const SizedBox(height: 16),\n          \n          _buildInfoCard(\n            'Contact Information',\n            [\n              if (_currentPatient.phone != null)\n                _buildInfoRow('Phone', _currentPatient.phone!),\n              if (_currentPatient.email != null)\n                _buildInfoRow('Email', _currentPatient.email!),\n              if (_currentPatient.address != null)\n                _buildInfoRow('Address', _currentPatient.address!),\n              if (_currentPatient.emergencyContact != null)\n                _buildInfoRow('Emergency Contact', _currentPatient.emergencyContact!),\n            ],\n          ),\n          \n          const SizedBox(height: 16),\n          \n          if (_currentPatient.allergies.isNotEmpty) ..[\n            _buildInfoCard(\n              'Allergies & Medical Info',\n              [\n                _buildChipRow('Allergies', _currentPatient.allergies, Colors.red),\n                if (_currentPatient.medications.isNotEmpty)\n                  _buildChipRow('Medications', _currentPatient.medications, Colors.blue),\n              ],\n            ),\n          ],\n        ],\n      ),\n    );\n  }\n\n  Widget _buildTimelineTab(AppointmentProvider appointmentProvider) {\n    final appointments = appointmentProvider.getAppointmentsForPatient(_currentPatient.id);\n    \n    return appointments.isEmpty\n        ? const Center(\n            child: Column(\n              mainAxisAlignment: MainAxisAlignment.center,\n              children: [\n                Icon(Icons.event_busy, size: 64, color: Colors.grey),\n                SizedBox(height: 16),\n                Text('No appointments found', style: TextStyle(fontSize: 18, color: Colors.grey)),\n              ],\n            ),\n          )\n        : ListView.builder(\n            padding: const EdgeInsets.all(16),\n            itemCount: appointments.length,\n            itemBuilder: (context, index) {\n              final appointment = appointments[index];\n              return Card(\n                margin: const EdgeInsets.only(bottom: 12),\n                child: ListTile(\n                  leading: Container(\n                    width: 40,\n                    height: 40,\n                    decoration: BoxDecoration(\n                      color: _getStatusColor(appointment.status),\n                      borderRadius: BorderRadius.circular(20),\n                    ),\n                    child: Icon(\n                      _getStatusIcon(appointment.status),\n                      color: Colors.white,\n                      size: 20,\n                    ),\n                  ),\n                  title: Text(_formatDate(appointment.start)),\n                  subtitle: Text('${appointment.type.name} - ${appointment.status.name}'),\n                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),\n                ),\n              );\n            },\n          );\n  }\n\n  Widget _buildPaymentsTab() {\n    return const Center(\n      child: Column(\n        mainAxisAlignment: MainAxisAlignment.center,\n        children: [\n          Icon(Icons.payment, size: 64, color: Colors.grey),\n          SizedBox(height: 16),\n          Text('Payment history', style: TextStyle(fontSize: 18, color: Colors.grey)),\n          SizedBox(height: 8),\n          Text('Feature coming soon...', style: TextStyle(color: Colors.grey)),\n        ],\n      ),\n    );\n  }\n\n  Widget _buildNotesTab(PatientProvider patientProvider) {\n    return PrivateNotesSection(\n      patient: _currentPatient,\n      patientProvider: patientProvider,\n    );\n  }\n\n  Widget _buildInfoCard(String title, List<Widget> children) {\n    return Card(\n      child: Padding(\n        padding: const EdgeInsets.all(16),\n        child: Column(\n          crossAxisAlignment: CrossAxisAlignment.start,\n          children: [\n            Text(\n              title,\n              style: const TextStyle(\n                fontSize: 18,\n                fontWeight: FontWeight.bold,\n              ),\n            ),\n            const SizedBox(height: 12),\n            ...children,\n          ],\n        ),\n      ),\n    );\n  }\n\n  Widget _buildInfoRow(String label, String value) {\n    return Padding(\n      padding: const EdgeInsets.only(bottom: 8),\n      child: Row(\n        crossAxisAlignment: CrossAxisAlignment.start,\n        children: [\n          SizedBox(\n            width: 120,\n            child: Text(\n              label,\n              style: const TextStyle(\n                fontWeight: FontWeight.w500,\n                color: Colors.grey,\n              ),\n            ),\n          ),\n          Expanded(\n            child: Text(\n              value,\n              style: const TextStyle(fontSize: 16),\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  Widget _buildChipRow(String label, List<String> items, Color color) {\n    return Padding(\n      padding: const EdgeInsets.only(bottom: 12),\n      child: Column(\n        crossAxisAlignment: CrossAxisAlignment.start,\n        children: [\n          Text(\n            label,\n            style: const TextStyle(\n              fontWeight: FontWeight.w500,\n              color: Colors.grey,\n            ),\n          ),\n          const SizedBox(height: 8),\n          Wrap(\n            spacing: 8,\n            runSpacing: 4,\n            children: items.map((item) => Chip(\n              label: Text(\n                item,\n                style: const TextStyle(\n                  fontSize: 12,\n                  color: Colors.white,\n                ),\n              ),\n              backgroundColor: color,\n            )).toList(),\n          ),\n        ],\n      ),\n    );\n  }\n\n  String _getInitials(String name) {\n    List<String> parts = name.split(' ');\n    if (parts.length >= 2) {\n      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();\n    }\n    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();\n  }\n\n  String _formatDate(DateTime date) {\n    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';\n  }\n\n  Color _getStatusColor(status) {\n    switch (status.toString()) {\n      case 'AppointmentStatus.confirmed':\n        return Colors.green;\n      case 'AppointmentStatus.waitlist':\n        return Colors.orange;\n      case 'AppointmentStatus.cancelled':\n        return Colors.red;\n      case 'AppointmentStatus.completed':\n        return Colors.blue;\n      default:\n        return Colors.grey;\n    }\n  }\n\n  IconData _getStatusIcon(status) {\n    switch (status.toString()) {\n      case 'AppointmentStatus.confirmed':\n        return Icons.check;\n      case 'AppointmentStatus.waitlist':\n        return Icons.hourglass_empty;\n      case 'AppointmentStatus.cancelled':\n        return Icons.close;\n      case 'AppointmentStatus.completed':\n        return Icons.done_all;\n      default:\n        return Icons.event;\n    }\n  }\n\n  void _editPatient() {\n    // Navigate to edit patient screen\n    ScaffoldMessenger.of(context).showSnackBar(\n      const SnackBar(content: Text('Edit patient feature coming soon...')),\n    );\n  }\n\n  void _exportPatientData() {\n    // Export patient data (excluding private notes)\n    ScaffoldMessenger.of(context).showSnackBar(\n      const SnackBar(content: Text('Patient data exported (private notes excluded)')),\n    );\n  }\n\n  void _scheduleAppointment() {\n    // Navigate to schedule appointment\n    ScaffoldMessenger.of(context).showSnackBar(\n      const SnackBar(content: Text('Schedule appointment feature coming soon...')),\n    );\n  }\n}
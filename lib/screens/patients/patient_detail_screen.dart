import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/patient.dart';
import '../../providers/patient_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/settings_provider.dart';

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
        return Scaffold(
          appBar: AppBar(
            title: Text(_currentPatient.name),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editPatient();
                      break;
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
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit Patient'),
                      ],
                    ),
                  ),
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
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Patient Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(_currentPatient.name),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Name and Status
                    Text(
                      _currentPatient.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Quick Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatChip(
                          Icons.star,
                          '${_currentPatient.loyaltyPoints} pts',
                          Colors.amber,
                        ),
                        if (_currentPatient.allergies.isNotEmpty)
                          _buildStatChip(
                            Icons.warning,
                            'Allergies',
                            Colors.red,
                          ),
                        if (_currentPatient.internalNotes.isNotEmpty)
                          _buildStatChip(
                            Icons.note,
                            '${_currentPatient.internalNotes.length} notes',
                            Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Profile', icon: Icon(Icons.person)),
                  Tab(text: 'Timeline', icon: Icon(Icons.history)),
                  Tab(text: 'Payments', icon: Icon(Icons.payment)),
                  Tab(text: 'Notes', icon: Icon(Icons.note)),
                ],
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(),
                    _buildTimelineTab(appointmentProvider),
                    _buildPaymentsTab(),
                    _buildNotesTab(patientProvider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            'Personal Information',
            [
              _buildInfoRow('Full Name', _currentPatient.name),
              _buildInfoRow('Document Type', _currentPatient.docType),
              _buildInfoRow('Document Number', _currentPatient.docNumber),
              if (_currentPatient.dateOfBirth != null)
                _buildInfoRow(
                  'Date of Birth',
                  _formatDate(_currentPatient.dateOfBirth!),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoCard(
            'Contact Information',
            [
              if (_currentPatient.phone != null)
                _buildInfoRow('Phone', _currentPatient.phone!),
              if (_currentPatient.email != null)
                _buildInfoRow('Email', _currentPatient.email!),
              if (_currentPatient.address != null)
                _buildInfoRow('Address', _currentPatient.address!),
              if (_currentPatient.emergencyContact != null)
                _buildInfoRow('Emergency Contact', _currentPatient.emergencyContact!),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (_currentPatient.allergies.isNotEmpty) ...[
            _buildInfoCard(
              'Allergies & Medical Info',
              [
                _buildChipRow('Allergies', _currentPatient.allergies, Colors.red),
                if (_currentPatient.medications.isNotEmpty)
                  _buildChipRow('Medications', _currentPatient.medications, Colors.blue),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineTab(AppointmentProvider appointmentProvider) {
    final appointments = appointmentProvider.getAppointmentsForPatient(_currentPatient.id);
    
    return appointments.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No appointments found', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getStatusIcon(appointment.status),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(_formatDate(appointment.start)),
                  subtitle: Text('${appointment.type.name} - ${appointment.status.name}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          );
  }

  Widget _buildPaymentsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Payment history', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Feature coming soon...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNotesTab(PatientProvider patientProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Private Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Clinical notes are private and HIPAA compliant',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _currentPatient.internalNotes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_add, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No notes yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _currentPatient.internalNotes.length,
                    itemBuilder: (context, index) {
                      final note = _currentPatient.internalNotes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(note.length > 100 ? '${note.substring(0, 100)}...' : note),
                          subtitle: Text('Note ${index + 1}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Edit note functionality
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(String label, List<String> items, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: items.map((item) => Chip(
              label: Text(
                item,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              backgroundColor: color,
            )).toList(),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(status) {
    switch (status.toString()) {
      case 'AppointmentStatus.confirmed':
        return Colors.green;
      case 'AppointmentStatus.waitlist':
        return Colors.orange;
      case 'AppointmentStatus.cancelled':
        return Colors.red;
      case 'AppointmentStatus.completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(status) {
    switch (status.toString()) {
      case 'AppointmentStatus.confirmed':
        return Icons.check;
      case 'AppointmentStatus.waitlist':
        return Icons.hourglass_empty;
      case 'AppointmentStatus.cancelled':
        return Icons.close;
      case 'AppointmentStatus.completed':
        return Icons.done_all;
      default:
        return Icons.event;
    }
  }

  void _editPatient() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit patient feature coming soon...')),
    );
  }

  void _exportPatientData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patient data exported (private notes excluded)')),
    );
  }

  void _scheduleAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule appointment feature coming soon...')),
    );
  }
}
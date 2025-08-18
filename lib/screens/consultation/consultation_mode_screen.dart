import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../widgets/pain_map_widget.dart';
import '../../widgets/consultation_timer.dart';
import '../../widgets/dnd_banner.dart';
import '../consent/consent_recording_screen.dart';

class ConsultationModeScreen extends StatefulWidget {
  final Appointment appointment;
  final Patient patient;

  const ConsultationModeScreen({
    super.key,
    required this.appointment,
    required this.patient,
  });

  @override
  State<ConsultationModeScreen> createState() => _ConsultationModeScreenState();
}

class _ConsultationModeScreenState extends State<ConsultationModeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();
  
  Timer? _timer;
  Duration _sessionDuration = Duration.zero;
  bool _isSessionActive = false;
  Map<String, int> _painScores = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startSession();
    
    // Load existing private notes
    if (widget.appointment.privateNotes != null) {
      _notesController.text = widget.appointment.privateNotes!;
    }
    
    // Load existing pain scores
    if (widget.appointment.painMapScores != null) {
      _painScores = Map.from(widget.appointment.painMapScores!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
    });
    
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    appointmentProvider.startConsultation();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isSessionActive) {
        setState(() {
          _sessionDuration = Duration(seconds: _sessionDuration.inSeconds + 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _endSession() async {
    setState(() {
      _isSessionActive = false;
    });
    
    _timer?.cancel();
    
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    appointmentProvider.endConsultation();
    
    // Save consultation data
    await _saveConsultationData();
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveConsultationData() async {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    // Save private notes
    if (_notesController.text.trim().isNotEmpty) {
      await appointmentProvider.addPrivateNotes(
        widget.appointment.id,
        _notesController.text.trim(),
      );
    }
    
    // Save pain map scores
    if (_painScores.isNotEmpty) {
      await appointmentProvider.updatePainMapScores(
        widget.appointment.id,
        _painScores,
      );
    }
  }

  void _onPainScoreChanged(String region, int score) {
    setState(() {
      if (score > 0) {
        _painScores[region] = score;
      } else {
        _painScores.remove(region);
      }
    });
  }

  void _openConsentRecording() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsentRecordingScreen(
          appointment: widget.appointment,
          patient: widget.patient,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSessionActive) {
          final shouldEnd = await _showEndSessionDialog();
          if (shouldEnd == true) {
            _endSession();
            return true;
          }
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            // Do Not Disturb Banner
            const DNDBanner(),
            
            // Session Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Back Button\n                        IconButton(\n                          icon: const Icon(Icons.arrow_back, color: Colors.white),\n                          onPressed: () => _showEndSessionDialog().then((result) {\n                            if (result == true) _endSession();\n                          }),\n                        ),\n                        \n                        // Patient Info\n                        Expanded(\n                          child: Column(\n                            crossAxisAlignment: CrossAxisAlignment.start,\n                            children: [\n                              Text(\n                                'In Consultation',\n                                style: const TextStyle(\n                                  color: Colors.white,\n                                  fontSize: 14,\n                                  fontWeight: FontWeight.w500,\n                                ),\n                              ),\n                              Text(\n                                widget.patient.name,\n                                style: const TextStyle(\n                                  color: Colors.white,\n                                  fontSize: 18,\n                                  fontWeight: FontWeight.bold,\n                                ),\n                              ),\n                            ],\n                          ),\n                        ),\n                        \n                        // Timer\n                        ConsultationTimer(\n                          duration: _sessionDuration,\n                          isActive: _isSessionActive,\n                        ),\n                      ],\n                    ),\n                    \n                    const SizedBox(height: 16),\n                    \n                    // Quick Patient Info\n                    Container(\n                      padding: const EdgeInsets.all(12),\n                      decoration: BoxDecoration(\n                        color: Colors.white.withOpacity(0.1),\n                        borderRadius: BorderRadius.circular(8),\n                      ),\n                      child: Row(\n                        children: [\n                          const Icon(Icons.info_outline, color: Colors.white, size: 16),\n                          const SizedBox(width: 8),\n                          Expanded(\n                            child: Text(\n                              'Allergies: ${widget.patient.allergies.isEmpty ? \"None\" : widget.patient.allergies.join(\", \")}',\n                              style: const TextStyle(\n                                color: Colors.white,\n                                fontSize: 12,\n                              ),\n                            ),\n                          ),\n                        ],\n                      ),\n                    ),\n                  ],\n                ),\n              ),\n            ),\n            \n            // Tab Bar\n            TabBar(\n              controller: _tabController,\n              tabs: const [\n                Tab(text: 'Essentials', icon: Icon(Icons.medical_services)),\n                Tab(text: 'Pain Map', icon: Icon(Icons.accessibility_new)),\n                Tab(text: 'Notes', icon: Icon(Icons.note_add)),\n              ],\n            ),\n            \n            // Tab Content\n            Expanded(\n              child: TabBarView(\n                controller: _tabController,\n                children: [\n                  _buildEssentialsTab(),\n                  _buildPainMapTab(),\n                  _buildNotesTab(),\n                ],\n              ),\n            ),\n            \n            // Action Bar\n            Container(\n              padding: const EdgeInsets.all(16),\n              decoration: BoxDecoration(\n                color: Theme.of(context).cardColor,\n                boxShadow: [\n                  BoxShadow(\n                    color: Colors.black.withOpacity(0.1),\n                    blurRadius: 4,\n                    offset: const Offset(0, -2),\n                  ),\n                ],\n              ),\n              child: Row(\n                children: [\n                  Expanded(\n                    child: OutlinedButton.icon(\n                      onPressed: _saveConsultationData,\n                      icon: const Icon(Icons.save),\n                      label: const Text('Save Progress'),\n                    ),\n                  ),\n                  const SizedBox(width: 16),\n                  Expanded(\n                    child: ElevatedButton.icon(\n                      onPressed: () => _showEndSessionDialog().then((result) {\n                        if (result == true) _endSession();\n                      }),\n                      icon: const Icon(Icons.stop),\n                      label: const Text('End Session'),\n                      style: ElevatedButton.styleFrom(\n                        backgroundColor: Colors.red,\n                        foregroundColor: Colors.white,\n                      ),\n                    ),\n                  ),\n                ],\n              ),\n            ),\n          ],\n        ),\n      ),\n    );\n  }\n\n  Widget _buildEssentialsTab() {\n    return SingleChildScrollView(\n      padding: const EdgeInsets.all(16),\n      child: Column(\n        crossAxisAlignment: CrossAxisAlignment.start,\n        children: [\n          // Patient Overview Card\n          Card(\n            child: Padding(\n              padding: const EdgeInsets.all(16),\n              child: Column(\n                crossAxisAlignment: CrossAxisAlignment.start,\n                children: [\n                  const Text(\n                    'Patient Overview',\n                    style: TextStyle(\n                      fontSize: 18,\n                      fontWeight: FontWeight.bold,\n                    ),\n                  ),\n                  const SizedBox(height: 12),\n                  _buildInfoRow('Age', _calculateAge(widget.patient.dateOfBirth)),\n                  _buildInfoRow('Phone', widget.patient.phone ?? 'Not provided'),\n                  _buildInfoRow('Last Visit', 'March 10, 2024'), // Mock data\n                  _buildInfoRow('Loyalty Points', widget.patient.loyaltyPoints.toString()),\n                ],\n              ),\n            ),\n          ),\n          \n          const SizedBox(height: 16),\n          \n          // Medical Alerts Card\n          if (widget.patient.allergies.isNotEmpty || widget.patient.medications.isNotEmpty)\n            Card(\n              color: Colors.orange.withOpacity(0.1),\n              child: Padding(\n                padding: const EdgeInsets.all(16),\n                child: Column(\n                  crossAxisAlignment: CrossAxisAlignment.start,\n                  children: [\n                    Row(\n                      children: [\n                        const Icon(Icons.warning, color: Colors.orange),\n                        const SizedBox(width: 8),\n                        const Text(\n                          'Medical Alerts',\n                          style: TextStyle(\n                            fontSize: 18,\n                            fontWeight: FontWeight.bold,\n                            color: Colors.orange,\n                          ),\n                        ),\n                      ],\n                    ),\n                    const SizedBox(height: 12),\n                    \n                    if (widget.patient.allergies.isNotEmpty) ..[\n                      const Text(\n                        'Allergies:',\n                        style: TextStyle(\n                          fontWeight: FontWeight.w600,\n                          color: Colors.red,\n                        ),\n                      ),\n                      const SizedBox(height: 4),\n                      Wrap(\n                        spacing: 8,\n                        runSpacing: 4,\n                        children: widget.patient.allergies.map((allergy) => Chip(\n                          label: Text(allergy),\n                          backgroundColor: Colors.red.withOpacity(0.1),\n                          side: const BorderSide(color: Colors.red),\n                        )).toList(),\n                      ),\n                      const SizedBox(height: 12),\n                    ],\n                    \n                    if (widget.patient.medications.isNotEmpty) ..[\n                      const Text(\n                        'Current Medications:',\n                        style: TextStyle(\n                          fontWeight: FontWeight.w600,\n                          color: Colors.blue,\n                        ),\n                      ),\n                      const SizedBox(height: 4),\n                      Wrap(\n                        spacing: 8,\n                        runSpacing: 4,\n                        children: widget.patient.medications.map((medication) => Chip(\n                          label: Text(medication),\n                          backgroundColor: Colors.blue.withOpacity(0.1),\n                          side: const BorderSide(color: Colors.blue),\n                        )).toList(),\n                      ),\n                    ],\n                  ],\n                ),\n              ),\n            ),\n          \n          const SizedBox(height: 16),\n          \n          // Recent Procedures Card\n          Card(\n            child: Padding(\n              padding: const EdgeInsets.all(16),\n              child: Column(\n                crossAxisAlignment: CrossAxisAlignment.start,\n                children: [\n                  const Text(\n                    'Recent Procedures',\n                    style: TextStyle(\n                      fontSize: 18,\n                      fontWeight: FontWeight.bold,\n                    ),\n                  ),\n                  const SizedBox(height: 12),\n                  // Mock recent procedures\n                  _buildProcedureItem('Botox Treatment', 'March 10, 2024', 'Dr. Ana Silva'),\n                  _buildProcedureItem('Facial Cleaning', 'February 15, 2024', 'Dr. Ana Silva'),\n                  _buildProcedureItem('Consultation', 'January 20, 2024', 'Dr. Ana Silva'),\n                ],\n              ),\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  Widget _buildPainMapTab() {\n    return Column(\n      children: [\n        // Instructions\n        Container(\n          width: double.infinity,\n          padding: const EdgeInsets.all(16),\n          margin: const EdgeInsets.all(16),\n          decoration: BoxDecoration(\n            color: Colors.blue.withOpacity(0.1),\n            borderRadius: BorderRadius.circular(8),\n            border: Border.all(color: Colors.blue.withOpacity(0.3)),\n          ),\n          child: Column(\n            children: [\n              const Row(\n                children: [\n                  Icon(Icons.info, color: Colors.blue),\n                  SizedBox(width: 8),\n                  Text(\n                    'Interactive Pain Mapping',\n                    style: TextStyle(\n                      fontWeight: FontWeight.bold,\n                      color: Colors.blue,\n                    ),\n                  ),\n                ],\n              ),\n              const SizedBox(height: 8),\n              const Text(\n                'Tap on body regions to record pain levels (0-10 scale).',\n                style: TextStyle(fontSize: 14),\n              ),\n              const SizedBox(height: 8),\n              // Pain Scale Legend\n              Row(\n                mainAxisAlignment: MainAxisAlignment.spaceEvenly,\n                children: [\n                  _buildPainLegend('No Pain', 0, Colors.green),\n                  _buildPainLegend('Mild', 3, Colors.yellow),\n                  _buildPainLegend('Moderate', 6, Colors.orange),\n                  _buildPainLegend('Severe', 9, Colors.red),\n                ],\n              ),\n            ],\n          ),\n        ),\n        \n        // Pain Map Widget\n        Expanded(\n          child: PainMapWidget(\n            painScores: _painScores,\n            onScoreChanged: _onPainScoreChanged,\n          ),\n        ),\n        \n        // Pain Summary\n        if (_painScores.isNotEmpty)\n          Container(\n            padding: const EdgeInsets.all(16),\n            margin: const EdgeInsets.all(16),\n            decoration: BoxDecoration(\n              color: Theme.of(context).cardColor,\n              borderRadius: BorderRadius.circular(8),\n              boxShadow: [\n                BoxShadow(\n                  color: Colors.black.withOpacity(0.1),\n                  blurRadius: 4,\n                  offset: const Offset(0, 2),\n                ),\n              ],\n            ),\n            child: Column(\n              crossAxisAlignment: CrossAxisAlignment.start,\n              children: [\n                const Text(\n                  'Pain Summary',\n                  style: TextStyle(\n                    fontSize: 16,\n                    fontWeight: FontWeight.bold,\n                  ),\n                ),\n                const SizedBox(height: 8),\n                Wrap(\n                  spacing: 8,\n                  runSpacing: 4,\n                  children: _painScores.entries.map((entry) {\n                    final color = _getPainColor(entry.value);\n                    return Chip(\n                      label: Text(\n                        '${entry.key}: ${entry.value}/10',\n                        style: const TextStyle(color: Colors.white, fontSize: 12),\n                      ),\n                      backgroundColor: color,\n                    );\n                  }).toList(),\n                ),\n                const SizedBox(height: 8),\n                Text(\n                  'Max Pain Level: ${_painScores.values.isEmpty ? 0 : _painScores.values.reduce((a, b) => a > b ? a : b)}/10',\n                  style: const TextStyle(\n                    fontWeight: FontWeight.w600,\n                  ),\n                ),\n              ],\n            ),\n          ),\n      ],\n    );\n  }\n\n  Widget _buildNotesTab() {\n    return Padding(\n      padding: const EdgeInsets.all(16),\n      child: Column(\n        children: [\n          // Private Notes Warning\n          Container(\n            width: double.infinity,\n            padding: const EdgeInsets.all(12),\n            decoration: BoxDecoration(\n              color: Colors.orange.withOpacity(0.1),\n              borderRadius: BorderRadius.circular(8),\n              border: Border.all(color: Colors.orange.withOpacity(0.3)),\n            ),\n            child: Row(\n              children: [\n                const Icon(Icons.lock, color: Colors.orange),\n                const SizedBox(width: 8),\n                const Expanded(\n                  child: Text(\n                    'Private Clinical Notes (Not included in exports)',\n                    style: TextStyle(\n                      fontWeight: FontWeight.w600,\n                      color: Colors.orange,\n                    ),\n                  ),\n                ),\n              ],\n            ),\n          ),\n          \n          const SizedBox(height: 16),\n          \n          // Notes Text Field\n          Expanded(\n            child: TextField(\n              controller: _notesController,\n              maxLines: null,\n              expands: true,\n              textAlignVertical: TextAlignVertical.top,\n              decoration: const InputDecoration(\n                hintText: 'Enter private clinical notes here...\\n\\n• Observations\\n• Treatment notes\\n• Patient responses\\n• Follow-up recommendations',\n                border: OutlineInputBorder(),\n                alignLabelWithHint: true,\n              ),\n            ),\n          ),\n          \n          const SizedBox(height: 16),\n          \n          // Voice Input Button (Mock)\n          SizedBox(\n            width: double.infinity,\n            child: OutlinedButton.icon(\n              onPressed: () {\n                ScaffoldMessenger.of(context).showSnackBar(\n                  const SnackBar(\n                    content: Text('Voice input feature coming soon...'),\n                  ),\n                );\n              },\n              icon: const Icon(Icons.mic),\n              label: const Text('Voice Input'),\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  Widget _buildInfoRow(String label, String value) {\n    return Padding(\n      padding: const EdgeInsets.only(bottom: 8),\n      child: Row(\n        children: [\n          SizedBox(\n            width: 100,\n            child: Text(\n              label,\n              style: TextStyle(\n                fontWeight: FontWeight.w500,\n                color: Colors.grey[600],\n              ),\n            ),\n          ),\n          Text(value),\n        ],\n      ),\n    );\n  }\n\n  Widget _buildProcedureItem(String name, String date, String doctor) {\n    return Container(\n      padding: const EdgeInsets.symmetric(vertical: 8),\n      child: Row(\n        children: [\n          Container(\n            width: 8,\n            height: 8,\n            decoration: BoxDecoration(\n              color: Theme.of(context).primaryColor,\n              borderRadius: BorderRadius.circular(4),\n            ),\n          ),\n          const SizedBox(width: 12),\n          Expanded(\n            child: Column(\n              crossAxisAlignment: CrossAxisAlignment.start,\n              children: [\n                Text(\n                  name,\n                  style: const TextStyle(\n                    fontWeight: FontWeight.w600,\n                  ),\n                ),\n                Text(\n                  '$date • $doctor',\n                  style: TextStyle(\n                    fontSize: 12,\n                    color: Colors.grey[600],\n                  ),\n                ),\n              ],\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  Widget _buildPainLegend(String label, int value, Color color) {\n    return Column(\n      children: [\n        Container(\n          width: 16,\n          height: 16,\n          decoration: BoxDecoration(\n            color: color,\n            borderRadius: BorderRadius.circular(8),\n          ),\n        ),\n        const SizedBox(height: 4),\n        Text(\n          label,\n          style: const TextStyle(fontSize: 10),\n        ),\n        Text(\n          value.toString(),\n          style: const TextStyle(\n            fontSize: 10,\n            fontWeight: FontWeight.bold,\n          ),\n        ),\n      ],\n    );\n  }\n\n  Color _getPainColor(int score) {\n    if (score <= 2) return Colors.green;\n    if (score <= 4) return Colors.yellow;\n    if (score <= 6) return Colors.orange;\n    return Colors.red;\n  }\n\n  String _calculateAge(DateTime? dateOfBirth) {\n    if (dateOfBirth == null) return 'Unknown';\n    final now = DateTime.now();\n    final age = now.year - dateOfBirth.year;\n    if (now.month < dateOfBirth.month || \n        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {\n      return (age - 1).toString();\n    }\n    return age.toString();\n  }\n\n  Future<bool?> _showEndSessionDialog() {\n    return showDialog<bool>(\n      context: context,\n      builder: (context) => AlertDialog(\n        title: const Text('End Consultation'),\n        content: Column(\n          mainAxisSize: MainAxisSize.min,\n          crossAxisAlignment: CrossAxisAlignment.start,\n          children: [\n            const Text('Are you sure you want to end this consultation session?'),\n            const SizedBox(height: 12),\n            Text(\n              'Session Duration: ${_sessionDuration.inMinutes}:${(_sessionDuration.inSeconds % 60).toString().padLeft(2, '0')}',\n              style: const TextStyle(\n                fontWeight: FontWeight.w600,\n              ),\n            ),\n            const SizedBox(height: 8),\n            const Text(\n              'All data will be saved automatically.',\n              style: TextStyle(\n                fontSize: 12,\n                color: Colors.green,\n              ),\n            ),\n          ],\n        ),\n        actions: [\n          TextButton(\n            onPressed: () => Navigator.of(context).pop(false),\n            child: const Text('Continue Session'),\n          ),\n          ElevatedButton(\n            onPressed: () => Navigator.of(context).pop(true),\n            style: ElevatedButton.styleFrom(\n              backgroundColor: Colors.red,\n              foregroundColor: Colors.white,\n            ),\n            child: const Text('End Session'),\n          ),\n        ],\n      ),\n    );\n  }\n}
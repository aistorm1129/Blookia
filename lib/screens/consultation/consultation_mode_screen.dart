import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/patient.dart';
import '../../widgets/consultation_timer.dart';
import '../../widgets/dnd_banner.dart';
import '../../widgets/pain_map_widget.dart';

class ConsultationModeScreen extends StatefulWidget {
  final Patient patient;

  const ConsultationModeScreen({
    super.key,
    required this.patient,
  });

  @override
  State<ConsultationModeScreen> createState() => _ConsultationModeScreenState();
}

class _ConsultationModeScreenState extends State<ConsultationModeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _notesController;
  late Timer _sessionTimer;
  
  Duration _sessionDuration = Duration.zero;
  bool _isSessionActive = true;
  Map<String, int> _painScores = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _notesController = TextEditingController();
    _startSessionTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _sessionTimer.cancel();
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isSessionActive) {
        setState(() {
          _sessionDuration = Duration(seconds: _sessionDuration.inSeconds + 1);
        });
      }
    });
  }

  void _endSession() {
    setState(() {
      _isSessionActive = false;
    });
    _sessionTimer.cancel();
    _saveConsultationData();
    Navigator.of(context).pop();
  }

  void _saveConsultationData() {
    // Save consultation data logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consultation data saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onPainScoreChanged(String region, int score) {
    setState(() {
      _painScores[region] = score;
    });
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
            
            // Consultation Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Back Button
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => _showEndSessionDialog().then((result) {
                            if (result == true) _endSession();
                          }),
                        ),
                        
                        // Patient Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'In Consultation',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.patient.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Timer
                        ConsultationTimer(
                          duration: _sessionDuration,
                          isActive: _isSessionActive,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quick Patient Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Allergies: ${widget.patient.allergies.isEmpty ? "None" : widget.patient.allergies.join(", ")}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Essentials', icon: Icon(Icons.medical_services)),
                Tab(text: 'Pain Map', icon: Icon(Icons.accessibility_new)),
                Tab(text: 'Notes', icon: Icon(Icons.note_add)),
              ],
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEssentialsTab(),
                  _buildPainMapTab(),
                  _buildNotesTab(),
                ],
              ),
            ),
            
            // Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saveConsultationData,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Progress'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showEndSessionDialog().then((result) {
                        if (result == true) _endSession();
                      }),
                      icon: const Icon(Icons.stop),
                      label: const Text('End Session'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEssentialsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Overview Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Age', _calculateAge(widget.patient.dateOfBirth)),
                  _buildInfoRow('Phone', widget.patient.phone ?? 'Not provided'),
                  _buildInfoRow('Last Visit', 'March 10, 2024'), // Mock data
                  _buildInfoRow('Loyalty Points', widget.patient.loyaltyPoints.toString()),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Medical Alerts Card
          if (widget.patient.allergies.isNotEmpty || widget.patient.medications.isNotEmpty)
            Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Medical Alerts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (widget.patient.allergies.isNotEmpty) ...[
                      const Text(
                        'Allergies:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: widget.patient.allergies.map((allergy) => Chip(
                          label: Text(allergy),
                          backgroundColor: Colors.red.withOpacity(0.1),
                          side: const BorderSide(color: Colors.red),
                        )).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    if (widget.patient.medications.isNotEmpty) ...[
                      const Text(
                        'Current Medications:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: widget.patient.medications.map((medication) => Chip(
                          label: Text(medication),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          side: const BorderSide(color: Colors.blue),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Recent Procedures Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Procedures',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Mock recent procedures
                  _buildProcedureItem('Botox Treatment', 'March 10, 2024', 'Dr. Ana Silva'),
                  _buildProcedureItem('Facial Cleaning', 'February 15, 2024', 'Dr. Ana Silva'),
                  _buildProcedureItem('Consultation', 'January 20, 2024', 'Dr. Ana Silva'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPainMapTab() {
    return Column(
      children: [
        // Instructions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Interactive Pain Mapping',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap on body regions to record pain levels (0-10 scale).',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              // Pain Scale Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPainLegend('No Pain', 0, Colors.green),
                  _buildPainLegend('Mild', 3, Colors.yellow),
                  _buildPainLegend('Moderate', 6, Colors.orange),
                  _buildPainLegend('Severe', 9, Colors.red),
                ],
              ),
            ],
          ),
        ),
        
        // Pain Map Widget
        Expanded(
          child: PainMapWidget(
            painScores: _painScores,
            onScoreChanged: _onPainScoreChanged,
          ),
        ),
        
        // Pain Summary
        if (_painScores.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
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
                  'Pain Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _painScores.entries.map((entry) {
                    final color = _getPainColor(entry.value);
                    return Chip(
                      label: Text(
                        '${entry.key}: ${entry.value}/10',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: color,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Max Pain Level: ${_painScores.values.isEmpty ? 0 : _painScores.values.reduce((a, b) => a > b ? a : b)}/10',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Private Notes Warning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Private Clinical Notes (Not included in exports)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notes Text Field
          Expanded(
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Enter private clinical notes here...\n\n• Observations\n• Treatment notes\n• Patient responses\n• Follow-up recommendations',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Voice Input Button (Mock)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice input feature coming soon...'),
                  ),
                );
              },
              icon: const Icon(Icons.mic),
              label: const Text('Voice Input'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildProcedureItem(String name, String date, String doctor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$date • $doctor',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPainLegend(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getPainColor(int score) {
    if (score <= 2) return Colors.green;
    if (score <= 4) return Colors.yellow;
    if (score <= 6) return Colors.orange;
    return Colors.red;
  }

  String _calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 'Unknown';
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      return (age - 1).toString();
    }
    return age.toString();
  }

  Future<bool?> _showEndSessionDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Consultation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to end this consultation session?'),
            const SizedBox(height: 12),
            Text(
              'Session Duration: ${_sessionDuration.inMinutes}:${(_sessionDuration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'All data will be saved automatically.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue Session'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'dart:ui';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../models/transcript.dart';
import '../../widgets/consent_form_widget.dart';
import '../../widgets/recording_controls.dart';
import '../../widgets/transcript_editor.dart';

class ConsentRecordingScreen extends StatefulWidget {
  final Appointment appointment;
  final Patient patient;

  const ConsentRecordingScreen({
    super.key,
    required this.appointment,
    required this.patient,
  });

  @override
  State<ConsentRecordingScreen> createState() => _ConsentRecordingScreenState();
}

class _ConsentRecordingScreenState extends State<ConsentRecordingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _uuid = const Uuid();
  
  // Consent state
  bool _consentGiven = false;
  DateTime? _consentTimestamp;
  String _consentSignature = '';
  
  // Recording state
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _recordingPath;
  
  // Transcript state
  String _transcriptText = '';
  List<TranscriptVersion> _transcriptVersions = [];
  bool _isGeneratingTranscript = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load existing consent status
    _consentGiven = widget.appointment.consentGiven;
    
    // Lock tabs until consent is given
    _tabController.addListener(() {
      if (!_consentGiven && _tabController.index > 0) {
        _tabController.animateTo(0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please obtain patient consent first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;
    });
    
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      }
    });
    
    // Mock recording path
    _recordingPath = 'recordings/appointment_${widget.appointment.id}_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  void _pauseRecording() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
    
    _recordingTimer?.cancel();
    
    // Auto-generate transcript
    _generateTranscript();
  }

  void _generateTranscript() async {
    setState(() {
      _isGeneratingTranscript = true;
    });
    
    // Simulate transcript generation
    await Future.delayed(const Duration(seconds: 3));
    
    // Mock transcript text
    final mockTranscript = '''
Consultation Transcript
Date: ${DateTime.now().toString()}
Duration: ${_formatDuration(_recordingDuration)}
Participants: Dr. ${widget.appointment.professionalId}, ${widget.patient.name}

[00:00:00] Doctor: Good morning, ${widget.patient.name}. How are you feeling today?

[00:00:05] Patient: I'm doing well, thank you. I'm here for my scheduled consultation regarding the aesthetic treatment we discussed.

[00:00:12] Doctor: Excellent. Before we begin, I want to review the procedure we'll be discussing today. We'll be covering the treatment options, potential risks and benefits, and the expected recovery time.

[00:00:25] Patient: That sounds good. I've been thinking about this for a while and I have some questions.

[00:00:32] Doctor: Of course, I'm here to answer all your questions. Let's start with your main concerns.

[00:00:40] Patient: My primary concern is about the recovery time and any potential side effects.

[00:00:47] Doctor: That's a very important consideration. Let me explain the typical recovery process...

[Additional consultation details would continue here...]

[END OF TRANSCRIPT]
    ''';
    
    setState(() {
      _transcriptText = mockTranscript;
      _transcriptVersions = [
        TranscriptVersion(
          id: _uuid.v4(),
          text: mockTranscript,
          createdAt: DateTime.now(),
          editedBy: 'Auto-generated',
        ),
      ];
      _isGeneratingTranscript = false;
    });
    
    // Move to transcript tab
    _tabController.animateTo(2);
  }

  void _saveTranscriptVersion(String newText) {
    setState(() {
      _transcriptText = newText;
      _transcriptVersions.add(
        TranscriptVersion(
          id: _uuid.v4(),
          text: newText,
          createdAt: DateTime.now(),
          editedBy: 'Manual Edit',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consent & Recording'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(
                Icons.assignment,
                color: _consentGiven ? Colors.green : null,
              ),
              text: 'Consent',
            ),
            Tab(
              icon: Icon(
                Icons.mic,
                color: _isRecording ? Colors.red : null,
              ),
              text: 'Recording',
            ),
            Tab(
              icon: Icon(
                Icons.description,
                color: _transcriptText.isNotEmpty ? Colors.blue : null,
              ),
              text: 'Transcript',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: _consentGiven 
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        children: [
          _buildConsentTab(),
          _buildRecordingTab(),
          _buildTranscriptTab(),
        ],
      ),
    );
  }

  Widget _buildConsentTab() {
    return ConsentFormWidget(
      patient: widget.patient,
      appointment: widget.appointment,
      consentGiven: _consentGiven,
      onConsentChanged: (given, signature) {
        setState(() {
          _consentGiven = given;
          _consentTimestamp = given ? DateTime.now() : null;
          _consentSignature = signature;
        });
        
        if (given) {
          // Save consent to appointment
          final appointmentProvider = Provider.of<AppointmentProvider>(
            context,
            listen: false,
          );
          appointmentProvider.giveConsent(widget.appointment.id, true);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Consent obtained successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Move to recording tab
          _tabController.animateTo(1);
        }
      },
    );
  }

  Widget _buildRecordingTab() {
    return Column(
      children: [
        // Recording Status Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isRecording
                  ? [Colors.red, Colors.red.shade700]
                  : [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Icon(
                  _isRecording ? Icons.mic : Icons.mic_none,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  _isRecording
                      ? (_isPaused ? 'Recording Paused' : 'Recording...')
                      : 'Ready to Record',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(_recordingDuration),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Recording Info
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Legal Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Legal Recording Notice',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This recording is for medical documentation purposes. Patient consent has been obtained.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Session Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Session Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Patient', widget.patient.name),
                        _buildInfoRow('Date', _formatDate(DateTime.now())),
                        _buildInfoRow('Type', _getAppointmentType(widget.appointment.type)),
                        _buildInfoRow('Consent', _consentGiven ? '✅ Obtained' : '❌ Not Given'),
                        if (_consentTimestamp != null)
                          _buildInfoRow('Consent Time', _formatDateTime(_consentTimestamp!)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Audio Waveform Visualization (Mock)
                if (_isRecording)
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      painter: WaveformPainter(_isPaused),
                      child: Container(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Recording Controls
        RecordingControls(
          isRecording: _isRecording,
          isPaused: _isPaused,
          onStart: _startRecording,
          onPause: _pauseRecording,
          onStop: _stopRecording,
        ),
      ],
    );
  }

  Widget _buildTranscriptTab() {
    if (_isGeneratingTranscript) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Generating Transcript...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Using AI to transcribe audio',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    if (_transcriptText.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Transcript Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Record audio to generate transcript',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            if (_recordingPath != null)
              ElevatedButton.icon(
                onPressed: _generateTranscript,
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate Transcript'),
              ),
          ],
        ),
      );
    }
    
    return TranscriptEditor(
      transcriptText: _transcriptText,
      versions: _transcriptVersions,
      recordingDuration: _recordingDuration,
      onSave: _saveTranscriptVersion,
      onExport: () => _exportTranscript(context),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getAppointmentType(AppointmentType type) {
    switch (type) {
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.procedure:
        return 'Procedure';
      case AppointmentType.followUp:
        return 'Follow-up';
      case AppointmentType.emergency:
        return 'Emergency';
    }
  }

  void _exportTranscript(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📄 Transcript exported to PDF successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Mock waveform painter for visual effect
class WaveformPainter extends CustomPainter {
  final bool isPaused;
  
  WaveformPainter(this.isPaused);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isPaused ? Colors.grey : Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final amplitude = size.height / 2;
    final frequency = 0.02;
    
    path.moveTo(0, size.height / 2);
    
    for (double x = 0; x < size.width; x++) {
      final y = size.height / 2 + amplitude * (x / size.width) * 
          (isPaused ? 0.2 : 1.0) * 
          (0.5 + 0.5 * (x.hashCode % 100) / 100);
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
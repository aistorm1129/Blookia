import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/ai_assistant_fab.dart';
import 'package:uuid/uuid.dart';

class TeleconsultScreen extends StatefulWidget {
  final Appointment appointment;
  final Patient patient;

  const TeleconsultScreen({
    super.key,
    required this.appointment,
    required this.patient,
  });

  @override
  State<TeleconsultScreen> createState() => _TeleconsultScreenState();
}

class _TeleconsultScreenState extends State<TeleconsultScreen>
    with TickerProviderStateMixin {
  late AnimationController _connectionAnimationController;
  late Animation<double> _connectionAnimation;
  late TabController _tabController;
  
  TeleconsultStatus _status = TeleconsultStatus.preparing;
  Duration _sessionDuration = Duration.zero;
  Timer? _sessionTimer;
  bool _isMuted = false;
  bool _isCameraOff = false;
  String _connectionQuality = 'Excellent';
  final List<TeleconsultMessage> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  
  // Pre-call checklist
  final Map<String, bool> _checklist = {
    'Patient identity verified': false,
    'Technical requirements met': false,
    'Privacy ensured': false,
    'Emergency contact available': false,
    'Consent obtained': false,
  };

  @override
  void initState() {
    super.initState();
    
    _connectionAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _connectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_connectionAnimationController);
    
    _tabController = TabController(length: 3, vsync: this);
    
    _connectionAnimationController.repeat();
    _initializeTeleconsult();
  }

  @override
  void dispose() {
    _connectionAnimationController.dispose();
    _tabController.dispose();
    _sessionTimer?.cancel();
    _chatController.dispose();
    super.dispose();
  }

  void _initializeTeleconsult() {
    // Simulate initialization process
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _status = TeleconsultStatus.readyToStart;
        });
        _connectionAnimationController.stop();
      }
    });
  }

  void _startSession() {
    if (!_allChecklistComplete()) {
      _showChecklistIncompleteDialog();
      return;
    }

    setState(() {
      _status = TeleconsultStatus.connecting;
    });
    
    _connectionAnimationController.repeat();
    
    // Simulate connection process
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _status = TeleconsultStatus.connected;
          _sessionDuration = Duration.zero;
        });
        _connectionAnimationController.stop();
        _startSessionTimer();
      }
    });
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_status == TeleconsultStatus.connected) {
        setState(() {
          _sessionDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  void _endSession() {
    setState(() {
      _status = TeleconsultStatus.ended;
    });
    _sessionTimer?.cancel();
    
    // Update appointment status
    Provider.of<AppointmentProvider>(context, listen: false)
        .completeAppointment(widget.appointment.id);
    
    _showSessionSummaryDialog();
  }

  bool _allChecklistComplete() {
    return _checklist.values.every((checked) => checked);
  }

  void _showChecklistIncompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pre-Call Checklist Incomplete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please complete all checklist items before starting the teleconsult:'),
            const SizedBox(height: 12),
            ..._checklist.entries.where((entry) => !entry.value).map((entry) => 
              Text('• ${entry.key}', style: const TextStyle(color: Colors.red))
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSessionSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session Duration: ${_formatDuration(_sessionDuration)}'),
            Text('Patient: ${widget.patient.name}'),
            Text('Connection Quality: $_connectionQuality'),
            const SizedBox(height: 16),
            const Text('Session notes and recordings have been saved to the patient record.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to patient record or generate report
            },
            child: const Text('View Summary'),
          ),
        ],
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
  }

  void _sendChatMessage(String message) {
    if (message.trim().isEmpty) return;
    
    final chatMessage = TeleconsultMessage(
      id: const Uuid().v4(),
      content: message,
      senderName: 'You', // In real app, use current user name
      timestamp: DateTime.now(),
      isFromProvider: true,
    );
    
    setState(() {
      _chatMessages.add(chatMessage);
    });
    
    _chatController.clear();
    
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Scroll logic would go here
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teleconsult'),
        actions: [
          if (_status == TeleconsultStatus.connected) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, color: Colors.white, size: 8),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(_sessionDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: AIAssistantFAB(
        context: 'consultation',
        patient: widget.patient,
        appointment: widget.appointment,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case TeleconsultStatus.preparing:
        return _buildPreparingScreen();
      case TeleconsultStatus.readyToStart:
        return _buildPreCallChecklist();
      case TeleconsultStatus.connecting:
        return _buildConnectingScreen();
      case TeleconsultStatus.connected:
        return _buildActiveSession();
      case TeleconsultStatus.ended:
        return _buildSessionEndedScreen();
    }
  }

  Widget _buildPreparingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _connectionAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _connectionAnimation.value * 2 * 3.14159,
                child: const Icon(
                  Icons.video_call,
                  size: 64,
                  color: Colors.blue,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Preparing Teleconsult',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text('Initializing secure connection...'),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildPreCallChecklist() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Name: ${widget.patient.name}'),
                  Text('Phone: ${widget.patient.phone ?? 'Not provided'}'),
                  Text('Appointment Type: ${_getAppointmentTypeString()}'),
                  Text('Scheduled: ${_formatDateTime(widget.appointment.start)}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Pre-Call Checklist
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pre-Call Checklist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._checklist.entries.map((entry) => CheckboxListTile(
                    title: Text(entry.key),
                    value: entry.value,
                    onChanged: (value) {
                      setState(() {
                        _checklist[entry.key] = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  )),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Technical Requirements
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Technical Requirements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRequirementItem(
                    icon: Icons.wifi,
                    label: 'Internet Connection',
                    status: 'Good (45 Mbps)',
                    isGood: true,
                  ),
                  _buildRequirementItem(
                    icon: Icons.videocam,
                    label: 'Camera',
                    status: 'Available',
                    isGood: true,
                  ),
                  _buildRequirementItem(
                    icon: Icons.mic,
                    label: 'Microphone',
                    status: 'Available',
                    isGood: true,
                  ),
                  _buildRequirementItem(
                    icon: Icons.speaker,
                    label: 'Audio Output',
                    status: 'Available',
                    isGood: true,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Start Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _allChecklistComplete() ? _startSession : null,
              icon: const Icon(Icons.video_call),
              label: const Text('Start Teleconsult'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _connectionAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_connectionAnimation.value * 0.4),
                child: const Icon(
                  Icons.connect_without_contact,
                  size: 64,
                  color: Colors.blue,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Connecting...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text('Establishing secure connection with ${widget.patient.name}'),
          const SizedBox(height: 24),
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _status = TeleconsultStatus.readyToStart;
              });
              _connectionAnimationController.stop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSession() {
    return Column(
      children: [
        // Video Area
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.black,
            child: Stack(
              children: [
                // Main video (patient)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.black87],
                    ),
                  ),
                  child: _isCameraOff 
                      ? _buildCameraOffView()
                      : _buildVideoView(isPatient: true),
                ),
                
                // PiP video (self)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: _buildVideoView(isPatient: false),
                  ),
                ),
                
                // Connection Quality Indicator
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.signal_wifi_4_bar,
                          color: _getConnectionColor(),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _connectionQuality,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Session Timer
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _formatDuration(_sessionDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Controls and Chat
        Expanded(
          flex: 1,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildControlsTab(),
              _buildChatTab(),
              _buildNotesTab(),
            ],
          ),
        ),
        
        // Tab Bar and End Button
        Container(
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Controls', icon: Icon(Icons.settings)),
                  Tab(text: 'Chat', icon: Icon(Icons.chat)),
                  Tab(text: 'Notes', icon: Icon(Icons.note_add)),
                ],
              ),
              
              // End Session Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _endSession,
                  icon: const Icon(Icons.call_end),
                  label: const Text('End Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                label: _isMuted ? 'Unmute' : 'Mute',
                onPressed: _toggleMute,
                isActive: !_isMuted,
              ),
              _buildControlButton(
                icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                label: _isCameraOff ? 'Camera On' : 'Camera Off',
                onPressed: _toggleCamera,
                isActive: !_isCameraOff,
              ),
              _buildControlButton(
                icon: Icons.screen_share,
                label: 'Share Screen',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Screen sharing started')),
                  );
                },
                isActive: false,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Additional Options
          ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: const Text('Record Session'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Implement recording toggle
              },
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.closed_caption),
            title: const Text('Live Captions'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Implement captions toggle
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        // Chat Messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final message = _chatMessages[index];
              return _buildChatMessage(message);
            },
          ),
        ),
        
        // Chat Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _sendChatMessage,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _sendChatMessage(_chatController.text),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Session Notes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Take notes during the session...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionEndedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            'Session Completed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text('Duration: ${_formatDuration(_sessionDuration)}'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Return to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem({
    required IconData icon,
    required String label,
    required String status,
    required bool isGood,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: isGood ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            status,
            style: TextStyle(
              color: isGood ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(32),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVideoView({required bool isPatient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.blue.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: isPatient ? 64 : 32,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              isPatient ? widget.patient.name : 'You',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraOffView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam_off,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.patient.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Camera is off',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(TeleconsultMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: message.isFromProvider ? Colors.blue : Colors.grey,
            child: Text(
              message.senderName[0],
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(message.content),
              ],
            ),
          ),
          Text(
            "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConnectionColor() {
    switch (_connectionQuality) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getAppointmentTypeString() {
    switch (widget.appointment.type) {
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

enum TeleconsultStatus {
  preparing,
  readyToStart,
  connecting,
  connected,
  ended,
}

class TeleconsultMessage {
  final String id;
  final String content;
  final String senderName;
  final DateTime timestamp;
  final bool isFromProvider;

  TeleconsultMessage({
    required this.id,
    required this.content,
    required this.senderName,
    required this.timestamp,
    required this.isFromProvider,
  });
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/appointment_provider.dart';
import '../../providers/patient_provider.dart';
import '../../models/appointment.dart';
import '../../models/waitlist_invite.dart';
import 'package:uuid/uuid.dart';

class WaitlistRecoveryScreen extends StatefulWidget {
  final Appointment cancelledAppointment;

  const WaitlistRecoveryScreen({
    super.key,
    required this.cancelledAppointment,
  });

  @override
  State<WaitlistRecoveryScreen> createState() => _WaitlistRecoveryScreenState();
}

class _WaitlistRecoveryScreenState extends State<WaitlistRecoveryScreen>
    with TickerProviderStateMixin {
  late AnimationController _countdownController;
  late AnimationController _pulseController;
  late Animation<double> _countdownAnimation;
  late Animation<double> _pulseAnimation;
  
  Timer? _countdownTimer;
  Duration _timeRemaining = const Duration(minutes: 10);
  bool _isActive = true;
  String? _acceptedPatientId;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    
    _countdownController = AnimationController(
      duration: const Duration(minutes: 10),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _countdownAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_countdownController);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));

    _startCountdown();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownController.forward();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isActive) {
        timer.cancel();
        return;
      }

      setState(() {
        _timeRemaining = _timeRemaining - const Duration(seconds: 1);
      });

      if (_timeRemaining.inSeconds <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    setState(() {
      _isActive = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏰ Waitlist offer expired'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _acceptSlot(String patientId, String patientName) {
    if (!_isActive || _acceptedPatientId != null) return;

    setState(() {
      _acceptedPatientId = patientId;
      _isActive = false;
    });

    _countdownTimer?.cancel();
    _pulseController.stop();

    // Award loyalty points
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    patientProvider.addLoyaltyPoints(patientId, 50);

    // Update appointment
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final updatedAppointment = Appointment(
      id: widget.cancelledAppointment.id,
      patientId: patientId,
      professionalId: widget.cancelledAppointment.professionalId,
      start: widget.cancelledAppointment.start,
      end: widget.cancelledAppointment.end,
      type: widget.cancelledAppointment.type,
      status: AppointmentStatus.confirmed,
      channel: widget.cancelledAppointment.channel,
      noShowRisk: appointmentProvider.calculateNoShowRisk(patientId),
      notes: 'Recovered from waitlist',
      createdAt: widget.cancelledAppointment.createdAt,
      updatedAt: DateTime.now(),
      durationMinutes: widget.cancelledAppointment.durationMinutes,
    );

    appointmentProvider.updateAppointment(updatedAppointment);

    // Show success animation
    _showSuccessDialog(patientName);
  }

  void _showSuccessDialog(String patientName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              '🎉 Slot Confirmed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '$patientName accepted the appointment slot!',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '+50 Loyalty Points Awarded',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close waitlist screen
            },
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppointmentProvider, PatientProvider>(
      builder: (context, appointmentProvider, patientProvider, _) {
        final waitlistPatients = _getWaitlistPatients(appointmentProvider, patientProvider);
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Waitlist Slot Recovery'),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.orange.withOpacity(0.1),
                  Colors.white,\n                ],\n              ),\n            ),\n            child: Column(\n              children: [\n                // Countdown Header\n                Container(\n                  width: double.infinity,\n                  padding: const EdgeInsets.all(20),\n                  child: Column(\n                    children: [\n                      const Text(\n                        '⏰ Slot Available!',\n                        style: TextStyle(\n                          fontSize: 24,\n                          fontWeight: FontWeight.bold,\n                        ),\n                      ),\n                      \n                      const SizedBox(height: 8),\n                      \n                      Text(\n                        '${_formatDateTime(widget.cancelledAppointment.start)} - ${_formatTime(widget.cancelledAppointment.end)}',\n                        style: const TextStyle(\n                          fontSize: 18,\n                          color: Colors.grey,\n                        ),\n                      ),\n                      \n                      const SizedBox(height: 20),\n                      \n                      // Countdown Circle\n                      AnimatedBuilder(\n                        animation: _countdownAnimation,\n                        builder: (context, child) {\n                          return AnimatedBuilder(\n                            animation: _pulseAnimation,\n                            builder: (context, child) {\n                              return Transform.scale(\n                                scale: _isActive ? _pulseAnimation.value : 1.0,\n                                child: SizedBox(\n                                  width: 120,\n                                  height: 120,\n                                  child: Stack(\n                                    children: [\n                                      // Background circle\n                                      Container(\n                                        width: 120,\n                                        height: 120,\n                                        decoration: BoxDecoration(\n                                          color: Colors.white,\n                                          borderRadius: BorderRadius.circular(60),\n                                          boxShadow: [\n                                            BoxShadow(\n                                              color: Colors.orange.withOpacity(0.3),\n                                              blurRadius: 20,\n                                              offset: const Offset(0, 5),\n                                            ),\n                                          ],\n                                        ),\n                                      ),\n                                      \n                                      // Progress indicator\n                                      SizedBox(\n                                        width: 120,\n                                        height: 120,\n                                        child: CircularProgressIndicator(\n                                          value: _isActive ? _countdownAnimation.value : 0,\n                                          strokeWidth: 8,\n                                          backgroundColor: Colors.grey.withOpacity(0.3),\n                                          valueColor: AlwaysStoppedAnimation(\n                                            _timeRemaining.inMinutes > 5\n                                                ? Colors.green\n                                                : _timeRemaining.inMinutes > 2\n                                                    ? Colors.orange\n                                                    : Colors.red,\n                                          ),\n                                        ),\n                                      ),\n                                      \n                                      // Time text\n                                      Center(\n                                        child: Column(\n                                          mainAxisAlignment: MainAxisAlignment.center,\n                                          children: [\n                                            Text(\n                                              _formatTimeRemaining(),\n                                              style: TextStyle(\n                                                fontSize: 20,\n                                                fontWeight: FontWeight.bold,\n                                                color: _timeRemaining.inMinutes > 2\n                                                    ? Colors.black\n                                                    : Colors.red,\n                                              ),\n                                            ),\n                                            Text(\n                                              _timeRemaining.inSeconds > 60 ? 'minutes' : 'seconds',\n                                              style: TextStyle(\n                                                fontSize: 12,\n                                                color: Colors.grey[600],\n                                              ),\n                                            ),\n                                          ],\n                                        ),\n                                      ),\n                                    ],\n                                  ),\n                                ),\n                              );\n                            },\n                          );\n                        },\n                      ),\n                      \n                      const SizedBox(height: 16),\n                      \n                      if (_acceptedPatientId == null && _isActive)\n                        const Text(\n                          'First to accept wins the slot!',\n                          style: TextStyle(\n                            fontSize: 16,\n                            fontWeight: FontWeight.w600,\n                            color: Colors.orange,\n                          ),\n                        )\n                      else if (_acceptedPatientId != null)\n                        const Text(\n                          '✅ Slot has been claimed!',\n                          style: TextStyle(\n                            fontSize: 16,\n                            fontWeight: FontWeight.w600,\n                            color: Colors.green,\n                          ),\n                        )\n                      else\n                        const Text(\n                          '⏰ Offer expired',\n                          style: TextStyle(\n                            fontSize: 16,\n                            fontWeight: FontWeight.w600,\n                            color: Colors.grey,\n                          ),\n                        ),\n                    ],\n                  ),\n                ),\n                \n                const SizedBox(height: 20),\n                \n                // Waitlist Patients\n                Expanded(\n                  child: waitlistPatients.isEmpty\n                      ? const Center(\n                          child: Column(\n                            mainAxisAlignment: MainAxisAlignment.center,\n                            children: [\n                              Icon(\n                                Icons.hourglass_empty,\n                                size: 64,\n                                color: Colors.grey,\n                              ),\n                              SizedBox(height: 16),\n                              Text(\n                                'No patients on waitlist',\n                                style: TextStyle(\n                                  fontSize: 18,\n                                  color: Colors.grey,\n                                ),\n                              ),\n                            ],\n                          ),\n                        )\n                      : ListView.builder(\n                          padding: const EdgeInsets.symmetric(horizontal: 20),\n                          itemCount: waitlistPatients.length,\n                          itemBuilder: (context, index) {\n                            final patient = waitlistPatients[index];\n                            final isWinner = _acceptedPatientId == patient.id;\n                            final canAccept = _isActive && _acceptedPatientId == null;\n                            \n                            return AnimatedContainer(\n                              duration: const Duration(milliseconds: 500),\n                              margin: const EdgeInsets.only(bottom: 12),\n                              child: Card(\n                                elevation: isWinner ? 8 : 2,\n                                color: isWinner ? Colors.green.withOpacity(0.1) : null,\n                                shape: RoundedRectangleBorder(\n                                  borderRadius: BorderRadius.circular(12),\n                                  side: BorderSide(\n                                    color: isWinner \n                                        ? Colors.green \n                                        : Colors.transparent,\n                                    width: 2,\n                                  ),\n                                ),\n                                child: Padding(\n                                  padding: const EdgeInsets.all(16),\n                                  child: Row(\n                                    children: [\n                                      // Patient Avatar\n                                      Container(\n                                        width: 50,\n                                        height: 50,\n                                        decoration: BoxDecoration(\n                                          color: isWinner \n                                              ? Colors.green \n                                              : Theme.of(context).primaryColor,\n                                          borderRadius: BorderRadius.circular(25),\n                                        ),\n                                        child: Center(\n                                          child: Text(\n                                            _getInitials(patient.name),\n                                            style: const TextStyle(\n                                              color: Colors.white,\n                                              fontWeight: FontWeight.bold,\n                                            ),\n                                          ),\n                                        ),\n                                      ),\n                                      \n                                      const SizedBox(width: 16),\n                                      \n                                      // Patient Info\n                                      Expanded(\n                                        child: Column(\n                                          crossAxisAlignment: CrossAxisAlignment.start,\n                                          children: [\n                                            Row(\n                                              children: [\n                                                Text(\n                                                  patient.name,\n                                                  style: const TextStyle(\n                                                    fontSize: 16,\n                                                    fontWeight: FontWeight.w600,\n                                                  ),\n                                                ),\n                                                if (patient.loyaltyPoints > 100) ..[\n                                                  const SizedBox(width: 8),\n                                                  Container(\n                                                    padding: const EdgeInsets.symmetric(\n                                                      horizontal: 6,\n                                                      vertical: 2,\n                                                    ),\n                                                    decoration: BoxDecoration(\n                                                      color: Colors.amber,\n                                                      borderRadius: BorderRadius.circular(10),\n                                                    ),\n                                                    child: const Text(\n                                                      'VIP',\n                                                      style: TextStyle(\n                                                        fontSize: 10,\n                                                        fontWeight: FontWeight.bold,\n                                                        color: Colors.white,\n                                                      ),\n                                                    ),\n                                                  ),\n                                                ],\n                                              ],\n                                            ),\n                                            const SizedBox(height: 4),\n                                            Row(\n                                              children: [\n                                                Icon(\n                                                  Icons.star,\n                                                  size: 16,\n                                                  color: Colors.amber[700],\n                                                ),\n                                                const SizedBox(width: 4),\n                                                Text(\n                                                  '${patient.loyaltyPoints} points',\n                                                  style: TextStyle(\n                                                    color: Colors.grey[600],\n                                                    fontSize: 12,\n                                                  ),\n                                                ),\n                                                if (patient.phone != null) ..[\n                                                  const SizedBox(width: 16),\n                                                  Icon(\n                                                    Icons.phone,\n                                                    size: 16,\n                                                    color: Colors.grey[500],\n                                                  ),\n                                                  const SizedBox(width: 4),\n                                                  Text(\n                                                    patient.phone!,\n                                                    style: TextStyle(\n                                                      color: Colors.grey[600],\n                                                      fontSize: 12,\n                                                    ),\n                                                  ),\n                                                ],\n                                              ],\n                                            ),\n                                          ],\n                                        ),\n                                      ),\n                                      \n                                      // Action Button\n                                      if (isWinner)\n                                        Container(\n                                          padding: const EdgeInsets.all(8),\n                                          decoration: BoxDecoration(\n                                            color: Colors.green,\n                                            borderRadius: BorderRadius.circular(20),\n                                          ),\n                                          child: const Icon(\n                                            Icons.check,\n                                            color: Colors.white,\n                                            size: 20,\n                                          ),\n                                        )\n                                      else if (canAccept)\n                                        ElevatedButton(\n                                          onPressed: () => _acceptSlot(patient.id, patient.name),\n                                          style: ElevatedButton.styleFrom(\n                                            backgroundColor: Colors.green,\n                                            foregroundColor: Colors.white,\n                                            shape: RoundedRectangleBorder(\n                                              borderRadius: BorderRadius.circular(20),\n                                            ),\n                                          ),\n                                          child: const Text('Accept'),\n                                        )\n                                      else\n                                        Container(\n                                          padding: const EdgeInsets.symmetric(\n                                            horizontal: 12,\n                                            vertical: 8,\n                                          ),\n                                          decoration: BoxDecoration(\n                                            color: Colors.grey.withOpacity(0.3),\n                                            borderRadius: BorderRadius.circular(20),\n                                          ),\n                                          child: const Text(\n                                            'Missed',\n                                            style: TextStyle(\n                                              color: Colors.grey,\n                                              fontSize: 12,\n                                            ),\n                                          ),\n                                        ),\n                                    ],\n                                  ),\n                                ),\n                              ),\n                            );\n                          },\n                        ),\n                ),\n              ],\n            ),\n          ),\n        );\n      },\n    );\n  }\n\n  List<dynamic> _getWaitlistPatients(AppointmentProvider appointmentProvider, PatientProvider patientProvider) {\n    // Get patients from waitlist appointments\n    final waitlistAppointments = appointmentProvider.waitlistAppointments;\n    final patients = <dynamic>[];\n    \n    for (final appointment in waitlistAppointments.take(5)) {\n      final patient = patientProvider.getPatientById(appointment.patientId);\n      if (patient != null) {\n        patients.add(patient);\n      }\n    }\n    \n    // Sort by loyalty points (VIP first)\n    patients.sort((a, b) => b.loyaltyPoints.compareTo(a.loyaltyPoints));\n    \n    return patients;\n  }\n\n  String _getInitials(String name) {\n    final parts = name.split(' ');\n    if (parts.length >= 2) {\n      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();\n    }\n    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();\n  }\n\n  String _formatDateTime(DateTime dateTime) {\n    return '${dateTime.day}/${dateTime.month} ${_formatTime(dateTime)}';\n  }\n\n  String _formatTime(DateTime dateTime) {\n    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';\n  }\n\n  String _formatTimeRemaining() {\n    if (_timeRemaining.inSeconds <= 0) return '0:00';\n    \n    if (_timeRemaining.inSeconds > 60) {\n      return '${_timeRemaining.inMinutes}:${(_timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}';\n    } else {\n      return _timeRemaining.inSeconds.toString();\n    }\n  }\n}
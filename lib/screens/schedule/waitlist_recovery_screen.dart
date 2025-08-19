import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/patient_provider.dart';

class WaitlistRecoveryScreen extends StatefulWidget {
  final Appointment cancelledAppointment;
  final Duration countdownDuration;

  const WaitlistRecoveryScreen({
    super.key,
    required this.cancelledAppointment,
    this.countdownDuration = const Duration(minutes: 15),
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
  late Timer _timer;
  
  Duration _timeRemaining = const Duration(minutes: 15);
  bool _isActive = true;
  String? _acceptedPatientId;

  @override
  void initState() {
    super.initState();
    
    _timeRemaining = widget.countdownDuration;
    
    _countdownController = AnimationController(
      duration: widget.countdownDuration,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _countdownAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_countdownController);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    _countdownController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownController.forward();
    _pulseController.repeat(reverse: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining.inSeconds > 0) {
          _timeRemaining = Duration(seconds: _timeRemaining.inSeconds - 1);
        } else {
          _isActive = false;
          timer.cancel();
          _pulseController.stop();
        }
      });
    });
  }

  void _acceptSlot(String patientId, String patientName) {
    setState(() {
      _acceptedPatientId = patientId;
      _isActive = false;
    });
    
    _timer.cancel();
    _pulseController.stop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Slot assigned to $patientName'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Here you would typically update the appointment in the provider
    // and send notifications to the patient
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
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              children: [
                // Countdown Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        '⏰ Slot Available!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        '${_formatDateTime(widget.cancelledAppointment.start)} - ${_formatTime(widget.cancelledAppointment.end)}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Countdown Circle
                      AnimatedBuilder(
                        animation: _countdownAnimation,
                        builder: (context, child) {
                          return AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isActive ? _pulseAnimation.value : 1.0,
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Stack(
                                    children: [
                                      // Background circle
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(60),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.orange.withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Progress indicator
                                      SizedBox(
                                        width: 120,
                                        height: 120,
                                        child: CircularProgressIndicator(
                                          value: _isActive ? _countdownAnimation.value : 0,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.grey.withOpacity(0.3),
                                          valueColor: AlwaysStoppedAnimation(
                                            _timeRemaining.inMinutes > 5
                                                ? Colors.green
                                                : _timeRemaining.inMinutes > 2
                                                    ? Colors.orange
                                                    : Colors.red,
                                          ),
                                        ),
                                      ),
                                      
                                      // Time text
                                      Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _formatTimeRemaining(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: _timeRemaining.inMinutes > 2
                                                    ? Colors.black
                                                    : Colors.red,
                                              ),
                                            ),
                                            Text(
                                              _timeRemaining.inSeconds > 60 ? 'minutes' : 'seconds',
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
                                ),
                              );
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      if (_acceptedPatientId == null && _isActive)
                        const Text(
                          'First to accept wins the slot!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        )
                      else if (_acceptedPatientId != null)
                        const Text(
                          '✅ Slot has been claimed!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        )
                      else
                        const Text(
                          '⏰ Offer expired',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Waitlist Patients
                Expanded(
                  child: waitlistPatients.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hourglass_empty,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No patients on waitlist',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: waitlistPatients.length,
                          itemBuilder: (context, index) {
                            final patient = waitlistPatients[index];
                            final isWinner = _acceptedPatientId == patient.id;
                            final canAccept = _isActive && _acceptedPatientId == null;
                            
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                elevation: isWinner ? 8 : 2,
                                color: isWinner ? Colors.green.withOpacity(0.1) : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isWinner 
                                        ? Colors.green 
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Patient Avatar
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: isWinner 
                                              ? Colors.green 
                                              : Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _getInitials(patient.name),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 16),
                                      
                                      // Patient Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  patient.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if (patient.loyaltyPoints > 100) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: const Text(
                                                      'VIP',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.amber[700],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${patient.loyaltyPoints} points',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                if (patient.phone != null) ...[
                                                  const SizedBox(width: 16),
                                                  Icon(
                                                    Icons.phone,
                                                    size: 16,
                                                    color: Colors.grey[500],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    patient.phone!,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Action Button
                                      if (isWinner)
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        )
                                      else if (canAccept)
                                        ElevatedButton(
                                          onPressed: () => _acceptSlot(patient.id, patient.name),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text('Accept'),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Missed',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<dynamic> _getWaitlistPatients(AppointmentProvider appointmentProvider, PatientProvider patientProvider) {
    // Get patients from waitlist appointments
    final waitlistAppointments = appointmentProvider.waitlistAppointments;
    final patients = <dynamic>[];
    
    for (final appointment in waitlistAppointments.take(5)) {
      final patient = patientProvider.getPatientById(appointment.patientId);
      if (patient != null) {
        patients.add(patient);
      }
    }
    
    // Sort by loyalty points (VIP first)
    patients.sort((a, b) => b.loyaltyPoints.compareTo(a.loyaltyPoints));
    
    return patients;
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeRemaining() {
    if (_timeRemaining.inSeconds <= 0) return '0:00';
    
    if (_timeRemaining.inSeconds > 60) {
      return '${_timeRemaining.inMinutes}:${(_timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return _timeRemaining.inSeconds.toString();
    }
  }
}
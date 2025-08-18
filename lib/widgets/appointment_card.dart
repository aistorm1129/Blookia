import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/patient.dart';
import '../screens/schedule/waitlist_recovery_screen.dart';
import '../screens/consultation/consultation_mode_screen.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final Patient? patient;
  final VoidCallback onTap;
  final Function(AppointmentStatus) onStatusChanged;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.patient,
    required this.onTap,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(appointment.status).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  // Time
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatTime(appointment.start),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Patient Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient?.name ?? 'Unknown Patient',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getAppointmentTypeDisplay(appointment.type),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(appointment.status),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Details Row
              Row(
                children: [
                  // Duration
                  _buildInfoChip(
                    Icons.schedule,
                    '${appointment.durationMinutes ?? 60} min',
                    Colors.grey,
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Channel
                  _buildInfoChip(
                    _getChannelIcon(appointment.channel),
                    _getChannelDisplayName(appointment.channel),
                    Colors.blue,
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // No-show risk indicator
                  if (appointment.noShowRisk > 0.7)
                    _buildInfoChip(
                      Icons.warning,
                      'High Risk',
                      Colors.red,
                    ),
                  
                  const Spacer(),
                  
                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (appointment.status == AppointmentStatus.waitlist)
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => onStatusChanged(AppointmentStatus.confirmed),
                          tooltip: 'Confirm',
                        ),
                      
                      if (appointment.status == AppointmentStatus.confirmed)
                        IconButton(
                          icon: const Icon(Icons.play_circle, color: Colors.blue),
                          onPressed: () => _startConsultation(context),
                          tooltip: 'Start Consultation',
                        ),
                      
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) => _handleMenuAction(value, context),
                        itemBuilder: (context) => [
                          if (appointment.status != AppointmentStatus.cancelled)
                            const PopupMenuItem(
                              value: 'cancel',
                              child: Row(
                                children: [
                                  Icon(Icons.cancel, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Cancel'),
                                ],
                              ),
                            ),
                          if (appointment.status == AppointmentStatus.confirmed)
                            const PopupMenuItem(
                              value: 'reschedule',
                              child: Row(
                                children: [
                                  Icon(Icons.schedule, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Reschedule'),
                                ],
                              ),
                            ),
                          if (appointment.status != AppointmentStatus.completed)
                            const PopupMenuItem(
                              value: 'complete',
                              child: Row(
                                children: [
                                  Icon(Icons.done, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Mark Complete'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'notes',
                            child: Row(
                              children: [
                                Icon(Icons.note_add, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Add Notes'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              // Notes section if available
              if (appointment.notes != null || appointment.isUrgent) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: appointment.isUrgent 
                        ? Colors.red.withOpacity(0.1) 
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (appointment.isUrgent) ...[
                        const Icon(Icons.priority_high, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        if (appointment.notes != null) const SizedBox(width: 8),
                      ],
                      if (appointment.notes != null)
                        Expanded(
                          child: Text(
                            appointment.notes!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.waitlist:
        return Colors.orange;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.waitlist:
        return 'Waitlist';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  String _getAppointmentTypeDisplay(AppointmentType type) {
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

  IconData _getChannelIcon(Channel channel) {
    switch (channel) {
      case Channel.inPerson:
        return Icons.person;
      case Channel.teleconsult:
        return Icons.video_call;
      case Channel.phone:
        return Icons.phone;
    }
  }

  String _getChannelDisplayName(Channel channel) {
    switch (channel) {
      case Channel.inPerson:
        return 'In-Person';
      case Channel.teleconsult:
        return 'Video';
      case Channel.phone:
        return 'Phone';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _startConsultation(BuildContext context) {
    if (patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationModeScreen(
          appointment: appointment,
          patient: patient!,
        ),
      ),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'cancel':
        _showCancelDialog(context);
        break;
      case 'complete':
        onStatusChanged(AppointmentStatus.completed);
        break;
      case 'reschedule':
        // Handle reschedule
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reschedule feature coming soon...')),
        );
        break;
      case 'notes':
        // Handle add notes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add notes feature coming soon...')),
        );
        break;
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Would you like to offer this slot to patients on the waitlist?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onStatusChanged(AppointmentStatus.cancelled);
            },
            child: const Text('Just Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showWaitlistRecovery(context);
            },
            child: const Text('Offer to Waitlist'),
          ),
        ],
      ),
    );
  }

  void _showWaitlistRecovery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaitlistRecoveryScreen(
          cancelledAppointment: appointment,
        ),
      ),
    );
  }
}
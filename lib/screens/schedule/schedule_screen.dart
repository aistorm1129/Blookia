import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/patient_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/appointment.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/schedule_calendar.dart';
import 'auto_messages_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCalendarView = false;
  AppointmentStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AppointmentProvider, PatientProvider, SettingsProvider>(
      builder: (context, appointmentProvider, patientProvider, settings, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(settings.translate('schedule')),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(_showCalendarView ? Icons.list : Icons.calendar_view_month),
                onPressed: () {
                  setState(() {
                    _showCalendarView = !_showCalendarView;
                  });
                },
              ),
              PopupMenuButton<AppointmentStatus?>(
                icon: const Icon(Icons.filter_list),
                onSelected: (status) {
                  setState(() {
                    _statusFilter = status;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: null,
                    child: Text('All Appointments'),
                  ),
                  ...AppointmentStatus.values.map(
                    (status) => PopupMenuItem(
                      value: status,
                      child: Text(_getStatusDisplayName(status)),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: () => _showAutoMessages(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Quick Stats
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Today',
                        appointmentProvider.todayAppointments.length.toString(),
                        Icons.today,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Confirmed',
                        _getFilteredAppointments(appointmentProvider.appointments, AppointmentStatus.confirmed).length.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Waitlist',
                        appointmentProvider.waitlistAppointments.length.toString(),
                        Icons.hourglass_empty,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Risk',
                        appointmentProvider.highRiskAppointments.length.toString(),
                        Icons.warning,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Waitlist'),
                  Tab(text: 'High Risk'),
                ],
              ),
              
              // Content
              Expanded(
                child: _showCalendarView
                    ? ScheduleCalendar(
                        appointments: appointmentProvider.appointments,
                        onDateSelected: (date) {
                          appointmentProvider.setSelectedDate(date);
                        },
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAppointmentsList(
                            appointmentProvider.todayAppointments,
                            patientProvider,
                            'No appointments today',
                          ),
                          _buildAppointmentsList(
                            appointmentProvider.upcomingAppointments,
                            patientProvider,
                            'No upcoming appointments',
                          ),
                          _buildAppointmentsList(
                            appointmentProvider.waitlistAppointments,
                            patientProvider,
                            'No waitlist appointments',
                          ),
                          _buildAppointmentsList(
                            appointmentProvider.highRiskAppointments,
                            patientProvider,
                            'No high-risk appointments',
                          ),
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addAppointment(),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(
    List<Appointment> appointments,
    PatientProvider patientProvider,
    String emptyMessage,
  ) {
    final filteredAppointments = _statusFilter != null
        ? appointments.where((apt) => apt.status == _statusFilter).toList()
        : appointments;

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        final patient = patientProvider.getPatientById(appointment.patientId);
        
        return AppointmentCard(
          appointment: appointment,
          patient: patient,
          onTap: () => _showAppointmentDetails(appointment, patient),
          onStatusChanged: (newStatus) => _updateAppointmentStatus(appointment.id, newStatus),
        );
      },
    );
  }

  List<Appointment> _getFilteredAppointments(List<Appointment> appointments, AppointmentStatus status) {
    return appointments.where((apt) => apt.status == status).toList();
  }

  String _getStatusDisplayName(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.waitlist:
        return 'Waitlist';
      case AppointmentStatus.noShow:
        return 'No Show';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
    }
  }

  void _showAutoMessages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AutoMessagesScreen(),
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment, patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Appointment Details',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Appointment info would go here
                Text('Patient: ${patient?.name ?? "Unknown"}')
                // More details...
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateAppointmentStatus(String appointmentId, AppointmentStatus newStatus) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    appointmentProvider.updateAppointmentStatus(appointmentId, newStatus);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment status updated to ${_getStatusDisplayName(newStatus)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add appointment feature coming soon...'),
      ),
    );
  }
}
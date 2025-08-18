import 'package:flutter/material.dart';
import '../models/appointment.dart';

class ScheduleCalendar extends StatefulWidget {
  final List<Appointment> appointments;
  final Function(DateTime) onDateSelected;

  const ScheduleCalendar({
    super.key,
    required this.appointments,
    required this.onDateSelected,
  });

  @override
  State<ScheduleCalendar> createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  late PageController _pageController;
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1000, // Start at a large number to allow both directions
    );
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(-1),
              ),
              
              Text(
                '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
        ),
        
        // Days of week header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Calendar Grid
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              final offset = index - 1000;
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset);
              });
            },
            itemBuilder: (context, index) {
              final offset = index - 1000;
              final month = DateTime(_currentMonth.year, _currentMonth.month + offset);
              return _buildCalendarGrid(month);
            },
          ),
        ),
        
        // Selected date appointments
        if (_selectedDate != null) _buildSelectedDateAppointments(),
      ],
    );
  }

  Widget _buildCalendarGrid(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    List<Widget> dayWidgets = [];

    // Empty cells for days before the first day of the month
    for (int i = 0; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final appointmentsForDay = _getAppointmentsForDate(date);
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == date.day;
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
            widget.onDateSelected(date);
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isToday
                      ? Theme.of(context).primaryColor.withOpacity(0.3)
                      : null,
              borderRadius: BorderRadius.circular(8),
              border: appointmentsForDay.isNotEmpty
                  ? Border.all(color: Colors.green, width: 1)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? Theme.of(context).primaryColor
                            : null,
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                
                // Appointment indicators
                if (appointmentsForDay.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < appointmentsForDay.length && i < 3; i++)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: _getStatusColor(appointmentsForDay[i].status),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        if (appointmentsForDay.length > 3)
                          Text(
                            '+${appointmentsForDay.length - 3}',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 7,
        children: dayWidgets,
      ),
    );
  }

  Widget _buildSelectedDateAppointments() {
    final appointmentsForDay = _getAppointmentsForDate(_selectedDate!);
    
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Appointments - ${_formatDate(_selectedDate!)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Expanded(
            child: appointmentsForDay.isEmpty
                ? const Center(
                    child: Text(
                      'No appointments for this date',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: appointmentsForDay.length,
                    itemBuilder: (context, index) {
                      final appointment = appointmentsForDay[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(appointment.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getStatusColor(appointment.status).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _formatTime(appointment.start),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,\n                              ),\n                            ),\n                            const SizedBox(width: 12),\n                            Expanded(\n                              child: Text(\n                                _getAppointmentTypeDisplay(appointment.type),\n                                style: const TextStyle(fontSize: 14),\n                              ),\n                            ),\n                            Container(\n                              padding: const EdgeInsets.symmetric(\n                                horizontal: 8,\n                                vertical: 2,\n                              ),\n                              decoration: BoxDecoration(\n                                color: _getStatusColor(appointment.status),\n                                borderRadius: BorderRadius.circular(10),\n                              ),\n                              child: Text(\n                                _getStatusDisplayName(appointment.status),\n                                style: const TextStyle(\n                                  fontSize: 10,\n                                  color: Colors.white,\n                                  fontWeight: FontWeight.w500,\n                                ),\n                              ),\n                            ),\n                          ],\n                        ),\n                      );\n                    },\n                  ),\n          ),\n        ],\n      ),\n    );\n  }\n\n  List<Appointment> _getAppointmentsForDate(DateTime date) {\n    return widget.appointments.where((appointment) {\n      return appointment.start.year == date.year &&\n             appointment.start.month == date.month &&\n             appointment.start.day == date.day;\n    }).toList()..sort((a, b) => a.start.compareTo(b.start));\n  }\n\n  void _changeMonth(int offset) {\n    setState(() {\n      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset);\n    });\n    _pageController.animateToPage(\n      1000 + offset,\n      duration: const Duration(milliseconds: 300),\n      curve: Curves.easeInOut,\n    );\n  }\n\n  String _getMonthName(int month) {\n    const months = [\n      'January', 'February', 'March', 'April', 'May', 'June',\n      'July', 'August', 'September', 'October', 'November', 'December'\n    ];\n    return months[month - 1];\n  }\n\n  String _formatDate(DateTime date) {\n    return '${date.day}/${date.month}/${date.year}';\n  }\n\n  String _formatTime(DateTime dateTime) {\n    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';\n  }\n\n  Color _getStatusColor(AppointmentStatus status) {\n    switch (status) {\n      case AppointmentStatus.confirmed:\n        return Colors.green;\n      case AppointmentStatus.waitlist:\n        return Colors.orange;\n      case AppointmentStatus.cancelled:\n        return Colors.red;\n      case AppointmentStatus.completed:\n        return Colors.blue;\n      case AppointmentStatus.noShow:\n        return Colors.grey;\n    }\n  }\n\n  String _getStatusDisplayName(AppointmentStatus status) {\n    switch (status) {\n      case AppointmentStatus.confirmed:\n        return 'Confirmed';\n      case AppointmentStatus.waitlist:\n        return 'Waitlist';\n      case AppointmentStatus.cancelled:\n        return 'Cancelled';\n      case AppointmentStatus.completed:\n        return 'Completed';\n      case AppointmentStatus.noShow:\n        return 'No Show';\n    }\n  }\n\n  String _getAppointmentTypeDisplay(AppointmentType type) {\n    switch (type) {\n      case AppointmentType.consultation:\n        return 'Consultation';\n      case AppointmentType.procedure:\n        return 'Procedure';\n      case AppointmentType.followUp:\n        return 'Follow-up';\n      case AppointmentType.emergency:\n        return 'Emergency';\n    }\n  }\n}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/patient_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/ai_assistant_fab.dart';
import '../../widgets/sync_status_widget.dart';
import '../patients/patients_screen.dart';
import '../schedule/schedule_screen.dart';
import '../settings/comprehensive_settings_screen.dart';
import '../chat/assistant_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Show sync notification if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      appProvider.showSyncNotification(context);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer5<AuthProvider, AppProvider, AppointmentProvider, PatientProvider, SettingsProvider>(
      builder: (context, auth, app, appointments, patients, settings, _) {
        return Scaffold(
          floatingActionButton: const AIAssistantFAB(context: 'dashboard'),
          body: Stack(
            children: [
              const AnimatedBackground(),
              
              Column(
                children: [
                  // App Bar
                  Container(
                    padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          // User Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${auth.currentUser?.name ?? 'User'}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        auth.currentUserRoleDisplay,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        auth.currentTenant?.name ?? 'Clinic',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Actions
                          Row(
                            children: [
                              // Language Selector
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.language),
                                onSelected: (locale) {
                                  settings.setLocale(locale);
                                },
                                itemBuilder: (context) => settings.localeNames.entries.map(
                                  (entry) => PopupMenuItem(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ),
                                ).toList(),
                              ),
                              
                              // Offline Toggle
                              Switch(
                                value: app.isOfflineMode,
                                onChanged: (_) => app.toggleOfflineMode(),
                                activeColor: Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Offline Banner
                  if (app.isOfflineMode) const OfflineBanner(),
                  
                  // Sync Status Banner
                  const SyncStatusBanner(),
                  
                  // Content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      children: [
                        _buildDashboardContent(context, appointments, patients, settings),
                        const PatientsScreen(),
                        const ScheduleScreen(),
                        const AssistantScreen(),
                        const ComprehensiveSettingsScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard),
                label: settings.translate('dashboard'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people),
                label: settings.translate('patients'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today),
                label: settings.translate('schedule'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat),
                label: 'Assistant',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: settings.translate('settings'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    AppointmentProvider appointments,
    PatientProvider patients,
    SettingsProvider settings,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your clinic operations efficiently',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // KPI Cards
          Text(
            'Key Metrics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              KPICard(
                title: 'Today\'s Appointments',
                value: appointments.todayAppointments.length.toString(),
                icon: Icons.today,
                color: Colors.blue,
                trend: '+12%',
                onTap: () => _onTabTapped(2), // Go to schedule
              ),
              KPICard(
                title: 'No-show Risk',
                value: appointments.highRiskAppointments.length.toString(),
                icon: Icons.warning,
                color: Colors.orange,
                trend: '-5%',
                onTap: () => _onTabTapped(2),
              ),
              KPICard(
                title: 'Pending Payments',
                value: '3', // Mock value
                icon: Icons.payment,
                color: Colors.red,
                trend: '+2',
                onTap: () {}, // Could navigate to payments screen
              ),
              KPICard(
                title: 'Patient NPS',
                value: '4.8',
                icon: Icons.star,
                color: Colors.green,
                trend: '+0.2',
                onTap: () {},
              ),
              KPICard(
                title: 'Waitlist',
                value: appointments.waitlistAppointments.length.toString(),
                icon: Icons.queue,
                color: Colors.purple,
                trend: '+${appointments.waitlistAppointments.length}',
                onTap: () => _onTabTapped(2),
              ),
              KPICard(
                title: 'Total Patients',
                value: patients.patients.length.toString(),
                icon: Icons.people,
                color: Colors.teal,
                trend: '+${patients.getPatientsWithRecentActivity().length}',
                onTap: () => _onTabTapped(1),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Schedule Appointment',
                  Icons.add_circle,
                  Colors.blue,
                  () => _onTabTapped(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Add Patient',
                  Icons.person_add,
                  Colors.green,
                  () => _onTabTapped(1),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Start Consultation',
                  Icons.medical_services,
                  Colors.orange,
                  () {
                    // Navigate to consultation mode
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'AI Assistant',
                  Icons.chat,
                  Colors.purple,
                  () => _onTabTapped(3),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildActivityItem(
                  'Appointment confirmed',
                  'Sofia Rodriguez - 2:00 PM',
                  Icons.check_circle,
                  Colors.green,
                  '5 min ago',
                ),
                const Divider(),
                _buildActivityItem(
                  'Payment received',
                  'Isabella Martínez - \$250',
                  Icons.payment,
                  Colors.blue,
                  '10 min ago',
                ),
                const Divider(),
                _buildActivityItem(
                  'New message',
                  'Consultation inquiry',
                  Icons.message,
                  Colors.purple,
                  '15 min ago',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/localization_service.dart';
import '../../services/accessibility_service.dart';
import '../../services/sync_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/sync_status_widget.dart';

class ComprehensiveSettingsScreen extends StatefulWidget {
  const ComprehensiveSettingsScreen({super.key});

  @override
  State<ComprehensiveSettingsScreen> createState() => _ComprehensiveSettingsScreenState();
}

class _ComprehensiveSettingsScreenState extends State<ComprehensiveSettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.language), text: 'Language'),
            Tab(icon: Icon(Icons.accessibility), text: 'Accessibility'),
            Tab(icon: Icon(Icons.sync), text: 'Sync'),
            Tab(icon: Icon(Icons.info), text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLanguageTab(),
          _buildAccessibilityTab(),
          _buildSyncTab(),
          _buildAboutTab(),
        ],
      ),
    );
  }

  Widget _buildLanguageTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current Language
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.language, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    const Text(
                      'Current Language',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Language Options - Mock data since service isn't initialized
                _buildLanguageOption('🇺🇸', 'English', 'en', true),
                _buildLanguageOption('🇧🇷', 'Português', 'pt', false),
                _buildLanguageOption('🇪🇸', 'Español', 'es', false),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Format Examples
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Format Examples',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFormatExample('Date', '12/18/2024', Icons.date_range),
                _buildFormatExample('Time', '02:30 PM', Icons.access_time),
                _buildFormatExample('Currency', '\$1,234.56', Icons.attach_money),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String flag, String name, String code, bool isSelected) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(name),
        ],
      ),
      value: code,
      groupValue: isSelected ? code : '',
      onChanged: (value) {
        // Handle language change
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language changed to $name')),
        );
      },
      selected: isSelected,
    );
  }

  Widget _buildAccessibilityTab() {
    return Consumer<AccessibilityService>(
      builder: (context, accessibility, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Quick Presets
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 12),
                        const Text(
                          'Accessibility Presets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetChip('Standard', AccessibilityPreset.standard, accessibility, Icons.settings),
                        _buildPresetChip('Vision Support', AccessibilityPreset.visualImpairment, accessibility, Icons.visibility),
                        _buildPresetChip('Motor Support', AccessibilityPreset.motorImpairment, accessibility, Icons.touch_app),
                        _buildPresetChip('Cognitive Support', AccessibilityPreset.cognitiveSupport, accessibility, Icons.psychology),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Text Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Text & Display',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ListTile(
                      leading: const Icon(Icons.text_fields),
                      title: const Text('Text Size'),
                      subtitle: Text('${(accessibility.textScaleFactor * 100).round()}%'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: accessibility.decreaseTextSize,
                            icon: const Icon(Icons.text_decrease),
                          ),
                          IconButton(
                            onPressed: accessibility.increaseTextSize,
                            icon: const Icon(Icons.text_increase),
                          ),
                        ],
                      ),
                    ),
                    
                    SwitchListTile(
                      secondary: const Icon(Icons.contrast),
                      title: const Text('High Contrast'),
                      subtitle: const Text('Improve visibility with stronger colors'),
                      value: accessibility.highContrastMode,
                      onChanged: (_) => accessibility.toggleHighContrast(),
                    ),
                    
                    SwitchListTile(
                      secondary: const Icon(Icons.animation),
                      title: const Text('Reduce Animations'),
                      subtitle: const Text('Minimize motion for better focus'),
                      value: accessibility.reduceAnimations,
                      onChanged: (_) => accessibility.toggleReduceAnimations(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Interaction Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interaction & Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ListTile(
                      leading: const Icon(Icons.touch_app),
                      title: const Text('Button Size'),
                      subtitle: Text('${accessibility.minimumTouchTargetSize.round()}px minimum'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: accessibility.decreaseTouchTargetSize,
                            icon: const Icon(Icons.remove),
                          ),
                          IconButton(
                            onPressed: accessibility.increaseTouchTargetSize,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                    
                    SwitchListTile(
                      secondary: const Icon(Icons.vibration),
                      title: const Text('Haptic Feedback'),
                      subtitle: const Text('Vibration for button presses'),
                      value: accessibility.hapticFeedbackEnabled,
                      onChanged: (_) => accessibility.toggleHapticFeedback(),
                    ),
                    
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up),
                      title: const Text('Sound Feedback'),
                      subtitle: const Text('Audio cues for interactions'),
                      value: accessibility.soundFeedbackEnabled,
                      onChanged: (_) => accessibility.toggleSoundFeedback(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSyncTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SyncStatusWidget(showDetails: true),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sync, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      const Text(
                        'Sync Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    secondary: const Icon(Icons.wifi),
                    title: const Text('Auto Sync'),
                    subtitle: const Text('Automatically sync when online'),
                    value: true,
                    onChanged: (value) {
                      // Toggle auto sync
                    },
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Storage Usage'),
                    subtitle: const Text('12.3 MB of offline data stored'),
                    trailing: TextButton(
                      onPressed: _showStorageDetails,
                      child: const Text('Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Blookia',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Medical Clinic Assistant',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 1.0.0 (Beta)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Compliance Badges
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compliance & Security',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildComplianceBadge('HIPAA', 'Compliant', Colors.blue, Icons.security),
                      _buildComplianceBadge('GDPR', 'Compliant', Colors.green, Icons.privacy_tip),
                      _buildComplianceBadge('LGPD', 'Compliant', Colors.orange, Icons.verified_user),
                      _buildComplianceBadge('ISO 27001', 'Certified', Colors.purple, Icons.shield),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(auth),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormatExample(String label, String example, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            example,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(
    String label,
    AccessibilityPreset preset,
    AccessibilityService accessibility,
    IconData icon,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {
        accessibility.applyPreset(preset);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Applied $label preset')),
        );
      },
    );
  }

  Widget _buildComplianceBadge(
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStorageDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Details'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patients: 2.1 MB'),
            Text('Appointments: 4.2 MB'),
            Text('Images: 5.8 MB'),
            Text('Cache: 0.2 MB'),
            Divider(),
            Text('Total: 12.3 MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              auth.logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
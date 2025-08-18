import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../screens/ai_assistant/ai_chat_screen.dart';

class AIAssistantFAB extends StatefulWidget {
  final String? context;
  final Patient? patient;
  final Appointment? appointment;
  final VoidCallback? onPressed;

  const AIAssistantFAB({
    super.key,
    this.context,
    this.patient,
    this.appointment,
    this.onPressed,
  });

  @override
  State<AIAssistantFAB> createState() => _AIAssistantFABState();
}

class _AIAssistantFABState extends State<AIAssistantFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _hasNewNotification = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.blue.shade300,
    ).animate(_animationController);
    
    _animationController.repeat(reverse: true);
    
    // Simulate AI notification system
    _simulateAINotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _simulateAINotifications() {
    // Simulate periodic AI suggestions/notifications
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _hasNewNotification = true;
        });
      }
    });
  }

  void _openAIAssistant() {
    setState(() {
      _hasNewNotification = false;
    });
    
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AIChatScreen(
            context: widget.context,
            patient: widget.patient,
            appointment: widget.appointment,
          ),
        ),
      );
    }
  }

  String _getTooltipText() {
    if (widget.context != null) {
      switch (widget.context) {
        case 'dashboard':
          return 'AI Analytics Assistant';
        case 'patient':
          return 'AI Clinical Assistant';
        case 'consultation':
          return 'AI Consultation Support';
        default:
          return 'Blookia AI Assistant';
      }
    }
    return 'Blookia AI Assistant';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main FAB
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: FloatingActionButton(
                onPressed: _openAIAssistant,
                backgroundColor: _colorAnimation.value,
                tooltip: _getTooltipText(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 28,
                    ),
                    
                    // AI "thinking" animation
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Notification Badge
        if (_hasNewNotification)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        
        // Context Indicator
        if (widget.context != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getContextColor(),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                _getContextIcon(),
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
      ],
    );
  }

  Color _getContextColor() {
    switch (widget.context) {
      case 'dashboard':
        return Colors.green;
      case 'patient':
        return Colors.orange;
      case 'consultation':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getContextIcon() {
    switch (widget.context) {
      case 'dashboard':
        return Icons.analytics;
      case 'patient':
        return Icons.person;
      case 'consultation':
        return Icons.medical_services;
      default:
        return Icons.help;
    }
  }
}

class AIAssistantBottomSheet extends StatelessWidget {
  final String? context;
  final Patient? patient;
  final Appointment? appointment;

  const AIAssistantBottomSheet({
    super.key,
    this.context,
    this.patient,
    this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blookia AI Assistant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'How can I help you today?',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          SizedBox(
            height: 100,
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              children: [
                _buildQuickAction(
                  icon: Icons.analytics,
                  label: 'Analytics',
                  onTap: () => _openAIChat(context, 'analytics'),
                ),
                _buildQuickAction(
                  icon: Icons.medical_services,
                  label: 'Clinical',
                  onTap: () => _openAIChat(context, 'clinical'),
                ),
                _buildQuickAction(
                  icon: Icons.schedule,
                  label: 'Schedule',
                  onTap: () => _openAIChat(context, 'schedule'),
                ),
                _buildQuickAction(
                  icon: Icons.help,
                  label: 'General',
                  onTap: () => _openAIChat(context, 'general'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Chat Interface
          Expanded(
            child: AIChatScreen(
              context: this.context,
              patient: patient,
              appointment: appointment,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openAIChat(BuildContext context, String mode) {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIChatScreen(
          context: mode,
          patient: patient,
          appointment: appointment,
        ),
      ),
    );
  }
}

// Helper widget for inline AI suggestions
class AIInlineSuggestion extends StatelessWidget {
  final String suggestion;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const AIInlineSuggestion({
    super.key,
    required this.suggestion,
    required this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Suggestion',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  suggestion,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: const Text('Ask AI'),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 16),
            ),
        ],
      ),
    );
  }
}
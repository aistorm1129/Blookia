import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../models/patient.dart';
import '../../models/appointment.dart';
import '../../models/chat_message.dart';
import '../../providers/auth_provider.dart';

class AIChatScreen extends StatefulWidget {
  final String? context; // 'dashboard', 'patient', 'consultation', 'general'
  final Patient? patient;
  final Appointment? appointment;

  const AIChatScreen({
    super.key,
    this.context,
    this.patient,
    this.appointment,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final List<String> _suggestionChips = [];
  
  bool _isTyping = false;
  bool _isListening = false;
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;
  
  // AI Assistant Modes
  AIAssistantMode _currentMode = AIAssistantMode.general;

  @override
  void initState() {
    super.initState();
    
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_typingAnimationController);
    
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    // Set context-specific mode
    _currentMode = _getModeFromContext();
    
    // Add welcome message
    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      from: MessageSender.assistant,
      text: _getWelcomeMessage(),
      timestamp: DateTime.now(),
    ));
    
    // Generate context-specific suggestions
    _generateSuggestionChips();
  }

  AIAssistantMode _getModeFromContext() {
    switch (widget.context) {
      case 'dashboard':
        return AIAssistantMode.analytics;
      case 'patient':
        return AIAssistantMode.clinical;
      case 'consultation':
        return AIAssistantMode.consultation;
      default:
        return AIAssistantMode.general;
    }
  }

  String _getWelcomeMessage() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final userName = user?.name ?? 'Doctor';
    
    switch (_currentMode) {
      case AIAssistantMode.clinical:
        if (widget.patient != null) {
          return "Hello Dr. $userName! I'm here to help with ${widget.patient!.name}'s case. I can assist with treatment recommendations, drug interactions, medical research, and patient history analysis.";
        }
        return "Hello Dr. $userName! I'm your clinical AI assistant. How can I help you with patient care today?";
      
      case AIAssistantMode.consultation:
        return "I'm assisting with your consultation session. I can help with symptoms analysis, treatment protocols, medication guidance, and documentation.";
      
      case AIAssistantMode.analytics:
        return "Hello Dr. $userName! I can help you analyze clinic performance, patient trends, financial insights, and scheduling optimization.";
      
      case AIAssistantMode.general:
        return "Hello Dr. $userName! I'm Blookia AI, your intelligent assistant. I can help with medical questions, clinic management, patient care, and much more. What can I assist you with today?";
    }
  }

  void _generateSuggestionChips() {
    _suggestionChips.clear();
    
    switch (_currentMode) {
      case AIAssistantMode.clinical:
        if (widget.patient != null) {
          _suggestionChips.addAll([
            "Analyze patient allergies",
            "Suggest treatment protocol",
            "Review medication interactions",
            "Explain procedure risks",
            "Generate follow-up plan",
          ]);
        } else {
          _suggestionChips.addAll([
            "Latest clinical guidelines",
            "Drug interaction checker",
            "Symptom differential",
            "Treatment protocols",
            "Medical research updates",
          ]);
        }
        break;
      
      case AIAssistantMode.consultation:
        _suggestionChips.addAll([
          "Help with diagnosis",
          "Treatment recommendations",
          "Medication dosage",
          "Document findings",
          "Patient education materials",
        ]);
        break;
      
      case AIAssistantMode.analytics:
        _suggestionChips.addAll([
          "Clinic performance summary",
          "Patient satisfaction trends",
          "Revenue analysis",
          "No-show predictions",
          "Optimization suggestions",
        ]);
        break;
      
      case AIAssistantMode.general:
        _suggestionChips.addAll([
          "Help with patient case",
          "Clinic management tips",
          "Latest medical news",
          "Schedule optimization",
          "Billing questions",
        ]);
        break;
    }
    
    setState(() {});
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;
    
    // Add user message
    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      from: MessageSender.patient,
      text: content,
      timestamp: DateTime.now(),
    ));
    
    _messageController.clear();
    _generateAIResponse(content);
  }

  void _generateAIResponse(String userMessage) {
    setState(() {
      _isTyping = true;
    });
    
    _typingAnimationController.repeat(reverse: true);
    
    // Simulate AI processing time
    Timer(Duration(milliseconds: 1500 + Random().nextInt(2000)), () {
      final response = _getAIResponse(userMessage);
      
      setState(() {
        _isTyping = false;
      });
      
      _typingAnimationController.stop();
      _typingAnimationController.reset();
      
      _addMessage(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        from: MessageSender.assistant,
        text: response,
        timestamp: DateTime.now(),
      ));
    });
  }

  String _getAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    // Context-aware responses
    if (_currentMode == AIAssistantMode.clinical && widget.patient != null) {
      return _getClinicalResponse(lowerMessage, widget.patient!);
    } else if (_currentMode == AIAssistantMode.consultation) {
      return _getConsultationResponse(lowerMessage);
    } else if (_currentMode == AIAssistantMode.analytics) {
      return _getAnalyticsResponse(lowerMessage);
    }
    
    // General responses
    if (lowerMessage.contains('schedule') || lowerMessage.contains('appointment')) {
      return _getScheduleResponse();
    } else if (lowerMessage.contains('patient') && lowerMessage.contains('manage')) {
      return _getPatientManagementResponse();
    } else if (lowerMessage.contains('payment') || lowerMessage.contains('billing')) {
      return _getPaymentResponse();
    } else if (lowerMessage.contains('help') || lowerMessage.contains('how to')) {
      return _getHelpResponse();
    } else if (lowerMessage.contains('symptom') || lowerMessage.contains('diagnos')) {
      return _getMedicalResponse();
    }
    
    return _getDefaultResponse();
  }

  String _getClinicalResponse(String message, Patient patient) {
    if (message.contains('allergies') || message.contains('allergy')) {
      if (patient.allergies.isNotEmpty) {
        return "⚠️ **Patient Allergies Alert**\n\n${patient.name} has the following known allergies:\n\n${patient.allergies.map((a) => '• $a').join('\n')}\n\n**Recommendations:**\n• Always verify before prescribing new medications\n• Consider cross-allergies and related substances\n• Have emergency protocols ready\n• Document any new allergic reactions";
      } else {
        return "✅ **No Known Allergies**\n\n${patient.name} has no documented allergies in their file. However, always ask about new allergies before procedures or prescriptions.";
      }
    } else if (message.contains('medication') || message.contains('drug')) {
      if (patient.medications.isNotEmpty) {
        return "💊 **Current Medications**\n\n${patient.name} is currently taking:\n\n${patient.medications.map((m) => '• $m').join('\n')}\n\n**Clinical Considerations:**\n• Check for drug interactions before adding new medications\n• Verify dosage schedules and compliance\n• Monitor for side effects\n• Consider contraindications for procedures";
      } else {
        return "📋 **No Current Medications**\n\n${patient.name} is not currently on any documented medications. Always verify this information during consultation.";
      }
    } else if (message.contains('treatment') || message.contains('protocol')) {
      return "🎯 **Treatment Recommendations for ${patient.name}**\n\nBased on the patient profile:\n\n**Assessment Factors:**\n• Age: ${_calculateAge(patient.dateOfBirth)} years\n• Medical history: Review required\n• Current medications: ${patient.medications.isEmpty ? 'None' : patient.medications.length.toString()}\n• Known allergies: ${patient.allergies.isEmpty ? 'None' : patient.allergies.length.toString()}\n\n**Next Steps:**\n1. Complete physical examination\n2. Review diagnostic requirements\n3. Discuss treatment options\n4. Obtain informed consent\n\n*Always validate this information with current clinical guidelines.*";
    }
    
    return "I can help you with ${patient.name}'s clinical care. What specific aspect would you like to discuss? I can analyze allergies, medications, treatment protocols, or help with medical decision-making.";
  }

  String _getConsultationResponse(String message) {
    if (message.contains('diagnos')) {
      return "🔍 **Diagnostic Support**\n\n**Systematic Approach:**\n1. **Chief Complaint**: Document primary concern\n2. **History of Present Illness**: Timeline and characteristics\n3. **Physical Examination**: Focused assessment\n4. **Differential Diagnosis**: Consider alternatives\n5. **Diagnostic Tests**: If indicated\n\n**Red Flags to Watch:**\n• Sudden onset severe symptoms\n• Progressive neurological signs\n• Cardiovascular instability\n• Signs of infection or inflammation\n\nWould you like me to help with a specific symptom analysis?";
    } else if (message.contains('treatment') || message.contains('medication')) {
      return "💊 **Treatment Guidance**\n\n**Evidence-Based Approach:**\n1. Confirm diagnosis before treatment\n2. Consider patient factors (age, comorbidities, allergies)\n3. Start with first-line therapies\n4. Monitor for effectiveness and side effects\n5. Adjust based on patient response\n\n**Safety Checklist:**\n✓ Allergies verified\n✓ Drug interactions checked\n✓ Appropriate dosing\n✓ Patient education provided\n✓ Follow-up scheduled\n\nWhat specific treatment are you considering?";
    } else if (message.contains('document') || message.contains('note')) {
      return "📝 **Documentation Support**\n\n**SOAP Format Reminder:**\n**S** - Subjective (patient's words)\n**O** - Objective (your observations, vitals, tests)\n**A** - Assessment (your clinical impression)\n**P** - Plan (treatment, follow-up, education)\n\n**Key Elements:**\n• Clear, concise language\n• Relevant positive and negative findings\n• Clinical reasoning for decisions\n• Patient understanding and consent\n• Follow-up instructions\n\nNeed help structuring specific findings?";
    }
    
    return "I'm here to support your consultation. I can help with diagnostic reasoning, treatment protocols, documentation, or patient education materials. What would you like to focus on?";
  }

  String _getAnalyticsResponse(String message) {
    if (message.contains('performance') || message.contains('summary')) {
      return "📊 **Clinic Performance Summary**\n\n**This Month:**\n• Total Appointments: 245 (↑12% from last month)\n• Patient Satisfaction: 4.7/5.0 (↑0.2)\n• Revenue: \\\$45,200 (↑8%)\n• No-show Rate: 12% (↓3%)\n\n**Top Performing Services:**\n1. Botox treatments (35% of revenue)\n2. Facial cleaning procedures\n3. Consultation appointments\n\n**Recommendations:**\n• Continue waitlist recovery system (reducing no-shows)\n• Expand Botox appointment slots\n• Consider package deals for facial treatments";
    } else if (message.contains('patient') && message.contains('trend')) {
      return "👥 **Patient Analytics**\n\n**Demographics:**\n• Average age: 42 years\n• Gender distribution: 73% female, 27% male\n• New patients: 34 this month\n• Returning patients: 88% retention rate\n\n**Appointment Patterns:**\n• Peak hours: 10am-2pm, 4pm-6pm\n• Most popular day: Wednesdays\n• Average session: 45 minutes\n• Preferred booking: 67% online, 33% phone\n\n**Loyalty Program:**\n• Active members: 156\n• Average points: 245 per patient\n• Redemption rate: 34%";
    } else if (message.contains('revenue') || message.contains('financial')) {
      return "💰 **Financial Analysis**\n\n**Revenue Breakdown:**\n• Procedures: 68% (\\\$30,736)\n• Consultations: 22% (\\\$9,944)\n• Products: 10% (\\\$4,520)\n\n**Payment Methods:**\n• PIX: 45% (instant payments)\n• Credit Card: 35% (avg 3.2 installments)\n• Cash: 12%\n• Bank Transfer: 8%\n\n**Key Metrics:**\n• Average transaction: \\\$185\n• Payment completion: 94%\n• Outstanding balances: \\\$2,340\n\n**Growth Opportunities:**\n• Increase package deal sales\n• Expand credit card installment options\n• Implement loyalty program discounts";
    } else if (message.contains('optimization') || message.contains('improve')) {
      return "🎯 **Optimization Recommendations**\n\n**Scheduling Efficiency:**\n1. Add 15-min buffer slots for complex cases\n2. Group similar procedures on same days\n3. Implement dynamic pricing for off-peak hours\n\n**Patient Experience:**\n1. Reduce waiting time (current avg: 12 min)\n2. Enhance digital check-in process\n3. Follow-up satisfaction surveys\n\n**Revenue Growth:**\n1. Introduce premium service tiers\n2. Develop referral incentive program\n3. Expand social media marketing\n\n**Operational:**\n1. Staff training on upselling techniques\n2. Inventory management optimization\n3. Equipment utilization analysis";
    }
    
    return "I can provide insights on clinic performance, patient trends, financial analysis, or optimization strategies. What specific metrics would you like to explore?";
  }

  String _getScheduleResponse() {
    return "📅 **Schedule Management**\n\nI can help you with:\n\n**Appointment Optimization:**\n• Finding optimal time slots\n• Managing waitlists effectively\n• Reducing no-show rates\n• Balancing provider schedules\n\n**Current Schedule Insights:**\n• Next available slot: Tomorrow 2:30 PM\n• This week's utilization: 87%\n• Waitlist size: 12 patients\n• Average booking lead time: 4.3 days\n\n**Recommendations:**\n• Enable auto-booking for cancellations\n• Send 24-hour reminders\n• Offer incentives for off-peak bookings\n\nWhat specific scheduling challenge can I help you solve?";
  }

  String _getPatientManagementResponse() {
    return "👥 **Patient Management Support**\n\nI can assist with:\n\n**Patient Care:**\n• Treatment history analysis\n• Medication management\n• Allergy tracking\n• Follow-up scheduling\n\n**Administrative Tasks:**\n• Patient communication\n• Documentation assistance\n• Insurance verification\n• Referral management\n\n**Analytics:**\n• Patient satisfaction trends\n• Treatment outcome tracking\n• Loyalty program performance\n• Demographic insights\n\nWhich aspect of patient management needs attention today?";
  }

  String _getPaymentResponse() {
    return "💳 **Payment & Billing Support**\n\n**Available Services:**\n• Generate payment QR codes\n• Process different payment methods\n• Set up installment plans\n• Track outstanding balances\n\n**Current Payment Metrics:**\n• Collection rate: 94%\n• Average payment time: 2.3 days\n• PIX adoption: 45% (growing)\n• Credit card installments: avg 3.2x\n\n**Best Practices:**\n• Offer multiple payment options\n• Clear pricing communication\n• Flexible installment terms\n• Prompt payment incentives\n\nNeed help with a specific payment scenario?";
  }

  String _getMedicalResponse() {
    return "🩺 **Clinical Decision Support**\n\n**I can help with:**\n• Symptom analysis and differential diagnosis\n• Treatment protocol recommendations\n• Drug interaction checking\n• Evidence-based medicine guidelines\n\n**Important Note:**\n*I provide clinical decision support based on established guidelines and evidence. Always use your clinical judgment and validate information with current medical literature. This is not a substitute for professional medical consultation.*\n\n**Safety Reminders:**\n• Verify patient allergies\n• Check medication interactions\n• Consider patient-specific factors\n• Document clinical reasoning\n\nWhat clinical question can I help you research?";
  }

  String _getHelpResponse() {
    return "❓ **How Can I Help?**\n\n**I'm equipped to assist with:**\n\n🏥 **Clinical Support**\n• Patient case analysis\n• Treatment recommendations\n• Drug interaction checks\n• Medical research\n\n📊 **Clinic Management**\n• Performance analytics\n• Schedule optimization\n• Financial insights\n• Operational efficiency\n\n👥 **Patient Care**\n• Communication templates\n• Follow-up protocols\n• Satisfaction analysis\n• Care coordination\n\n💼 **Administrative**\n• Documentation assistance\n• Billing questions\n• Compliance guidance\n• Workflow optimization\n\n**Quick Actions:**\nYou can also try the suggestion chips below for common requests!";
  }

  String _getDefaultResponse() {
    final responses = [
      "I understand you're asking about that. Could you provide more specific details so I can give you the most helpful information?",
      "That's an interesting question! Let me help you with that. Could you elaborate on what specific aspect you'd like me to focus on?",
      "I'm here to help! Could you rephrase your question or provide more context so I can give you the best assistance?",
      "I want to make sure I give you accurate information. Could you provide more details about what you're looking for?",
    ];
    
    return responses[Random().nextInt(responses.length)];
  }

  void _sendSuggestion(String suggestion) {
    _sendMessage(suggestion);
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
    
    if (_isListening) {
      // Simulate voice recognition
      Timer(const Duration(seconds: 3), () {
        setState(() {
          _isListening = false;
        });
        _messageController.text = "Tell me about the patient's medication history";
      });
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              Navigator.pop(context);
              _initializeChat();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _exportChat() {
    final chatText = _messages.map((message) {
      final timestamp = "${message.timestamp.day}/${message.timestamp.month} ${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}";
      final sender = message.from == MessageSender.patient ? 'You' : 'Blookia AI';
      return "[$timestamp] $sender: ${message.text}";
    }).join('\n\n');
    
    Clipboard.setData(ClipboardData(text: chatText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat exported to clipboard')),
    );
  }

  String _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 'Unknown';
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Blookia AI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _getModeDisplayName(_currentMode),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _clearChat();
                  break;
                case 'export':
                  _exportChat();
                  break;
                case 'mode':
                  _showModeSelector();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mode',
                child: Row(
                  children: [
                    Icon(Icons.psychology),
                    SizedBox(width: 8),
                    Text('Change Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Context Info Bar
          if (widget.patient != null || widget.appointment != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.patient != null 
                          ? 'Context: ${widget.patient!.name}'
                          : 'Context: Active Consultation',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Suggestion Chips
          if (_suggestionChips.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestionChips.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        _suggestionChips[index],
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _sendSuggestion(_suggestionChips[index]),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                    ),
                  );
                },
              ),
            ),
          
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Voice Input Button
                  Container(
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: _toggleListening,
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Text Input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ask me anything...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Send Button
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: () => _sendMessage(_messageController.text),
                      icon: const Icon(Icons.send, color: Colors.white),
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

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.from == MessageSender.patient ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (message.from == MessageSender.assistant) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.from == MessageSender.patient
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.from == MessageSender.patient ? Colors.white : Colors.black,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: message.from == MessageSender.patient 
                              ? Colors.white.withOpacity(0.7) 
                              : Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                      
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (message.from == MessageSender.patient) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.withOpacity(0.2),
              child: Icon(Icons.person, color: Colors.grey[600], size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypingDot(0),
                    const SizedBox(width: 4),
                    _buildTypingDot(1),
                    const SizedBox(width: 4),
                    _buildTypingDot(2),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    final delay = index * 0.2;
    final opacity = 0.4 + 0.6 * 
        (sin((_typingAnimation.value + delay) * 2 * pi) * 0.5 + 0.5);
    
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[600]?.withOpacity(opacity),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }


  String _getModeDisplayName(AIAssistantMode mode) {
    switch (mode) {
      case AIAssistantMode.clinical:
        return 'Clinical Assistant';
      case AIAssistantMode.consultation:
        return 'Consultation Support';
      case AIAssistantMode.analytics:
        return 'Analytics Assistant';
      case AIAssistantMode.general:
        return 'General Assistant';
    }
  }

  void _showModeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Assistant Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AIAssistantMode.values.map((mode) => RadioListTile<AIAssistantMode>(
            title: Text(_getModeDisplayName(mode)),
            subtitle: Text(_getModeDescription(mode)),
            value: mode,
            groupValue: _currentMode,
            onChanged: (value) {
              setState(() {
                _currentMode = value!;
              });
              Navigator.pop(context);
              _generateSuggestionChips();
            },
          )).toList(),
        ),
      ),
    );
  }


  String _getModeDescription(AIAssistantMode mode) {
    switch (mode) {
      case AIAssistantMode.clinical:
        return 'Patient care, medical decisions, treatment protocols';
      case AIAssistantMode.consultation:
        return 'Active consultation support and documentation';
      case AIAssistantMode.analytics:
        return 'Clinic performance, trends, and optimization';
      case AIAssistantMode.general:
        return 'General clinic management and medical questions';
    }
  }
}

enum AIAssistantMode {
  clinical,
  consultation,
  analytics,
  general,
}
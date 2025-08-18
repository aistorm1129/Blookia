import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/patient.dart';

class ConsentFormWidget extends StatefulWidget {
  final Patient patient;
  final Appointment appointment;
  final bool consentGiven;
  final Function(bool, String) onConsentChanged;

  const ConsentFormWidget({
    super.key,
    required this.patient,
    required this.appointment,
    required this.consentGiven,
    required this.onConsentChanged,
  });

  @override
  State<ConsentFormWidget> createState() => _ConsentFormWidgetState();
}

class _ConsentFormWidgetState extends State<ConsentFormWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final ScrollController _scrollController = ScrollController();
  bool _hasReadConsent = false;
  bool _agreeToRecord = false;
  bool _agreeToTreatment = false;
  String _digitalSignature = '';
  final TextEditingController _signatureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // Check if user has scrolled to bottom to enable consent
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 50) {
        if (!_hasReadConsent) {
          setState(() {
            _hasReadConsent = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  void _processConsent(bool isAgreed) {
    if (isAgreed && _isFormValid()) {
      setState(() {
        _digitalSignature = _signatureController.text.trim();
      });
      widget.onConsentChanged(true, _digitalSignature);
    } else if (!isAgreed) {
      widget.onConsentChanged(false, '');
    }
  }

  bool _isFormValid() {
    return _hasReadConsent &&
           _agreeToRecord &&
           _agreeToTreatment &&
           _signatureController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.consentGiven) {
      return _buildConsentConfirmation();
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informed Consent',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Patient: ${widget.patient.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Consent Document
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reading Guidance
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please read the entire consent form carefully before signing.',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Consent Content
                  _buildConsentSection('1. Procedure Information', '''
I understand that I am being offered ${_getProcedureDescription()} and that this consultation/treatment is being recorded for medical documentation and quality assurance purposes.

The procedure involves:
• Detailed consultation regarding treatment options
• Assessment of medical history and current condition  
• Discussion of expected outcomes and potential risks
• Development of a personalized treatment plan
                  '''),
                  
                  _buildConsentSection('2. Risks and Complications', '''
I understand that no medical procedure is 100% guaranteed, and complications may include but are not limited to:

• Temporary discomfort or swelling
• Bruising or skin irritation
• Allergic reactions to materials used
• Unsatisfactory cosmetic results
• Need for additional treatments

I have discussed these risks with my healthcare provider and understand them.
                  '''),
                  
                  _buildConsentSection('3. Alternative Treatments', '''
I understand that alternatives to this treatment exist, including:
• Non-invasive options
• Different treatment approaches
• No treatment at all

I have been informed of these alternatives and choose to proceed with the recommended treatment plan.
                  '''),
                  
                  _buildConsentSection('4. Post-Treatment Care', '''
I understand that following post-treatment instructions is crucial for optimal results and that failure to comply may affect the outcome and increase the risk of complications.

I agree to:
• Follow all aftercare instructions
• Attend scheduled follow-up appointments
• Contact the clinic with any concerns
• Avoid certain activities as advised
                  '''),
                  
                  _buildConsentSection('5. Recording and Documentation', '''
I understand and consent to:
• Audio recording of this consultation/treatment session
• Digital photography of treatment areas (if applicable)
• Use of this information for medical documentation
• Sharing with other healthcare providers as necessary for my care

All recordings and documentation will be handled in accordance with HIPAA privacy regulations.
                  '''),
                  
                  _buildConsentSection('6. Financial Agreement', '''
I understand the costs associated with this treatment and agree to:
• Pay all fees as discussed
• Understand that results are not guaranteed
• Additional treatments may require additional payment
• Payment is due regardless of satisfaction with results
                  '''),
                  
                  const SizedBox(height: 30),
                  
                  // Consent Checkboxes
                  if (_hasReadConsent) ...[
                    _buildCheckbox(
                      'I have read and understand the above information',
                      true, // Always true if they've scrolled
                      null, // No callback needed
                    ),
                    _buildCheckbox(
                      'I consent to audio recording of this session',
                      _agreeToRecord,
                      (value) => setState(() => _agreeToRecord = value ?? false),
                    ),
                    _buildCheckbox(
                      'I agree to proceed with the discussed treatment',
                      _agreeToTreatment,
                      (value) => setState(() => _agreeToTreatment = value ?? false),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Digital Signature
                    const Text(
                      'Digital Signature',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _signatureController,
                      decoration: const InputDecoration(
                        labelText: 'Type your full legal name',
                        hintText: 'Enter your name as your digital signature',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Consent Date & Time
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consent Date & Time:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            DateTime.now().toString(),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Scroll to read indicator
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 32,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please scroll down to read the complete consent form',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Action Buttons
          if (_hasReadConsent)
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _processConsent(false),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Decline', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isFormValid() ? () => _processConsent(true) : null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('I Agree & Consent'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConsentSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String text, bool value, Function(bool?)? onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentConfirmation() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 30),
          
          const Text(
            '✅ Consent Obtained',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Patient has provided informed consent',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // Consent Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consent Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Patient', widget.patient.name),
                  _buildSummaryRow('Digital Signature', _digitalSignature),
                  _buildSummaryRow('Consent Time', DateTime.now().toString()),
                  _buildSummaryRow('Recording Consent', '✅ Agreed'),
                  _buildSummaryRow('Treatment Consent', '✅ Agreed'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'You may now proceed with recording',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getProcedureDescription() {
    switch (widget.appointment.type) {
      case AppointmentType.consultation:
        return 'aesthetic consultation and treatment planning';
      case AppointmentType.procedure:
        return 'aesthetic medical procedure';
      case AppointmentType.followUp:
        return 'follow-up consultation and assessment';
      case AppointmentType.emergency:
        return 'urgent medical consultation';
    }
  }
}
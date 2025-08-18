import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../../models/patient.dart';
import '../../models/payment.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/app_theme.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class PaymentScreen extends StatefulWidget {
  final Patient patient;
  final String? appointmentId;

  const PaymentScreen({
    super.key,
    required this.patient,
    this.appointmentId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _uuid = const Uuid();
  
  // Form controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // Payment state
  PaymentMethod _selectedPaymentMethod = PaymentMethod.pix;
  String? _generatedQrCode;
  Payment? _pendingPayment;
  double _totalAmount = 0.0;
  double _discountAmount = 0.0;
  double _finalAmount = 0.0;
  
  // Installments
  int _installments = 1;
  final List<int> _installmentOptions = [1, 2, 3, 6, 10, 12, 18, 24];
  
  // Pre-defined services
  final List<Map<String, dynamic>> _services = [
    {'name': 'Botox Application', 'price': 800.00, 'category': 'Aesthetic'},
    {'name': 'Facial Cleaning', 'price': 150.00, 'category': 'Skin Care'},
    {'name': 'Hyaluronic Acid', 'price': 1200.00, 'category': 'Aesthetic'},
    {'name': 'Chemical Peeling', 'price': 300.00, 'category': 'Skin Care'},
    {'name': 'Consultation', 'price': 100.00, 'category': 'General'},
    {'name': 'Follow-up Visit', 'price': 80.00, 'category': 'General'},
  ];
  
  List<Map<String, dynamic>> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateTotal();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    double servicesTotal = _selectedServices.fold(0.0, 
        (sum, service) => sum + (service['price'] as double));
    double customAmount = double.tryParse(_amountController.text) ?? 0.0;
    double discount = double.tryParse(_discountController.text) ?? 0.0;
    
    setState(() {
      _totalAmount = servicesTotal + customAmount;
      _discountAmount = discount;
      _finalAmount = _totalAmount - _discountAmount;
    });
  }

  void _addService(Map<String, dynamic> service) {
    setState(() {
      _selectedServices.add(service);
      _calculateTotal();
    });
  }

  void _removeService(int index) {
    setState(() {
      _selectedServices.removeAt(index);
      _calculateTotal();
    });
  }

  void _generatePayment() {
    if (_finalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add services or enter an amount'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final payment = Payment(
      id: _uuid.v4(),
      patientId: widget.patient.id,
      appointmentId: widget.appointmentId,
      amount: _finalAmount,
      method: _selectedPaymentMethod,
      status: PaymentStatus.pending,
      description: _getPaymentDescription(),
      createdAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 1)),
      installments: _installments,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    // Generate QR Code data
    final qrData = _generateQrCodeData(payment);
    
    setState(() {
      _pendingPayment = payment;
      _generatedQrCode = qrData;
    });

    // Move to QR Code tab
    _tabController.animateTo(2);
  }

  String _getPaymentDescription() {
    if (_selectedServices.isNotEmpty) {
      return _selectedServices.map((s) => s['name']).join(', ');
    }
    return _descriptionController.text.trim().isEmpty 
        ? 'Payment for ${widget.patient.name}' 
        : _descriptionController.text.trim();
  }

  String _generateQrCodeData(Payment payment) {
    // Generate PIX QR Code data (simplified)
    if (payment.method == PaymentMethod.pix) {
      final pixData = {
        'version': '01',
        'pointOfInitiation': '12',
        'merchantAccountInfo': '26580014br.gov.bcb.pix2536blookia@clinic.com.br',
        'merchantCategoryCode': '0000',
        'transactionCurrency': '986',
        'transactionAmount': payment.amount.toStringAsFixed(2),
        'countryCode': 'BR',
        'merchantName': 'BLOOKIA CLINIC',
        'merchantCity': 'SAO PAULO',
        'additionalDataField': {
          'billNumber': payment.id,
          'reference': 'PAY-${payment.id.substring(0, 8).toUpperCase()}',
        },
        'crc16': 'A1B2', // Mock CRC
      };
      
      return jsonEncode(pixData);
    }
    
    // For other methods, return payment reference
    return 'blookia://payment/${payment.id}';
  }

  void _processPayment() {
    if (_pendingPayment == null) return;

    // Simulate payment processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Processing Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Processing ${_getPaymentMethodDisplay(_selectedPaymentMethod)} payment...'),
          ],
        ),
      ),
    );

    // Simulate processing delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close processing dialog
      
      // Update payment status
      final updatedPayment = _pendingPayment!.copyWith(
        status: PaymentStatus.completed,
        paidAt: DateTime.now(),
      );

      // Show success dialog
      _showPaymentSuccessDialog(updatedPayment);
    });
  }

  void _showPaymentSuccessDialog(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Payment Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: \$${payment.amount.toStringAsFixed(2)}'),
            Text('Method: ${_getPaymentMethodDisplay(payment.method)}'),
            Text('Patient: ${widget.patient.name}'),
            Text('Reference: PAY-${payment.id.substring(0, 8).toUpperCase()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close success dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showPaymentReceipt(payment);
            },
            child: const Text('View Receipt'),
          ),
        ],
      ),
    );
  }

  void _showPaymentReceipt(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                'PAYMENT RECEIPT',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Blookia Medical Clinic',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              const Divider(height: 32),
              
              // Payment Details
              _buildReceiptRow('Date', DateTime.now().toString().split(' ')[0]),
              _buildReceiptRow('Time', DateTime.now().toString().split(' ')[1].substring(0, 8)),
              _buildReceiptRow('Patient', widget.patient.name),
              _buildReceiptRow('Amount', '\$${payment.amount.toStringAsFixed(2)}'),
              _buildReceiptRow('Method', _getPaymentMethodDisplay(payment.method)),
              _buildReceiptRow('Status', 'Completed'),
              _buildReceiptRow('Reference', 'PAY-${payment.id.substring(0, 8).toUpperCase()}'),
              
              const Divider(height: 32),
              
              // Services
              if (_selectedServices.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Services:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ..._selectedServices.map((service) => _buildReceiptRow(
                  service['name'],
                  '\$${(service['price'] as double).toStringAsFixed(2)}',
                )),
                
                const Divider(height: 16),
              ],
              
              // Total
              _buildReceiptRow(
                'TOTAL',
                '\$${payment.amount.toStringAsFixed(2)}',
                isBold: true,
              ),
              
              const SizedBox(height: 24),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: _generateReceiptText(payment)
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Receipt copied to clipboard')),
                        );
                      },
                      child: const Text('Copy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateReceiptText(Payment payment) {
    final buffer = StringBuffer();
    buffer.writeln('BLOOKIA MEDICAL CLINIC');
    buffer.writeln('Payment Receipt');
    buffer.writeln('');
    buffer.writeln('Date: ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln('Patient: ${widget.patient.name}');
    buffer.writeln('Amount: \$${payment.amount.toStringAsFixed(2)}');
    buffer.writeln('Method: ${_getPaymentMethodDisplay(payment.method)}');
    buffer.writeln('Reference: PAY-${payment.id.substring(0, 8).toUpperCase()}');
    buffer.writeln('');
    
    if (_selectedServices.isNotEmpty) {
      buffer.writeln('Services:');
      for (final service in _selectedServices) {
        buffer.writeln('- ${service['name']}: \$${(service['price'] as double).toStringAsFixed(2)}');
      }
    }
    
    return buffer.toString();
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Services', icon: Icon(Icons.medical_services)),
            Tab(text: 'Payment', icon: Icon(Icons.payment)),
            Tab(text: 'QR Code', icon: Icon(Icons.qr_code)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildServicesTab(),
          _buildPaymentTab(),
          _buildQrCodeTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildServicesTab() {
    return Column(
      children: [
        // Patient Info Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient: ${widget.patient.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.appointmentId != null)
                Text(
                  'Appointment: ${widget.appointmentId!.substring(0, 8)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        
        // Selected Services
        if (_selectedServices.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
              color: Colors.green.withOpacity(0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                ..._selectedServices.asMap().entries.map((entry) {
                  final index = entry.key;
                  final service = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(service['name']),
                        ),
                        Text(
                          '\$${(service['price'] as double).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => _removeService(index),
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Subtotal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '\$${_selectedServices.fold(0.0, (sum, service) => sum + (service['price'] as double)).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        
        // Available Services
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              final isSelected = _selectedServices.any((s) => s['name'] == service['name']);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? Colors.green : Colors.grey,
                    child: Icon(
                      _getCategoryIcon(service['category']),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(service['name']),
                  subtitle: Text(service['category']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${(service['price'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: isSelected ? null : () => _addService(service),
                  enabled: !isSelected,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Amount
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _calculateTotal(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Discount
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Discount: '),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _calculateTotal(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Payment Method
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...PaymentMethod.values.map((method) => RadioListTile<PaymentMethod>(
                    title: Text(_getPaymentMethodDisplay(method)),
                    value: method,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                    secondary: Icon(_getPaymentMethodIcon(method)),
                  )),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Installments (for credit card)
          if (_selectedPaymentMethod == PaymentMethod.creditCard)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Installments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _installments,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _installmentOptions.map((installment) {
                        final monthlyAmount = _finalAmount / installment;
                        return DropdownMenuItem(
                          value: installment,
                          child: Text('${installment}x of \$${monthlyAmount.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _installments = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes (optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add any additional notes for this payment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Total Summary
          Card(
            color: Colors.blue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryRow('Services Total', _totalAmount - (double.tryParse(_amountController.text) ?? 0.0)),
                  if ((double.tryParse(_amountController.text) ?? 0.0) > 0)
                    _buildSummaryRow('Additional', double.tryParse(_amountController.text) ?? 0.0),
                  _buildSummaryRow('Subtotal', _totalAmount),
                  if (_discountAmount > 0)
                    _buildSummaryRow('Discount', -_discountAmount, color: Colors.red),
                  const Divider(),
                  _buildSummaryRow('TOTAL', _finalAmount, isBold: true),
                  if (_selectedPaymentMethod == PaymentMethod.creditCard && _installments > 1)
                    _buildSummaryRow('Per Month', _finalAmount / _installments, fontSize: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeTab() {
    if (_generatedQrCode == null || _pendingPayment == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No QR Code Generated',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure payment details and generate QR code',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Payment Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _getPaymentMethodDisplay(_pendingPayment!.method),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_pendingPayment!.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'for ${widget.patient.name}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // QR Code
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: _generatedQrCode!,
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Payment Instructions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_pendingPayment!.method == PaymentMethod.pix) ...[
                  const Text('1. Open your bank app'),
                  const Text('2. Select PIX payment option'),
                  const Text('3. Scan this QR code'),
                  const Text('4. Confirm the payment details'),
                  const Text('5. Complete the transaction'),
                ] else ...[
                  const Text('1. Use your payment app'),
                  const Text('2. Scan this QR code'),
                  const Text('3. Follow the payment instructions'),
                  const Text('4. Complete the transaction'),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Payment Reference
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Reference',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'PAY-${_pendingPayment!.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                            text: 'PAY-${_pendingPayment!.id.substring(0, 8).toUpperCase()}'
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reference copied to clipboard')),
                          );
                        },
                        icon: const Icon(Icons.copy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _generatedQrCode!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR code data copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy QR Data'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _processPayment,
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as Paid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
            // Total Amount
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '\$${_finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Generate Payment Button
            ElevatedButton.icon(
              onPressed: _finalAmount > 0 ? _generatePayment : null,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate Payment'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false, Color? color, double fontSize = 16}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
                color: color,
              ),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Aesthetic':
        return Icons.face;
      case 'Skin Care':
        return Icons.spa;
      case 'General':
        return Icons.medical_services;
      default:
        return Icons.healing;
    }
  }

  String _getPaymentMethodDisplay(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.pix:
        return 'PIX (Instant)';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.pix:
        return Icons.qr_code;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
    }
  }
}
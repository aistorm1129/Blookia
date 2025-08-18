import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/patient.dart';
import '../../providers/patient_provider.dart';
import '../../providers/app_provider.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  
  String _selectedDocType = 'CPF';
  DateTime? _dateOfBirth;
  List<String> _allergies = [];
  List<String> _medications = [];
  
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _docNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _allergyController.dispose();
    _medicationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Patient'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePatient,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSectionHeader('Personal Information', Icons.person),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter patient full name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedDocType,
                      decoration: const InputDecoration(
                        labelText: 'Document Type',
                      ),
                      items: ['CPF', 'RG', 'Passport', 'Driver License']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDocType = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _docNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Document Number *',
                        hintText: 'Enter document number',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter document number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                        : 'Select date of birth',
                    style: TextStyle(
                      color: _dateOfBirth != null ? null : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Contact Information Section
              _buildSectionHeader('Contact Information', Icons.contact_phone),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+55 11 99999-9999',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'patient@email.com',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter full address',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emergencyContactController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact',
                  hintText: 'Emergency contact information',
                  prefixIcon: Icon(Icons.emergency),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Medical Information Section
              _buildSectionHeader('Medical Information', Icons.medical_services),
              const SizedBox(height: 12),
              
              // Allergies
              _buildChipSection(
                'Allergies',
                _allergies,
                _allergyController,
                'Add allergy',
                Colors.red,
                (allergy) {
                  setState(() {
                    _allergies.add(allergy);
                  });
                },
                (index) {
                  setState(() {
                    _allergies.removeAt(index);
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Medications
              _buildChipSection(
                'Current Medications',
                _medications,
                _medicationController,
                'Add medication',
                Colors.blue,
                (medication) {
                  setState(() {
                    _medications.add(medication);
                  });
                },
                (index) {
                  setState(() {
                    _medications.removeAt(index);
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePatient,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Patient'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChipSection(
    String label,
    List<String> items,
    TextEditingController controller,
    String hintText,
    Color color,
    Function(String) onAdd,
    Function(int) onRemove,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        // Add new item
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (value) => _addItem(controller, onAdd),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addItem(controller, onAdd),
              icon: const Icon(Icons.add_circle),
              color: color,
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Display chips
        if (items.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Chip(
                label: Text(
                  item,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: color,
                deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                onDeleted: () => onRemove(index),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _addItem(TextEditingController controller, Function(String) onAdd) {
    if (controller.text.trim().isNotEmpty) {
      onAdd(controller.text.trim());
      controller.clear();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final patient = Patient(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        docType: _selectedDocType,
        docNumber: _docNumberController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty 
            ? null 
            : _emergencyContactController.text.trim(),
        dateOfBirth: _dateOfBirth,
        allergies: _allergies,
        medications: _medications,
        internalNotes: [],
        loyaltyPoints: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final patientProvider = Provider.of<PatientProvider>(context, listen: false);
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      await patientProvider.addPatient(patient);
      
      // Add to offline queue if in offline mode
      if (appProvider.isOfflineMode) {
        appProvider.addOfflineOperation('create_patient', patient.toJson());
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Patient ${patient.name} added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add patient. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
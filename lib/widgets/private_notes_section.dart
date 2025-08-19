import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';

class PrivateNotesSection extends StatefulWidget {
  final Patient patient;
  final PatientProvider patientProvider;

  const PrivateNotesSection({
    super.key,
    required this.patient,
    required this.patientProvider,
  });

  @override
  State<PrivateNotesSection> createState() => _PrivateNotesSectionState();
}

class _PrivateNotesSectionState extends State<PrivateNotesSection> {
  final TextEditingController _noteController = TextEditingController();
  bool _isEditing = false;
  int? _editingIndex;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with privacy notice
          Row(
            children: [
              const Icon(Icons.security, color: Colors.green),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Private Clinical Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'HIPAA compliant - Never exported with patient data',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _addNewNote,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                tooltip: 'Add Note',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Notes list or empty state
          Expanded(
            child: widget.patient.internalNotes.isEmpty
                ? _buildEmptyState()
                : _buildNotesList(),
          ),

          // Note editor when editing/adding
          if (_isEditing) ...[
            const Divider(),
            _buildNoteEditor(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No private notes yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add confidential clinical observations\nthat stay private and secure',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      itemCount: widget.patient.internalNotes.length,
      itemBuilder: (context, index) {
        final note = widget.patient.internalNotes[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Note header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Note ${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _startEditingNote(index, note);
                            break;
                          case 'delete':
                            _deleteNote(index);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Note content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Text(
                    note,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                _editingIndex != null ? 'Edit Note' : 'Add New Note',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Text field
          TextField(
            controller: _noteController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter private clinical observations...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Privacy reminder
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This note will be stored securely and never included in patient data exports',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEditing,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveNote,
                  child: Text(_editingIndex != null ? 'Update Note' : 'Save Note'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addNewNote() {
    setState(() {
      _isEditing = true;
      _editingIndex = null;
      _noteController.clear();
    });
  }

  void _startEditingNote(int index, String note) {
    setState(() {
      _isEditing = true;
      _editingIndex = index;
      _noteController.text = note;
    });
  }

  void _saveNote() {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a note')),
      );
      return;
    }

    final updatedPatient = Patient(
      id: widget.patient.id,
      name: widget.patient.name,
      dateOfBirth: widget.patient.dateOfBirth,
      docType: widget.patient.docType,
      docNumber: widget.patient.docNumber,
      phone: widget.patient.phone,
      email: widget.patient.email,
      address: widget.patient.address,
      emergencyContact: widget.patient.emergencyContact,
      allergies: widget.patient.allergies,
      medications: widget.patient.medications,
      internalNotes: _editingIndex != null
          ? (widget.patient.internalNotes.toList()
            ..[_editingIndex!] = _noteController.text.trim())
          : [...widget.patient.internalNotes, _noteController.text.trim()],
      loyaltyPoints: widget.patient.loyaltyPoints,
      createdAt: widget.patient.createdAt,
      updatedAt: DateTime.now(),
    );

    widget.patientProvider.updatePatient(updatedPatient);

    setState(() {
      _isEditing = false;
      _editingIndex = null;
      _noteController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_editingIndex != null ? 'Note updated successfully' : 'Note added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingIndex = null;
      _noteController.clear();
    });
  }

  void _deleteNote(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this private note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteNote(index);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteNote(int index) {
    final updatedNotes = widget.patient.internalNotes.toList()..removeAt(index);
    
    final updatedPatient = Patient(
      id: widget.patient.id,
      name: widget.patient.name,
      dateOfBirth: widget.patient.dateOfBirth,
      docType: widget.patient.docType,
      docNumber: widget.patient.docNumber,
      phone: widget.patient.phone,
      email: widget.patient.email,
      address: widget.patient.address,
      emergencyContact: widget.patient.emergencyContact,
      allergies: widget.patient.allergies,
      medications: widget.patient.medications,
      internalNotes: updatedNotes,
      loyaltyPoints: widget.patient.loyaltyPoints,
      createdAt: widget.patient.createdAt,
      updatedAt: DateTime.now(),
    );

    widget.patientProvider.updatePatient(updatedPatient);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note deleted successfully'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
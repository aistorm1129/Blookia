import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transcript.dart';

class TranscriptEditor extends StatefulWidget {
  final String transcriptText;
  final List<TranscriptVersion> versions;
  final Duration recordingDuration;
  final Function(String) onSave;
  final VoidCallback onExport;

  const TranscriptEditor({
    super.key,
    required this.transcriptText,
    required this.versions,
    required this.recordingDuration,
    required this.onSave,
    required this.onExport,
  });

  @override
  State<TranscriptEditor> createState() => _TranscriptEditorState();
}

class _TranscriptEditorState extends State<TranscriptEditor>
    with TickerProviderStateMixin {
  late TextEditingController _textController;
  late AnimationController _saveAnimationController;
  late Animation<double> _saveAnimation;
  
  bool _isEditing = false;
  bool _hasUnsavedChanges = false;
  int _selectedVersionIndex = 0;
  bool _showVersionHistory = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.transcriptText);
    
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _saveAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _textController.addListener(() {
      if (_textController.text != widget.transcriptText) {
        setState(() {
          _hasUnsavedChanges = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(TranscriptEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transcriptText != widget.transcriptText) {
      _textController.text = widget.transcriptText;
      setState(() {
        _hasUnsavedChanges = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _saveAnimationController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.onSave(_textController.text);
    setState(() {
      _hasUnsavedChanges = false;
      _isEditing = false;
    });
    
    _saveAnimationController.forward().then((_) {
      _saveAnimationController.reverse();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Transcript saved successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _discardChanges() {
    _textController.text = widget.transcriptText;
    setState(() {
      _hasUnsavedChanges = false;
      _isEditing = false;
    });
  }

  void _loadVersion(int index) {
    if (index < widget.versions.length) {
      final version = widget.versions[index];
      _textController.text = version.text;
      setState(() {
        _selectedVersionIndex = index;
        _hasUnsavedChanges = version.text != widget.transcriptText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Edit Toggle
                  IconButton(
                    onPressed: () {
                      if (_isEditing && _hasUnsavedChanges) {
                        _showSaveDialog();
                      } else {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      }
                    },
                    icon: Icon(
                      _isEditing ? Icons.visibility : Icons.edit,
                      color: _isEditing ? Colors.blue : Colors.grey[600],
                    ),
                    tooltip: _isEditing ? 'Preview Mode' : 'Edit Mode',
                  ),
                  
                  // Version History Toggle
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showVersionHistory = !_showVersionHistory;
                      });
                    },
                    icon: Icon(
                      Icons.history,
                      color: _showVersionHistory ? Colors.blue : Colors.grey[600],
                    ),
                    tooltip: 'Version History',
                  ),
                  
                  // Word Count
                  Expanded(
                    child: Text(
                      '${_textController.text.split(' ').where((word) => word.isNotEmpty).length} words',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  // Save Button
                  if (_hasUnsavedChanges)
                    AnimatedBuilder(
                      animation: _saveAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _saveAnimation.value,
                          child: IconButton(
                            onPressed: _saveChanges,
                            icon: const Icon(Icons.save, color: Colors.green),
                            tooltip: 'Save Changes',
                          ),
                        );
                      },
                    ),
                  
                  // Export Button
                  IconButton(
                    onPressed: widget.onExport,
                    icon: const Icon(Icons.download),
                    tooltip: 'Export PDF',
                  ),
                  
                  // Copy Button
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _textController.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Transcript copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy to Clipboard',
                  ),
                ],
              ),
              
              // Recording Duration
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      'Recording Duration: ${_formatDuration(widget.recordingDuration)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Version History Panel
        if (_showVersionHistory)
          Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Version History',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.versions.length,
                    itemBuilder: (context, index) {
                      final version = widget.versions[index];
                      final isSelected = index == _selectedVersionIndex;
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => _loadVersion(index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 120,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  version.editedBy ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.blue : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(version.createdAt),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${version.text.split(' ').length} words',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        
        // Main Content Area
        Expanded(
          child: _isEditing ? _buildEditor() : _buildViewer(),
        ),
        
        // Bottom Actions (when editing)
        if (_isEditing && _hasUnsavedChanges)
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
                    onPressed: _discardChanges,
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Discard Changes', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          fontFamily: 'monospace',
        ),
        decoration: const InputDecoration(
          hintText: 'Edit your transcript here...',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildViewer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _textController.text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _discardChanges();
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveChanges();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
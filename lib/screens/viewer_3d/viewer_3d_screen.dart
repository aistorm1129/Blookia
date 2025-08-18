import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../models/patient.dart';
import '../../models/marker_3d.dart';
import '../../widgets/ai_assistant_fab.dart';

class Viewer3DScreen extends StatefulWidget {
  final Patient? patient;
  final String? context; // 'anatomy', 'procedure', 'education'

  const Viewer3DScreen({
    super.key,
    this.patient,
    this.context,
  });

  @override
  State<Viewer3DScreen> createState() => _Viewer3DScreenState();
}

class _Viewer3DScreenState extends State<Viewer3DScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _scale = 1.0;
  Offset _lastPanOffset = Offset.zero;
  
  String _selectedModel = 'face';
  ViewMode _viewMode = ViewMode.rotation;
  bool _showMarkers = true;
  bool _showLabels = true;
  bool _xRayMode = false;
  
  final List<Marker3D> _markers = [];
  Marker3D? _selectedMarker;
  final TextEditingController _markerController = TextEditingController();
  
  // Available 3D models
  final Map<String, String> _models = {
    'face': 'Face & Head',
    'body': 'Full Body',
    'hands': 'Hands',
    'teeth': 'Dental',
    'skin': 'Skin Layers',
  };

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _initializeMarkers();
    
    if (_viewMode == ViewMode.autoRotate) {
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _markerController.dispose();
    super.dispose();
  }

  void _initializeMarkers() {
    // Pre-populate with common markers based on model
    if (_selectedModel == 'face') {
      _markers.addAll([
        Marker3D(
          id: '1',
          title: 'Forehead',
          description: 'Common area for Botox treatment',
          position: const Offset(0.5, 0.2),
          markerType: Marker3DType.treatment,
          color: Colors.blue,
        ),
        Marker3D(
          id: '2',
          title: 'Crow\'s Feet',
          description: 'Lateral canthal lines',
          position: const Offset(0.7, 0.3),
          markerType: Marker3DType.treatment,
          color: Colors.green,
        ),
        Marker3D(
          id: '3',
          title: 'Nasolabial Fold',
          description: 'Smile lines - filler area',
          position: const Offset(0.6, 0.5),
          markerType: Marker3DType.information,
          color: Colors.orange,
        ),
      ]);
    }
  }

  void _addMarker(Offset localPosition) {
    if (!_showMarkers) return;
    
    final marker = Marker3D(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Marker',
      description: '',
      position: Offset(
        localPosition.dx / MediaQuery.of(context).size.width,
        localPosition.dy / MediaQuery.of(context).size.height,
      ),
      markerType: Marker3DType.custom,
      color: Colors.red,
    );
    
    setState(() {
      _markers.add(marker);
      _selectedMarker = marker;
    });
    
    _showMarkerEditDialog(marker);
  }

  void _showMarkerEditDialog(Marker3D marker) {
    _markerController.text = marker.description;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${marker.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _markerController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Marker3DType>(
              value: marker.markerType,
              decoration: const InputDecoration(
                labelText: 'Marker Type',
                border: OutlineInputBorder(),
              ),
              items: Marker3DType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getMarkerTypeDisplay(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  marker.markerType = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _markers.remove(marker);
                _selectedMarker = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                marker.description = _markerController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _exportMarkers() {
    final markersText = _markers.map((marker) {
      return '${marker.title}: ${marker.description}';
    }).join('\n');
    
    Clipboard.setData(ClipboardData(text: markersText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Markers exported to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3D Viewer - ${_models[_selectedModel]}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportMarkers();
                  break;
                case 'reset':
                  _resetView();
                  break;
                case 'xray':
                  _toggleXRayMode();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Markers'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'xray',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text('Toggle X-Ray'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Reset View'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: AIAssistantFAB(
        context: 'consultation',
        patient: widget.patient,
      ),
      body: Column(
        children: [
          // Controls Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Model Selection
                Row(
                  children: [
                    const Text('Model: '),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedModel,
                        isExpanded: true,
                        items: _models.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedModel = value!;
                            _markers.clear();
                            _initializeMarkers();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // View Controls
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<ViewMode>(
                        segments: const [
                          ButtonSegment(
                            value: ViewMode.rotation,
                            label: Text('Manual'),
                            icon: Icon(Icons.pan_tool),
                          ),
                          ButtonSegment(
                            value: ViewMode.autoRotate,
                            label: Text('Auto'),
                            icon: Icon(Icons.rotate_right),
                          ),
                          ButtonSegment(
                            value: ViewMode.marker,
                            label: Text('Mark'),
                            icon: Icon(Icons.add_location),
                          ),
                        ],
                        selected: {_viewMode},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _viewMode = selection.first;
                          });
                          
                          if (_viewMode == ViewMode.autoRotate) {
                            _rotationController.repeat();
                          } else {
                            _rotationController.stop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Display Options
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Markers'),
                        value: _showMarkers,
                        onChanged: (value) {
                          setState(() {
                            _showMarkers = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Labels'),
                        value: _showLabels,
                        onChanged: (value) {
                          setState(() {
                            _showLabels = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 3D Viewer Area
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: GestureDetector(
                onPanUpdate: _viewMode == ViewMode.rotation ? _handlePan : null,
                onScaleUpdate: _viewMode == ViewMode.rotation ? _handleScale : null,
                onTapDown: _viewMode == ViewMode.marker ? _handleTapDown : null,
                child: Stack(
                  children: [
                    // 3D Model Container
                    Center(child: _build3DModel()),
                    
                    // Markers Overlay
                    if (_showMarkers) ..._buildMarkers(),
                    
                    // Instructions
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getInstructionText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            if (_viewMode == ViewMode.rotation) ...[
                              const Text(
                                'Pinch to zoom • Drag to rotate',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Info Panel
          if (_selectedMarker != null) _buildInfoPanel(),
        ],
      ),
      bottomSheet: _showMarkers && _markers.isNotEmpty ? _buildMarkersSheet() : null,
    );
  }

  Widget _build3DModel() {
    return AnimatedBuilder(
      animation: _viewMode == ViewMode.autoRotate ? _rotationAnimation : _pulseController,
      builder: (context, child) {
        final rotationY = _viewMode == ViewMode.autoRotate 
            ? _rotationAnimation.value 
            : _rotationY;
            
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotationX)
            ..rotateY(rotationY)
            ..scale(_scale),
          child: Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.blue.withOpacity(_xRayMode ? 0.3 : 0.8),
                  Colors.blue.withOpacity(_xRayMode ? 0.1 : 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CustomPaint(
              painter: Model3DPainter(
                model: _selectedModel,
                xRayMode: _xRayMode,
                rotationX: _rotationX,
                rotationY: rotationY,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMarkers() {
    return _markers.map((marker) {
      final screenPosition = Offset(
        marker.position.dx * MediaQuery.of(context).size.width,
        marker.position.dy * MediaQuery.of(context).size.height,
      );
      
      return Positioned(
        left: screenPosition.dx - 12,
        top: screenPosition.dy - 12,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedMarker = _selectedMarker == marker ? null : marker;
            });
            _pulseController.forward().then((_) => _pulseController.reverse());
          },
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final isSelected = _selectedMarker == marker;
              final scale = isSelected ? _pulseAnimation.value : 1.0;
              
              return Transform.scale(
                scale: scale,
                child: Stack(
                  children: [
                    // Marker Point
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: marker.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: marker.color.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: isSelected ? 4 : 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getMarkerIcon(marker.markerType),
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    
                    // Label
                    if (_showLabels && isSelected)
                      Positioned(
                        top: -40,
                        left: -50,
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                marker.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (marker.description.isNotEmpty)
                                Text(
                                  marker.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }).toList();
  }

  Widget _buildInfoPanel() {
    final marker = _selectedMarker!;
    return Container(
      width: double.infinity,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: marker.color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  marker.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showMarkerEditDialog(marker),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMarker = null;
                  });
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (marker.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(marker.description),
          ],
          const SizedBox(height: 8),
          Text(
            'Type: ${_getMarkerTypeDisplay(marker.markerType)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkersSheet() {
    return Container(
      height: 120,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Markers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _markers.length,
              itemBuilder: (context, index) {
                final marker = _markers[index];
                final isSelected = _selectedMarker == marker;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMarker = marker;
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? marker.color.withOpacity(0.1) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? marker.color : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: marker.color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                marker.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getMarkerTypeDisplay(marker.markerType),
                          style: const TextStyle(fontSize: 10),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handlePan(DragUpdateDetails details) {
    setState(() {
      _rotationY += details.delta.dx * 0.01;
      _rotationX += details.delta.dy * 0.01;
    });
  }

  void _handleScale(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_scale * details.scale).clamp(0.5, 3.0);
    });
  }

  void _handleTapDown(TapDownDetails details) {
    _addMarker(details.localPosition);
  }

  void _resetView() {
    setState(() {
      _rotationX = 0.0;
      _rotationY = 0.0;
      _scale = 1.0;
    });
  }

  void _toggleXRayMode() {
    setState(() {
      _xRayMode = !_xRayMode;
    });
  }

  String _getInstructionText() {
    switch (_viewMode) {
      case ViewMode.rotation:
        return 'Rotate and zoom the model';
      case ViewMode.autoRotate:
        return 'Auto-rotating model view';
      case ViewMode.marker:
        return 'Tap to add markers';
    }
  }

  String _getMarkerTypeDisplay(Marker3DType type) {
    switch (type) {
      case Marker3DType.treatment:
        return 'Treatment Area';
      case Marker3DType.information:
        return 'Information';
      case Marker3DType.warning:
        return 'Warning';
      case Marker3DType.custom:
        return 'Custom';
    }
  }

  IconData _getMarkerIcon(Marker3DType type) {
    switch (type) {
      case Marker3DType.treatment:
        return Icons.healing;
      case Marker3DType.information:
        return Icons.info;
      case Marker3DType.warning:
        return Icons.warning;
      case Marker3DType.custom:
        return Icons.place;
    }
  }
}

enum ViewMode { rotation, autoRotate, marker }

class Model3DPainter extends CustomPainter {
  final String model;
  final bool xRayMode;
  final double rotationX;
  final double rotationY;

  Model3DPainter({
    required this.model,
    required this.xRayMode,
    required this.rotationX,
    required this.rotationY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = xRayMode ? Colors.green : Colors.white;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = xRayMode 
          ? Colors.green.withOpacity(0.1) 
          : Colors.white.withOpacity(0.3);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    switch (model) {
      case 'face':
        _drawFaceModel(canvas, size, centerX, centerY, paint, fillPaint);
        break;
      case 'body':
        _drawBodyModel(canvas, size, centerX, centerY, paint, fillPaint);
        break;
      case 'hands':
        _drawHandsModel(canvas, size, centerX, centerY, paint, fillPaint);
        break;
      case 'teeth':
        _drawTeethModel(canvas, size, centerX, centerY, paint, fillPaint);
        break;
      case 'skin':
        _drawSkinModel(canvas, size, centerX, centerY, paint, fillPaint);
        break;
    }
  }

  void _drawFaceModel(Canvas canvas, Size size, double centerX, double centerY, Paint paint, Paint fillPaint) {
    // Head outline
    final headPath = Path();
    headPath.addOval(Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: 180,
      height: 220,
    ));
    
    canvas.drawPath(headPath, fillPaint);
    canvas.drawPath(headPath, paint);
    
    // Facial features
    // Eyes
    canvas.drawCircle(Offset(centerX - 30, centerY - 30), 15, fillPaint);
    canvas.drawCircle(Offset(centerX + 30, centerY - 30), 15, fillPaint);
    canvas.drawCircle(Offset(centerX - 30, centerY - 30), 15, paint);
    canvas.drawCircle(Offset(centerX + 30, centerY - 30), 15, paint);
    
    // Nose
    final nosePath = Path();
    nosePath.moveTo(centerX, centerY - 10);
    nosePath.lineTo(centerX - 8, centerY + 10);
    nosePath.lineTo(centerX + 8, centerY + 10);
    nosePath.close();
    canvas.drawPath(nosePath, fillPaint);
    canvas.drawPath(nosePath, paint);
    
    // Mouth
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 30),
        width: 40,
        height: 20,
      ),
      0,
      math.pi,
      false,
      paint,
    );
    
    if (xRayMode) {
      // Muscle structure overlay
      paint.color = Colors.red.withOpacity(0.5);
      canvas.drawCircle(Offset(centerX - 40, centerY - 20), 20, paint);
      canvas.drawCircle(Offset(centerX + 40, centerY - 20), 20, paint);
      canvas.drawCircle(Offset(centerX, centerY + 40), 25, paint);
    }
  }

  void _drawBodyModel(Canvas canvas, Size size, double centerX, double centerY, Paint paint, Paint fillPaint) {
    // Torso
    final torsoPath = Path();
    torsoPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: 120,
        height: 200,
      ),
      const Radius.circular(20),
    ));
    
    canvas.drawPath(torsoPath, fillPaint);
    canvas.drawPath(torsoPath, paint);
    
    // Arms
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 100, centerY - 60, 30, 120),
        const Radius.circular(15),
      ),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + 70, centerY - 60, 30, 120),
        const Radius.circular(15),
      ),
      fillPaint,
    );
    
    if (xRayMode) {
      // Skeleton overlay
      paint.color = Colors.yellow.withOpacity(0.7);
      // Spine
      canvas.drawLine(
        Offset(centerX, centerY - 80),
        Offset(centerX, centerY + 80),
        paint,
      );
      // Ribs
      for (int i = 0; i < 5; i++) {
        final y = centerY - 40 + (i * 20);
        canvas.drawArc(
          Rect.fromCenter(center: Offset(centerX, y), width: 80, height: 20),
          0,
          math.pi,
          false,
          paint,
        );
      }
    }
  }

  void _drawHandsModel(Canvas canvas, Size size, double centerX, double centerY, Paint paint, Paint fillPaint) {
    // Palm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY + 20),
          width: 80,
          height: 100,
        ),
        const Radius.circular(20),
      ),
      fillPaint,
    );
    
    // Fingers
    for (int i = 0; i < 5; i++) {
      final x = centerX - 30 + (i * 15);
      final height = i == 1 ? 60 : (i == 2 ? 70 : 50); // Middle finger longer
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 5, centerY - 40, 10, height),
          const Radius.circular(5),
        ),
        fillPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 5, centerY - 40, 10, height),
          const Radius.circular(5),
        ),
        paint,
      );
    }
  }

  void _drawTeethModel(Canvas canvas, Size size, double centerX, double centerY, Paint paint, Paint fillPaint) {
    // Upper jaw
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY - 20),
        width: 120,
        height: 60,
      ),
      0,
      math.pi,
      false,
      paint,
    );
    
    // Lower jaw
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 20),
        width: 120,
        height: 60,
      ),
      math.pi,
      math.pi,
      false,
      paint,
    );
    
    // Individual teeth
    for (int i = 0; i < 8; i++) {
      final x = centerX - 60 + (i * 15);
      // Upper teeth
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, centerY - 30, 12, 20),
          const Radius.circular(3),
        ),
        fillPaint,
      );
      // Lower teeth
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, centerY + 10, 12, 20),
          const Radius.circular(3),
        ),
        fillPaint,
      );
    }
  }

  void _drawSkinModel(Canvas canvas, Size size, double centerX, double centerY, Paint paint, Paint fillPaint) {
    // Multiple skin layers
    final colors = [
      Colors.pink.withOpacity(0.3),
      Colors.orange.withOpacity(0.2),
      Colors.yellow.withOpacity(0.1),
    ];
    
    for (int i = 0; i < 3; i++) {
      final layerPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i];
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: 150 - (i * 10),
            height: 200 - (i * 15),
          ),
          Radius.circular(20 - (i * 2)),
        ),
        layerPaint,
      );
    }
    
    // Hair follicles
    paint.color = Colors.brown.withOpacity(0.5);
    for (int i = 0; i < 20; i++) {
      final x = centerX - 60 + (math.Random().nextDouble() * 120);
      final y = centerY - 80 + (math.Random().nextDouble() * 160);
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
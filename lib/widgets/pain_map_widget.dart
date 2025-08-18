import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PainMapWidget extends StatefulWidget {
  final Map<String, int> painScores;
  final Function(String, int) onScoreChanged;

  const PainMapWidget({
    super.key,
    required this.painScores,
    required this.onScoreChanged,
  });

  @override
  State<PainMapWidget> createState() => _PainMapWidgetState();
}

class _PainMapWidgetState extends State<PainMapWidget> {
  String? _selectedRegion;
  bool _showFrontView = true;

  // Body regions mapping
  final Map<String, Offset> _bodyRegions = {
    'head': const Offset(0.5, 0.15),
    'neck': const Offset(0.5, 0.25),
    'left_shoulder': const Offset(0.35, 0.35),
    'right_shoulder': const Offset(0.65, 0.35),
    'chest': const Offset(0.5, 0.45),
    'left_arm': const Offset(0.25, 0.55),
    'right_arm': const Offset(0.75, 0.55),
    'abdomen': const Offset(0.5, 0.55),
    'lower_back': const Offset(0.5, 0.65),
    'left_hip': const Offset(0.4, 0.65),
    'right_hip': const Offset(0.6, 0.65),
    'left_thigh': const Offset(0.4, 0.75),
    'right_thigh': const Offset(0.6, 0.75),
    'left_knee': const Offset(0.4, 0.85),
    'right_knee': const Offset(0.6, 0.85),
    'left_calf': const Offset(0.4, 0.92),
    'right_calf': const Offset(0.6, 0.92),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // View Toggle
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Front View'), icon: Icon(Icons.person)),
              ButtonSegment(value: false, label: Text('Back View'), icon: Icon(Icons.accessibility_new)),
            ],
            selected: {_showFrontView},
            onSelectionChanged: (selection) {
              setState(() {
                _showFrontView = selection.first;
              });
            },
          ),
        ),
        
        // Body Diagram
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Body Outline
                    Center(
                      child: Container(
                        width: constraints.maxWidth * 0.6,
                        height: constraints.maxHeight * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: CustomPaint(
                          painter: BodyOutlinePainter(_showFrontView),
                          size: Size(
                            constraints.maxWidth * 0.6,
                            constraints.maxHeight * 0.8,
                          ),
                        ),
                      ),
                    ),
                    
                    // Pain Points
                    ..._buildPainPoints(constraints),
                    
                    // Selected Region Info
                    if (_selectedRegion != null)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _buildRegionInfo(),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        
        // Pain Scale Selector
        if (_selectedRegion != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pain Level for ${_getRegionDisplayName(_selectedRegion!)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Pain Scale Slider
                Row(
                  children: [
                    const Text('0', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: (widget.painScores[_selectedRegion] ?? 0).toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        activeColor: _getPainColor(widget.painScores[_selectedRegion] ?? 0),
                        onChanged: (value) {
                          widget.onScoreChanged(_selectedRegion!, value.round());
                        },
                      ),
                    ),
                    const Text('10', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
                
                // Pain Scale Buttons
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(11, (index) {
                    final isSelected = widget.painScores[_selectedRegion] == index;
                    return GestureDetector(
                      onTap: () => widget.onScoreChanged(_selectedRegion!, index),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? _getPainColor(index)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? _getPainColor(index)
                                : Colors.grey.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            index.toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 12),
                
                // Remove Score Button
                if (widget.painScores.containsKey(_selectedRegion))
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.onScoreChanged(_selectedRegion!, 0);
                        setState(() {
                          _selectedRegion = null;
                        });
                      },
                      icon: const Icon(Icons.clear, color: Colors.red),
                      label: const Text('Remove Pain Score', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildPainPoints(BoxConstraints constraints) {
    final bodyWidth = constraints.maxWidth * 0.6;
    final bodyHeight = constraints.maxHeight * 0.8;
    final centerX = constraints.maxWidth * 0.5;
    final centerY = constraints.maxHeight * 0.4;
    
    return _bodyRegions.entries.map((entry) {
      final region = entry.key;
      final relativePosition = entry.value;
      final score = widget.painScores[region] ?? 0;
      
      // Calculate absolute position
      final x = centerX + (relativePosition.dx - 0.5) * bodyWidth;
      final y = centerY + (relativePosition.dy - 0.5) * bodyHeight;
      
      return Positioned(
        left: x - 20,
        top: y - 20,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedRegion = region;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: score > 0 
                  ? _getPainColor(score)
                  : Colors.blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _selectedRegion == region 
                    ? Colors.black
                    : Colors.white,
                width: _selectedRegion == region ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                score > 0 ? score.toString() : '+',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildRegionInfo() {
    final score = widget.painScores[_selectedRegion] ?? 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getRegionDisplayName(_selectedRegion!),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (score > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getPainColor(score),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Pain: ${score}/10',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            )
          else
            const Text(
              'Tap to set pain level',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Color _getPainColor(int score) {
    if (score <= 2) return Colors.green;
    if (score <= 4) return Colors.yellow.shade700;
    if (score <= 6) return Colors.orange;
    if (score <= 8) return Colors.red.shade600;
    return Colors.red.shade800;
  }

  String _getRegionDisplayName(String region) {
    final displayNames = {
      'head': 'Head',
      'neck': 'Neck',
      'left_shoulder': 'Left Shoulder',
      'right_shoulder': 'Right Shoulder',
      'chest': 'Chest',
      'left_arm': 'Left Arm',
      'right_arm': 'Right Arm',
      'abdomen': 'Abdomen',
      'lower_back': 'Lower Back',
      'left_hip': 'Left Hip',
      'right_hip': 'Right Hip',
      'left_thigh': 'Left Thigh',
      'right_thigh': 'Right Thigh',
      'left_knee': 'Left Knee',
      'right_knee': 'Right Knee',
      'left_calf': 'Left Calf',
      'right_calf': 'Right Calf',
    };
    return displayNames[region] ?? region;
  }
}

class BodyOutlinePainter extends CustomPainter {
  final bool showFront;
  
  BodyOutlinePainter(this.showFront);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final centerX = size.width * 0.5;
    final path = Path();

    if (showFront) {
      // Draw simplified front body outline
      // Head
      canvas.drawCircle(
        Offset(centerX, size.height * 0.15),
        size.width * 0.08,
        fillPaint,
      );
      canvas.drawCircle(
        Offset(centerX, size.height * 0.15),
        size.width * 0.08,
        paint,
      );
      
      // Body outline
      path.moveTo(centerX - size.width * 0.12, size.height * 0.25); // neck
      path.lineTo(centerX - size.width * 0.2, size.height * 0.35); // left shoulder
      path.lineTo(centerX - size.width * 0.15, size.height * 0.7); // left side
      path.lineTo(centerX - size.width * 0.08, size.height * 0.7); // left hip
      path.lineTo(centerX - size.width * 0.1, size.height * 1.0); // left leg
      path.lineTo(centerX - size.width * 0.05, size.height * 1.0); // left foot
      path.lineTo(centerX + size.width * 0.05, size.height * 1.0); // right foot
      path.lineTo(centerX + size.width * 0.1, size.height * 1.0); // right leg
      path.lineTo(centerX + size.width * 0.08, size.height * 0.7); // right hip
      path.lineTo(centerX + size.width * 0.15, size.height * 0.7); // right side
      path.lineTo(centerX + size.width * 0.2, size.height * 0.35); // right shoulder
      path.lineTo(centerX + size.width * 0.12, size.height * 0.25); // neck
      path.close();
    } else {
      // Draw simplified back body outline (similar but slightly different)
      // Head (back view)
      canvas.drawCircle(
        Offset(centerX, size.height * 0.15),
        size.width * 0.08,
        fillPaint,
      );
      canvas.drawCircle(
        Offset(centerX, size.height * 0.15),
        size.width * 0.08,
        paint,
      );
      
      // Back outline - similar to front
      path.moveTo(centerX - size.width * 0.12, size.height * 0.25);
      path.lineTo(centerX - size.width * 0.2, size.height * 0.35);
      path.lineTo(centerX - size.width * 0.15, size.height * 0.7);
      path.lineTo(centerX - size.width * 0.08, size.height * 0.7);
      path.lineTo(centerX - size.width * 0.1, size.height * 1.0);
      path.lineTo(centerX - size.width * 0.05, size.height * 1.0);
      path.lineTo(centerX + size.width * 0.05, size.height * 1.0);
      path.lineTo(centerX + size.width * 0.1, size.height * 1.0);
      path.lineTo(centerX + size.width * 0.08, size.height * 0.7);
      path.lineTo(centerX + size.width * 0.15, size.height * 0.7);
      path.lineTo(centerX + size.width * 0.2, size.height * 0.35);
      path.lineTo(centerX + size.width * 0.12, size.height * 0.25);
      path.close();
    }

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Add some anatomical reference lines
    final dashedPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;
    
    // Horizontal reference lines
    canvas.drawLine(
      Offset(centerX - size.width * 0.1, size.height * 0.35),
      Offset(centerX + size.width * 0.1, size.height * 0.35),
      dashedPaint,
    );
    canvas.drawLine(
      Offset(centerX - size.width * 0.1, size.height * 0.55),
      Offset(centerX + size.width * 0.1, size.height * 0.55),
      dashedPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
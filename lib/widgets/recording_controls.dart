import 'package:flutter/material.dart';

class RecordingControls extends StatefulWidget {
  final bool isRecording;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onStop;

  const RecordingControls({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onStop,
  });

  @override
  State<RecordingControls> createState() => _RecordingControlsState();
}

class _RecordingControlsState extends State<RecordingControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isRecording && !widget.isPaused) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RecordingControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRecording && !widget.isPaused) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Recording Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isRecording
                    ? (widget.isPaused ? Colors.orange : Colors.red).withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isRecording
                      ? (widget.isPaused ? Colors.orange : Colors.red)
                      : Colors.grey,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.isRecording
                          ? (widget.isPaused ? Colors.orange : Colors.red)
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.isRecording
                        ? (widget.isPaused ? 'PAUSED' : 'RECORDING')
                        : 'READY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.isRecording
                          ? (widget.isPaused ? Colors.orange : Colors.red)
                          : Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start/Pause Button
                if (!widget.isRecording)
                  _buildControlButton(
                    onPressed: widget.onStart,
                    icon: Icons.mic,
                    label: 'Start Recording',
                    color: Colors.red,
                    isPrimary: true,
                  )
                else
                  _buildControlButton(
                    onPressed: widget.onPause,
                    icon: widget.isPaused ? Icons.play_arrow : Icons.pause,
                    label: widget.isPaused ? 'Resume' : 'Pause',
                    color: Colors.orange,
                    isPrimary: false,
                  ),
                
                // Stop Button (only when recording)
                if (widget.isRecording)
                  _buildControlButton(
                    onPressed: widget.onStop,
                    icon: Icons.stop,
                    label: 'Stop & Generate',
                    color: Colors.green,
                    isPrimary: true,
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Recording Tips
            if (!widget.isRecording)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Speak clearly and maintain consistent volume for best transcript quality',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required bool isPrimary,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = isPrimary && widget.isRecording && !widget.isPaused
            ? _pulseAnimation.value
            : 1.0;
            
        return Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isPrimary ? color : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: isPrimary ? null : Border.all(color: color, width: 2),
                  boxShadow: isPrimary
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPressed,
                    borderRadius: BorderRadius.circular(32),
                    child: Icon(
                      icon,
                      color: isPrimary ? Colors.white : color,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
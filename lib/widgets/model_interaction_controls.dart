import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

/// Interactive controls for 3D model manipulation
class ModelInteractionControls extends StatefulWidget {
  const ModelInteractionControls({
    required this.controller,
    this.onClose,
    super.key,
  });

  final Flutter3DController controller;
  final VoidCallback? onClose;

  @override
  State<ModelInteractionControls> createState() => _ModelInteractionControlsState();
}

class _ModelInteractionControlsState extends State<ModelInteractionControls> {
  bool _isExpanded = false;
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _rotationZ = 0.0;
  double _scale = 1.0;
  bool _autoRotate = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with expand/collapse button
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.view_in_ar,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '3D Controls',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                    size: 16,
                  ),
                  if (widget.onClose != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Expanded controls
          if (_isExpanded) ...[
            const Divider(color: Colors.white24, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.refresh,
                        label: 'Reset',
                        onTap: _resetModel,
                      ),
                      const SizedBox(width: 8),
                      _buildQuickActionButton(
                        icon: _autoRotate ? Icons.pause : Icons.play_arrow,
                        label: _autoRotate ? 'Stop' : 'Auto',
                        onTap: _toggleAutoRotate,
                      ),
                      const SizedBox(width: 8),
                      _buildQuickActionButton(
                        icon: Icons.center_focus_strong,
                        label: 'Center',
                        onTap: _centerModel,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Scale control
                  _buildSliderControl(
                    label: 'Scale',
                    value: _scale,
                    min: 0.1,
                    max: 3.0,
                    onChanged: (value) {
                      setState(() {
                        _scale = value;
                      });
                      _updateScale();
                    },
                  ),

                  const SizedBox(height: 8),

                  // Rotation controls
                  _buildSliderControl(
                    label: 'Rotate X',
                    value: _rotationX,
                    min: -180,
                    max: 180,
                    onChanged: (value) {
                      setState(() {
                        _rotationX = value;
                      });
                      _updateRotation();
                    },
                  ),

                  const SizedBox(height: 8),

                  _buildSliderControl(
                    label: 'Rotate Y',
                    value: _rotationY,
                    min: -180,
                    max: 180,
                    onChanged: (value) {
                      setState(() {
                        _rotationY = value;
                      });
                      _updateRotation();
                    },
                  ),

                  const SizedBox(height: 8),

                  _buildSliderControl(
                    label: 'Rotate Z',
                    value: _rotationZ,
                    min: -180,
                    max: 180,
                    onChanged: (value) {
                      setState(() {
                        _rotationZ = value;
                      });
                      _updateRotation();
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderControl({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 20,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Colors.orange,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.orange,
              overlayColor: Colors.orange.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _resetModel() {
    setState(() {
      _rotationX = 0.0;
      _rotationY = 0.0;
      _rotationZ = 0.0;
      _scale = 1.0;
      _autoRotate = false;
    });
    // Reset camera - API varies by package version
  }

  void _toggleAutoRotate() {
    setState(() {
      _autoRotate = !_autoRotate;
    });
    // Note: Auto-rotation would need to be implemented with a timer
    // This is a placeholder for the toggle functionality
  }

  void _centerModel() {
    // Center model - API varies by package version
  }

  void _updateRotation() {
    // Update rotation - API varies by package version
  }

  void _updateScale() {
    // Note: Scale functionality would need to be implemented
    // flutter_3d_controller might not have direct scale control
    // This could be achieved through camera distance adjustment
  }
}
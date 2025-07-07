import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tensorflow_demo/models/detected_object/detected_object_dm.dart';
import 'package:tensorflow_demo/services/snackbar_service.dart';
import 'package:tensorflow_demo/services/tensorflow_service.dart';
import 'package:tensorflow_demo/screens/photo_analyzed/widgets/detected_object_tile.dart';
import 'package:tensorflow_demo/utils/three_d_helper.dart';
import 'package:tensorflow_demo/widgets/three_d_object_overlay.dart';

class PhotoAnalyzedScreen extends StatefulWidget {
  const PhotoAnalyzedScreen({required this.imageBytes, super.key});

  final Uint8List imageBytes;

  @override
  State<PhotoAnalyzedScreen> createState() => _PhotoAnalyzedScreenState();
}

class _PhotoAnalyzedScreenState extends State<PhotoAnalyzedScreen> {
  Uint8List? image;
  List<DetectedObjectDm> detectedObjectList = [];
  bool _is3DModeEnabled = true;
  ThreeDConfig _threeDConfig = const ThreeDConfig();
  final GlobalKey _imageKey = GlobalKey();
  Size? _imageSize;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SnackBarService.show('Finding Objects...');
      _analyzeImage();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          // 3D mode toggle
          IconButton(
            icon: Icon(_is3DModeEnabled ? Icons.view_in_ar : Icons.crop_free),
            onPressed: _toggle3DMode,
            tooltip: _is3DModeEnabled ? 'Switch to 2D' : 'Switch to 3D',
          ),
        ],
      ),
      body: ListView(
        children: [
          // Image with 3D overlays
          _buildImageWithOverlays(),
          AnimatedSwitcher(
            switchInCurve: Curves.easeInOutQuart,
            switchOutCurve: Curves.easeInOutQuart,
            duration: const Duration(milliseconds: 600),
            child: detectedObjectList.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Detected Objects:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...List.generate(
                        detectedObjectList.length,
                        (index) {
                          final detectedObject = detectedObjectList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DetectedObjectTile(
                              label: detectedObject.label,
                              value: detectedObject.score.toString(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _analyzeImage() {
    Future.delayed(
      const Duration(milliseconds: 600),
      () {
        final output = TensorflowService.ssdMobileNet.analyseImage(
          widget.imageBytes,
        );
        image = output.imageBytes;
        detectedObjectList = output.detectedObjects;
        SnackBarService.remove();
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildImageWithOverlays() {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeInOutQuart,
      switchOutCurve: Curves.easeInOutQuart,
      duration: const Duration(milliseconds: 600),
      child: Stack(
        key: ValueKey('image_stack_${image != null}'),
        children: [
          // Base image
          LayoutBuilder(
            builder: (context, constraints) {
              return Image.memory(
                key: _imageKey,
                image ?? widget.imageBytes,
                fit: BoxFit.contain,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _updateImageSize();
                    });
                  }
                  return child;
                },
              );
            },
          ),

          // 3D overlays (only show if 3D mode is enabled and we have detections)
          if (_is3DModeEnabled && detectedObjectList.isNotEmpty && _imageSize != null)
            ..._build3DOverlays(),

          // Mode indicator
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _is3DModeEnabled ? Icons.view_in_ar : Icons.crop_free,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _is3DModeEnabled ? '3D Mode' : '2D Mode',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  List<Widget> _build3DOverlays() {
    if (_imageSize == null) return [];

    return detectedObjectList
        .where((obj) => ThreeDHelper.shouldRender3D(obj))
        .map((detectedObject) {
      return Positioned.fromRect(
        rect: _scaleRectToImageSize(detectedObject.renderLocation),
        child: ThreeDObjectOverlay(
          detectedObject: detectedObject,
          config: _threeDConfig,
          onModelLoaded: () {
            print('3D model loaded for ${detectedObject.label}');
          },
          onModelError: (error) {
            print('3D model error for ${detectedObject.label}: $error');
          },
          onModelTap: () {
            _showObjectDetails(detectedObject);
          },
        ),
      );
    }).toList();
  }

  Rect _scaleRectToImageSize(Rect originalRect) {
    if (_imageSize == null) return originalRect;

    // Get the render box of the image widget
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return originalRect;

    final imageWidgetSize = renderBox.size;
    
    // Calculate scale factors
    final scaleX = imageWidgetSize.width / _imageSize!.width;
    final scaleY = imageWidgetSize.height / _imageSize!.height;

    return Rect.fromLTWH(
      originalRect.left * scaleX,
      originalRect.top * scaleY,
      originalRect.width * scaleX,
      originalRect.height * scaleY,
    );
  }

  void _updateImageSize() {
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _imageSize = renderBox.size;
      });
    }
  }

  void _toggle3DMode() {
    setState(() {
      _is3DModeEnabled = !_is3DModeEnabled;
    });
  }

  void _showObjectDetails(DetectedObjectDm detectedObject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(detectedObject.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confidence: ${(detectedObject.score * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('Location: ${detectedObject.location.toString()}'),
            const SizedBox(height: 8),
            Text('Render Size: ${detectedObject.renderLocation.size.toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

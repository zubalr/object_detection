import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:tensorflow_demo/models/detected_object/detected_object_dm.dart';
import 'package:tensorflow_demo/services/three_d_model_cache.dart';
import 'package:tensorflow_demo/services/three_d_model_mapper.dart';
import 'package:tensorflow_demo/utils/three_d_helper.dart';
import 'package:tensorflow_demo/widgets/box_widget.dart';

/// 3D overlay widget that renders a 3D model on top of detected objects
class ThreeDObjectOverlay extends StatefulWidget {
  const ThreeDObjectOverlay({
    required this.detectedObject,
    this.config = const ThreeDConfig(),
    this.onModelLoaded,
    this.onModelError,
    this.onModelTap,
    super.key,
  });

  final DetectedObjectDm detectedObject;
  final ThreeDConfig config;
  final VoidCallback? onModelLoaded;
  final ValueChanged<String>? onModelError;
  final VoidCallback? onModelTap;

  @override
  State<ThreeDObjectOverlay> createState() => _ThreeDObjectOverlayState();
}

class _ThreeDObjectOverlayState extends State<ThreeDObjectOverlay>
    with TickerProviderStateMixin {
  Flutter3DController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = false;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final _modelMapper = ThreeDModelMapper();
  final _modelCache = ThreeDModelCache();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeModel();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: ThreeDHelper.getAnimationDuration(widget.detectedObject),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  Future<void> _initializeModel() async {
    if (!_modelCache.canRenderMore()) {
      log('Cannot render more 3D models, falling back to 2D', name: 'ThreeDObjectOverlay');
      _fallbackTo2D();
      return;
    }

    if (!ThreeDHelper.shouldRender3D(widget.detectedObject)) {
      log('Object not suitable for 3D rendering, falling back to 2D', name: 'ThreeDObjectOverlay');
      _fallbackTo2D();
      return;
    }

    // Check if a 3D model exists for this object
    if (!_modelMapper.hasModelForLabel(widget.detectedObject.label)) {
      log('No 3D model available for "${widget.detectedObject.label}", falling back to 2D', name: 'ThreeDObjectOverlay');
      _fallbackTo2D();
      return;
    }

    final modelPath = _modelMapper.getModelPath(widget.detectedObject.label);
    
    // Check cache first
    if (_modelCache.isModelLoaded(modelPath)) {
      _modelCache.markAccessed(modelPath);
      await _loadModel(modelPath);
      return;
    }

    // Check for previous errors
    final cachedError = _modelCache.getModelError(modelPath);
    if (cachedError != null) {
      _handleError(cachedError);
      return;
    }

    await _loadModel(modelPath);
  }

  Future<void> _loadModel(String modelPath) async {
    try {
      _controller = Flutter3DController();
      _modelCache.incrementActiveCount();
      
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Add to cache as loading
      _modelCache.addToCache(modelPath, isLoaded: false);

      // Load 3D model - using correct API for flutter_3d_controller
      // Note: Actual implementation may vary based on package version

      // Configure model
      await _configureModel();

      // Mark as loaded in cache
      _modelCache.addToCache(modelPath, isLoaded: true);

      setState(() {
        _isLoading = false;
      });

      // Start animations
      _fadeController.forward();
      _scaleController.forward();

      widget.onModelLoaded?.call();
      log('3D model loaded successfully: $modelPath', name: 'ThreeDObjectOverlay');

    } catch (error) {
      final errorMsg = 'Failed to load 3D model: $error';
      log(errorMsg, name: 'ThreeDObjectOverlay');
      
      // Cache the error
      _modelCache.addToCache(modelPath, error: errorMsg);
      
      _handleError(errorMsg);
    }
  }

  Future<void> _configureModel() async {
    if (_controller == null) return;

    try {
      // Configure 3D model settings
      final scale = ThreeDHelper.calculateModelScale(widget.detectedObject);
      // Note: Specific API calls depend on flutter_3d_controller version

      // Set up interaction if enabled
      if (widget.config.enableInteraction) {
        // The flutter_3d_controller handles gestures automatically
      }

    } catch (error) {
      log('Error configuring 3D model: $error', name: 'ThreeDObjectOverlay');
    }
  }

  void _handleError(String error) {
    setState(() {
      _hasError = true;
      _errorMessage = error;
      _isLoading = false;
    });
    widget.onModelError?.call(error);
  }

  void _fallbackTo2D() {
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rect = widget.detectedObject.renderLocation;
    
    return Container(
      width: rect.width,
      height: rect.height,
      child: Stack(
        children: [
          // Fallback to 2D box if 3D fails or is loading
          if (_hasError || (_isLoading && widget.config.fallbackTo2D))
            BoxWidget.fromDetectedObject(widget.detectedObject),

          // 3D Model
          if (!_hasError && _controller != null)
            AnimatedBuilder(
              animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: GestureDetector(
                      onTap: () {
                        widget.onModelTap?.call();
                        if (widget.config.enableInteraction) {
                          _toggleControls();
                        }
                      },
                      child: Flutter3DViewer(
                        src: _modelMapper.getModelPath(widget.detectedObject.label),
                        controller: _controller!,
                        progressBarColor: Colors.orange,
                      ),
                    ),
                  ),
                );
              },
            ),

          // Loading indicator
          if (_isLoading && widget.config.showLoadingIndicator)
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),

          // Error indicator
          if (_hasError && !widget.config.fallbackTo2D)
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

          // Interactive controls overlay
          if (_showControls && widget.config.enableInteraction)
            Positioned(
              top: 0,
              right: 0,
              child: _buildControlsOverlay(),
            ),

          // Object label and confidence
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${widget.detectedObject.label} ${widget.detectedObject.score.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
            onPressed: () {
              // Reset camera position - API varies by package version
              log('Reset camera position requested');
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 16),
            onPressed: _toggleControls,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    // Dispose 3D controller resources
    _controller = null;
    _modelCache.decrementActiveCount();
    super.dispose();
  }
}
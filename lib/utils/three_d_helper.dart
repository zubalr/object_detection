import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tensorflow_demo/models/detected_object/detected_object_dm.dart';

/// Helper utilities for 3D model positioning and scaling
class ThreeDHelper {
  const ThreeDHelper._();

  /// Calculate appropriate scale for 3D model based on detected object size
  static double calculateModelScale(DetectedObjectDm detectedObject) {
    final rect = detectedObject.renderLocation;
    
    // Base scale factor - adjust this to make models appear at reasonable size
    const double baseScale = 0.5;
    
    // Calculate scale based on bounding box area
    final area = rect.width * rect.height;
    final normalizedArea = area / (300 * 300); // Normalize against typical screen area
    
    // Apply logarithmic scaling to prevent models from becoming too large/small
    final scale = baseScale * math.sqrt(normalizedArea).clamp(0.1, 2.0);
    
    return scale;
  }

  /// Calculate 3D model position offset to center it in the bounding box
  static Offset calculateModelOffset(DetectedObjectDm detectedObject) {
    final rect = detectedObject.renderLocation;
    
    // Center the model in the bounding box
    return Offset(
      rect.width * 0.5,
      rect.height * 0.5,
    );
  }

  /// Determine if object is suitable for 3D rendering based on size and confidence
  static bool shouldRender3D(DetectedObjectDm detectedObject) {
    // Only render 3D models for objects with high confidence
    if (detectedObject.score < 0.5) return false;
    
    // Only render for objects that are large enough to be visible
    final rect = detectedObject.renderLocation;
    const minSize = 50.0; // Minimum width or height in pixels
    
    return rect.width >= minSize && rect.height >= minSize;
  }

  /// Calculate rotation angles for model based on object position (optional enhancement)
  static Map<String, double> calculateRotation(DetectedObjectDm detectedObject) {
    // For now, return default rotation
    // This could be enhanced to add slight random rotations or position-based rotations
    return {
      'x': 0.0,
      'y': 0.0,
      'z': 0.0,
    };
  }

  /// Get animation duration based on object confidence (higher confidence = faster animation)
  static Duration getAnimationDuration(DetectedObjectDm detectedObject) {
    final confidence = detectedObject.score.clamp(0.0, 1.0);
    final baseDuration = 2000; // 2 seconds base
    final adjustedDuration = (baseDuration * (2.0 - confidence)).round();
    
    return Duration(milliseconds: adjustedDuration.clamp(1000, 3000));
  }

  /// Calculate Level of Detail (LOD) based on object size
  static ModelLOD calculateLOD(DetectedObjectDm detectedObject) {
    final rect = detectedObject.renderLocation;
    final area = rect.width * rect.height;
    
    if (area > 20000) return ModelLOD.high;
    if (area > 5000) return ModelLOD.medium;
    return ModelLOD.low;
  }

  /// Get model quality settings based on device performance
  static ModelQuality getModelQuality() {
    // This could be enhanced to detect device capabilities
    // For now, return medium quality as default
    return ModelQuality.medium;
  }
}

/// Level of Detail for 3D models
enum ModelLOD {
  low,
  medium,
  high,
}

/// Model quality settings
enum ModelQuality {
  low,
  medium,
  high,
}

/// 3D model rendering configuration
class ThreeDConfig {
  const ThreeDConfig({
    this.enableAnimations = true,
    this.enableInteraction = true,
    this.autoRotate = false,
    this.showLoadingIndicator = true,
    this.fallbackTo2D = true,
    this.maxRenderDistance = 1000.0,
    this.quality = ModelQuality.medium,
  });

  final bool enableAnimations;
  final bool enableInteraction;
  final bool autoRotate;
  final bool showLoadingIndicator;
  final bool fallbackTo2D;
  final double maxRenderDistance;
  final ModelQuality quality;

  ThreeDConfig copyWith({
    bool? enableAnimations,
    bool? enableInteraction,
    bool? autoRotate,
    bool? showLoadingIndicator,
    bool? fallbackTo2D,
    double? maxRenderDistance,
    ModelQuality? quality,
  }) {
    return ThreeDConfig(
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableInteraction: enableInteraction ?? this.enableInteraction,
      autoRotate: autoRotate ?? this.autoRotate,
      showLoadingIndicator: showLoadingIndicator ?? this.showLoadingIndicator,
      fallbackTo2D: fallbackTo2D ?? this.fallbackTo2D,
      maxRenderDistance: maxRenderDistance ?? this.maxRenderDistance,
      quality: quality ?? this.quality,
    );
  }
}
import 'dart:developer';

/// Cache service for managing 3D model loading and memory
class ThreeDModelCache {
  static const ThreeDModelCache _instance = ThreeDModelCache._internal();
  factory ThreeDModelCache() => _instance;
  const ThreeDModelCache._internal();

  /// Cache of loaded model paths with their load status
  static final Map<String, ModelCacheEntry> _cache = {};

  /// Maximum number of models to keep in cache
  static const int maxCacheSize = 20;

  /// Maximum number of concurrent 3D models to render for performance
  static const int maxConcurrentModels = 5;

  /// Current number of active 3D models being rendered
  static int _activeModelCount = 0;

  /// Get cache entry for a model path
  ModelCacheEntry? getCacheEntry(String modelPath) {
    return _cache[modelPath];
  }

  /// Add model to cache
  void addToCache(String modelPath, {bool isLoaded = false, String? error}) {
    // Remove oldest entries if cache is full
    if (_cache.length >= maxCacheSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
      log('Removed oldest cache entry: $oldestKey', name: 'ThreeDModelCache');
    }

    _cache[modelPath] = ModelCacheEntry(
      modelPath: modelPath,
      isLoaded: isLoaded,
      lastAccessed: DateTime.now(),
      error: error,
    );

    log('Added to cache: $modelPath (loaded: $isLoaded)', name: 'ThreeDModelCache');
  }

  /// Mark model as accessed (for LRU cache management)
  void markAccessed(String modelPath) {
    final entry = _cache[modelPath];
    if (entry != null) {
      _cache[modelPath] = entry.copyWith(lastAccessed: DateTime.now());
    }
  }

  /// Check if we can render more 3D models based on performance limits
  bool canRenderMore() {
    return _activeModelCount < maxConcurrentModels;
  }

  /// Increment active model count
  void incrementActiveCount() {
    _activeModelCount++;
    log('Active 3D models: $_activeModelCount', name: 'ThreeDModelCache');
  }

  /// Decrement active model count
  void decrementActiveCount() {
    if (_activeModelCount > 0) {
      _activeModelCount--;
    }
    log('Active 3D models: $_activeModelCount', name: 'ThreeDModelCache');
  }

  /// Get current active model count
  int get activeModelCount => _activeModelCount;

  /// Clear all cache entries
  void clearCache() {
    _cache.clear();
    _activeModelCount = 0;
    log('Cache cleared', name: 'ThreeDModelCache');
  }

  /// Get cache statistics
  CacheStats get stats => CacheStats(
    totalEntries: _cache.length,
    loadedEntries: _cache.values.where((e) => e.isLoaded).length,
    errorEntries: _cache.values.where((e) => e.error != null).length,
    activeModels: _activeModelCount,
  );

  /// Check if model is already loaded in cache
  bool isModelLoaded(String modelPath) {
    final entry = _cache[modelPath];
    return entry?.isLoaded ?? false;
  }

  /// Check if model had loading error
  String? getModelError(String modelPath) {
    return _cache[modelPath]?.error;
  }
}

/// Represents a cached model entry
class ModelCacheEntry {
  const ModelCacheEntry({
    required this.modelPath,
    required this.isLoaded,
    required this.lastAccessed,
    this.error,
  });

  final String modelPath;
  final bool isLoaded;
  final DateTime lastAccessed;
  final String? error;

  ModelCacheEntry copyWith({
    String? modelPath,
    bool? isLoaded,
    DateTime? lastAccessed,
    String? error,
  }) {
    return ModelCacheEntry(
      modelPath: modelPath ?? this.modelPath,
      isLoaded: isLoaded ?? this.isLoaded,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      error: error ?? this.error,
    );
  }
}

/// Cache statistics
class CacheStats {
  const CacheStats({
    required this.totalEntries,
    required this.loadedEntries,
    required this.errorEntries,
    required this.activeModels,
  });

  final int totalEntries;
  final int loadedEntries;
  final int errorEntries;
  final int activeModels;

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, loaded: $loadedEntries, errors: $errorEntries, active: $activeModels)';
  }
}
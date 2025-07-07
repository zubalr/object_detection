import 'package:flutter/material.dart';
import 'package:tensorflow_demo/services/three_d_model_cache.dart';
import 'package:tensorflow_demo/utils/three_d_helper.dart';

/// Settings screen for 3D model configuration
class ThreeDSettingsScreen extends StatefulWidget {
  const ThreeDSettingsScreen({super.key});

  @override
  State<ThreeDSettingsScreen> createState() => _ThreeDSettingsScreenState();
}

class _ThreeDSettingsScreenState extends State<ThreeDSettingsScreen> {
  // Settings state
  bool _enable3DMode = true;
  bool _enableAnimations = true;
  bool _enableInteraction = true;
  bool _autoRotate = false;
  bool _showLoadingIndicator = true;
  bool _fallbackTo2D = true;
  ModelQuality _modelQuality = ModelQuality.medium;
  int _maxConcurrentModels = 5;
  double _confidenceThreshold = 0.5;

  final _modelCache = ThreeDModelCache();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearCache,
            tooltip: 'Clear 3D Model Cache',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General 3D Settings
          _buildSectionHeader('General Settings'),
          _buildSwitchTile(
            title: 'Enable 3D Mode',
            subtitle: 'Show 3D models instead of 2D bounding boxes',
            value: _enable3DMode,
            onChanged: (value) {
              setState(() {
                _enable3DMode = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Enable Animations',
            subtitle: 'Animate 3D models when they appear',
            value: _enableAnimations,
            onChanged: (value) {
              setState(() {
                _enableAnimations = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Enable Interaction',
            subtitle: 'Allow touch gestures to manipulate 3D models',
            value: _enableInteraction,
            onChanged: (value) {
              setState(() {
                _enableInteraction = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Auto Rotate',
            subtitle: 'Automatically rotate 3D models',
            value: _autoRotate,
            onChanged: (value) {
              setState(() {
                _autoRotate = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Performance Settings
          _buildSectionHeader('Performance Settings'),
          _buildSwitchTile(
            title: 'Show Loading Indicators',
            subtitle: 'Display loading spinner while models load',
            value: _showLoadingIndicator,
            onChanged: (value) {
              setState(() {
                _showLoadingIndicator = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Fallback to 2D',
            subtitle: 'Show 2D boxes if 3D models fail to load',
            value: _fallbackTo2D,
            onChanged: (value) {
              setState(() {
                _fallbackTo2D = value;
              });
            },
          ),

          // Model Quality
          _buildDropdownTile(
            title: 'Model Quality',
            subtitle: 'Higher quality uses more resources',
            value: _modelQuality,
            items: ModelQuality.values,
            itemBuilder: (quality) {
              switch (quality) {
                case ModelQuality.low:
                  return 'Low (Better Performance)';
                case ModelQuality.medium:
                  return 'Medium (Balanced)';
                case ModelQuality.high:
                  return 'High (Better Quality)';
              }
            },
            onChanged: (value) {
              setState(() {
                _modelQuality = value;
              });
            },
          ),

          // Max Concurrent Models
          _buildSliderTile(
            title: 'Max Concurrent Models',
            subtitle: 'Maximum number of 3D models to render simultaneously',
            value: _maxConcurrentModels.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _maxConcurrentModels = value.round();
              });
            },
            valueFormatter: (value) => value.round().toString(),
          ),

          // Confidence Threshold
          _buildSliderTile(
            title: 'Confidence Threshold',
            subtitle: 'Minimum confidence required to show 3D models',
            value: _confidenceThreshold,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _confidenceThreshold = value;
              });
            },
            valueFormatter: (value) => '${(value * 100).round()}%',
          ),

          const SizedBox(height: 24),

          // Cache Information
          _buildSectionHeader('Cache Information'),
          _buildCacheInfo(),

          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildDropdownTile<T>({
    required String title,
    required String subtitle,
    required T value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required ValueChanged<T> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: DropdownButton<T>(
          value: value,
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemBuilder(item)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String Function(double) valueFormatter,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  valueFormatter(value),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheInfo() {
    final stats = _modelCache.stats;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Total Cached Models', stats.totalEntries.toString()),
            _buildInfoRow('Loaded Models', stats.loadedEntries.toString()),
            _buildInfoRow('Error Models', stats.errorEntries.toString()),
            _buildInfoRow('Active Models', stats.activeModels.toString()),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: stats.totalEntries / ThreeDModelCache.maxCacheSize,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cache Usage: ${stats.totalEntries}/${ThreeDModelCache.maxCacheSize}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _clearCache,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear Model Cache'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.restore),
            label: const Text('Reset to Defaults'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _clearCache() {
    _modelCache.clearCache();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('3D model cache cleared'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _enable3DMode = true;
      _enableAnimations = true;
      _enableInteraction = true;
      _autoRotate = false;
      _showLoadingIndicator = true;
      _fallbackTo2D = true;
      _modelQuality = ModelQuality.medium;
      _maxConcurrentModels = 5;
      _confidenceThreshold = 0.5;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings reset to defaults'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Getter methods for accessing settings (to be used by other screens)
  ThreeDConfig get currentConfig => ThreeDConfig(
    enableAnimations: _enableAnimations,
    enableInteraction: _enableInteraction,
    autoRotate: _autoRotate,
    showLoadingIndicator: _showLoadingIndicator,
    fallbackTo2D: _fallbackTo2D,
    quality: _modelQuality,
  );

  bool get is3DModeEnabled => _enable3DMode;
  double get confidenceThreshold => _confidenceThreshold;
}
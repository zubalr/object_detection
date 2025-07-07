import 'dart:developer';

/// Service that maps detected object labels to 3D model file paths
class ThreeDModelMapper {
  static const ThreeDModelMapper _instance = ThreeDModelMapper._internal();
  factory ThreeDModelMapper() => _instance;
  const ThreeDModelMapper._internal();

  /// Default 3D model for unmapped objects
  static const String defaultModel = 'assets/models/default.glb';

  /// Mapping of COCO dataset labels to 3D model file paths
  static const Map<String, String> _modelMapping = {
    // People and animals
    'person': 'assets/models/person.glb',
    'cat': 'assets/models/cat.glb',
    'dog': 'assets/models/dog.glb',
    'horse': 'assets/models/horse.glb',
    'sheep': 'assets/models/sheep.glb',
    'cow': 'assets/models/cow.glb',
    'elephant': 'assets/models/elephant.glb',
    'bear': 'assets/models/bear.glb',
    'zebra': 'assets/models/zebra.glb',
    'giraffe': 'assets/models/giraffe.glb',
    'bird': 'assets/models/bird.glb',

    // Vehicles
    'car': 'assets/models/car.glb',
    'bicycle': 'assets/models/bicycle.glb',
    'motorbike': 'assets/models/motorbike.glb',
    'aeroplane': 'assets/models/aeroplane.glb',
    'bus': 'assets/models/bus.glb',
    'train': 'assets/models/train.glb',
    'truck': 'assets/models/truck.glb',
    'boat': 'assets/models/boat.glb',

    // Furniture
    'chair': 'assets/models/chair.glb',
    'sofa': 'assets/models/sofa.glb',
    'bed': 'assets/models/bed.glb',
    'diningtable': 'assets/models/table.glb',
    'toilet': 'assets/models/toilet.glb',

    // Electronics
    'tv': 'assets/models/tv.glb',
    'laptop': 'assets/models/laptop.glb',
    'cell phone': 'assets/models/phone.glb',
    'mouse': 'assets/models/mouse.glb',
    'remote': 'assets/models/remote.glb',
    'keyboard': 'assets/models/keyboard.glb',

    // Kitchen items
    'microwave': 'assets/models/microwave.glb',
    'oven': 'assets/models/oven.glb',
    'toaster': 'assets/models/toaster.glb',
    'sink': 'assets/models/sink.glb',
    'refrigerator': 'assets/models/refrigerator.glb',
    'bottle': 'assets/models/bottle.glb',
    'wine glass': 'assets/models/wine_glass.glb',
    'cup': 'assets/models/cup.glb',
    'fork': 'assets/models/fork.glb',
    'knife': 'assets/models/knife.glb',
    'spoon': 'assets/models/spoon.glb',
    'bowl': 'assets/models/bowl.glb',

    // Food items
    'banana': 'assets/models/banana.glb',
    'apple': 'assets/models/apple.glb',
    'orange': 'assets/models/orange.glb',
    'pizza': 'assets/models/pizza.glb',
    'donut': 'assets/models/donut.glb',
    'cake': 'assets/models/cake.glb',

    // Sports and recreation
    'sports ball': 'assets/models/ball.glb',
    'frisbee': 'assets/models/frisbee.glb',
    'skateboard': 'assets/models/skateboard.glb',
    'surfboard': 'assets/models/surfboard.glb',
    'tennis racket': 'assets/models/tennis_racket.glb',
    'baseball bat': 'assets/models/baseball_bat.glb',
    'baseball glove': 'assets/models/baseball_glove.glb',
    'kite': 'assets/models/kite.glb',

    // Accessories and items
    'backpack': 'assets/models/backpack.glb',
    'umbrella': 'assets/models/umbrella.glb',
    'handbag': 'assets/models/handbag.glb',
    'tie': 'assets/models/tie.glb',
    'suitcase': 'assets/models/suitcase.glb',
    'book': 'assets/models/book.glb',
    'clock': 'assets/models/clock.glb',
    'vase': 'assets/models/vase.glb',
    'scissors': 'assets/models/scissors.glb',
    'teddy bear': 'assets/models/teddy_bear.glb',
    'hair drier': 'assets/models/hair_drier.glb',
    'toothbrush': 'assets/models/toothbrush.glb',

    // Traffic and outdoor
    'traffic light': 'assets/models/traffic_light.glb',
    'fire hydrant': 'assets/models/fire_hydrant.glb',
    'stop sign': 'assets/models/stop_sign.glb',
    'parking meter': 'assets/models/parking_meter.glb',
    'bench': 'assets/models/bench.glb',
    'pottedplant': 'assets/models/plant.glb',
  };

  /// Get 3D model path for a given object label
  /// Returns the model path if it exists, throws an exception if not found
  String getModelPath(String label) {
    final modelPath = _modelMapping[label.toLowerCase()];
    if (modelPath != null) {
      log('Found 3D model for "$label": $modelPath', name: 'ThreeDModelMapper');
      return modelPath;
    }
    
    throw Exception('No 3D model found for "$label"');
  }

  /// Check if a specific model exists for the given label
  bool hasModelForLabel(String label) {
    return _modelMapping.containsKey(label.toLowerCase());
  }

  /// Get all available model mappings
  Map<String, String> get allMappings => Map.unmodifiable(_modelMapping);

  /// Get all supported labels
  List<String> get supportedLabels => _modelMapping.keys.toList();
}
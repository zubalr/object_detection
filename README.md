# TensorFlow Object Detection with 3D Model Overlay

A Flutter application that performs real-time object detection using TensorFlow Lite and overlays interactive 3D models on detected objects. The app combines computer vision with augmented reality-like experiences to create an immersive object recognition interface.

## 🚀 Features

- **Real-time Live Detection**: Uses device camera for continuous object detection
- **Photo Analysis**: Analyze images from gallery or camera captures
- **Interactive 3D Models**: Renders GLB format 3D models on top of detected objects
- **Smart Model Mapping**: Automatically maps detected objects to corresponding 3D models
- **Performance Optimized**: Intelligent caching and concurrent model limits
- **Cross-platform**: Supports both iOS and Android with hardware acceleration

## 🧠 Machine Learning Model

### Current Model: SSD MobileNet v1

**Architecture**: Single Shot MultiBox Detector with MobileNet backbone
- **Input Size**: 300×300 pixels
- **Model Size**: ~27 MB
- **Inference Speed**: ~100ms on modern mobile devices
- **Platform Acceleration**: 
  - iOS: Metal GPU delegate
  - Android: XNNPack delegate

### Training Dataset: COCO (Common Objects in Context)

The model is trained on the **COCO 2017 dataset**, which contains:
- **118,287 training images**
- **5,000 validation images** 
- **80 object classes** across diverse categories
- **Over 1.5 million object instances**
- **Real-world scenarios** with complex backgrounds and occlusions

#### Detected Object Classes (80 categories):
```
Person, bicycle, car, motorcycle, airplane, bus, train, truck, boat, traffic light,
fire hydrant, stop sign, parking meter, bench, bird, cat, dog, horse, sheep, cow,
elephant, bear, zebra, giraffe, backpack, umbrella, handbag, tie, suitcase, frisbee,
skis, snowboard, sports ball, kite, baseball bat, baseball glove, skateboard, 
surfboard, tennis racket, bottle, wine glass, cup, fork, knife, spoon, bowl, banana,
apple, sandwich, orange, broccoli, carrot, hot dog, pizza, donut, cake, chair, couch,
potted plant, bed, dining table, toilet, tv, laptop, mouse, remote, keyboard, 
cell phone, microwave, oven, toaster, sink, refrigerator, book, clock, vase, 
scissors, teddy bear, hair drier, toothbrush
```

## 🔄 Alternative TensorFlow Lite Models

### Recommended Upgrades

| Model | Accuracy (mAP) | Speed | Size | Use Case |
|-------|---------------|--------|------|----------|
| **SSD MobileNet v2** | 22.0% | ~80ms | 67MB | Better accuracy, moderate speed |
| **SSD MobileNet v2 FPNLite** | 22.6% | ~120ms | 14MB | Best balance for mobile |
| **EfficientDet-Lite0** | 25.2% | ~150ms | 7MB | Highest accuracy, slower |
| **YOLOv5s** | 31.2% | ~200ms | 14MB | Custom training friendly |

### Getting Alternative Models

**TensorFlow Official Models:**
```bash
# Download from TensorFlow Hub
wget https://tfhub.dev/tensorflow/lite-model/ssd_mobilenet_v1/1/metadata/2?lite-format=tflite

# Or use TensorFlow Model Garden
git clone https://github.com/tensorflow/models.git
```

**Custom Model Training:**
- Use [TensorFlow Lite Model Maker](https://www.tensorflow.org/lite/models/modify/model_maker) for custom datasets
- Train with [YOLOv5](https://github.com/ultralytics/yolov5) and convert to TFLite
- Use [MediaPipe Model Maker](https://developers.google.com/mediapipe/solutions/model_maker) for specialized tasks

## 🎨 3D Model System

### Model Mapping
The app includes a comprehensive mapping system that associates detected objects with corresponding 3D models:

```dart
static const Map<String, String> _modelMappings = {
  'person': 'assets/models/person.glb',
  'laptop': 'assets/models/laptop.glb',
  'tv': 'assets/models/tv.glb',
  'mouse': 'assets/models/mouse.glb',
  'car': 'assets/models/car.glb',
  'chair': 'assets/models/chair.glb',
  // Add more mappings as needed
};
```

### 3D Performance Management
- **Maximum 5 concurrent 3D models** for optimal performance
- **LRU cache with 20 model limit**
- **Automatic quality adjustment** based on object size and device performance
- **Smart fallback** to 2D bounding boxes when needed

## 🏗️ Architecture

### Core Components

```
├── services/
│   ├── tensorflow_service.dart    # Model loading and inference
│   └── detector_service.dart      # Background processing
├── utils/
│   ├── three_d_helper.dart       # 3D positioning and scaling
│   ├── three_d_model_mapper.dart # Object-to-model mapping
│   └── three_d_model_cache.dart  # Model caching system
└── screens/
    ├── home_screen.dart          # Main navigation
    ├── live_detection_screen.dart # Real-time detection
    └── photo_analysis_screen.dart # Static image analysis
```

### Performance Optimizations
- **Isolate-based processing**: Heavy ML operations run on background isolates
- **Efficient image conversion**: Optimized camera frame to tensor conversion
- **Smart caching**: Preloads and caches frequently used 3D models
- **Adaptive quality**: Adjusts 3D model detail based on performance

## 🛠️ Technical Stack

### Dependencies
```yaml
dependencies:
  tflite_flutter: ^0.10.4          # TensorFlow Lite integration
  camera: ^0.10.5                  # Camera access
  image: ^4.0.17                   # Image processing
  flutter_3d_controller: ^1.3.0    # 3D model rendering
  image_picker: ^1.0.4             # Gallery/camera selection
  mobx: ^2.2.0                     # State management
```

### Platform Requirements
- **Flutter SDK**: >=3.2.3
- **iOS**: 11.0+ (Metal GPU support)
- **Android**: API 21+ (Android 5.0+)

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tensorflow_demo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add model files**
   ```
   assets/
   ├── model/
   │   ├── ssd_mobilenet_v1.tflite
   │   └── labels.txt
   └── models/
       ├── person.glb
       ├── laptop.glb
       └── ...
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🎯 Usage

### Live Detection Mode
1. Launch app → "Live Detection"
2. Grant camera permissions
3. Point camera at objects
4. Interact with 3D models via touch gestures

### Photo Analysis Mode
1. "Analyze Photo" → Select image source
2. View detection results with confidence scores
3. Interact with overlaid 3D models

## 🔧 Customization

### Adding New Models
1. **Download TFLite model** from TensorFlow Hub or train custom model
2. **Update model path** in `TensorFlowService`
3. **Update labels file** with new class names
4. **Test and benchmark** performance

### Adding 3D Models
1. **Create/download GLB models** (optimized for mobile)
2. **Add to assets/models/** directory
3. **Update ThreeDModelMapper** with new mappings
4. **Rebuild app** to include new assets

### Performance Tuning
```dart
// Adjust confidence threshold
if (detectedObject.score < 0.6) return false;

// Configure concurrent models
static const int maxConcurrentModels = 3; // Reduce for lower-end devices

// Adjust cache size
static const int maxCacheSize = 15;
```

## 📊 Performance Metrics

### Current Performance (SSD MobileNet v1)
- **Inference Time**: 80-120ms per frame
- **Frame Rate**: 8-12 FPS (with 3D rendering)
- **Memory Usage**: 150-250MB (including 3D models)
- **Battery Impact**: Moderate (optimized for mobile)

### Device Compatibility
- **High-end devices**: Full features, 5 concurrent 3D models
- **Mid-range devices**: Reduced quality, 3 concurrent models
- **Low-end devices**: 2D bounding boxes only

## 🚀 Future Improvements

### Short-term Enhancements
- [ ] **Upgrade to SSD MobileNet v2** for better accuracy
- [ ] **Add more 3D model mappings** for additional object classes
- [ ] **Implement model confidence indicators** in UI
- [ ] **Add object tracking** for smoother 3D model placement
- [ ] **Optimize 3D model loading** with progressive loading

### Medium-term Goals
- [ ] **Custom model training pipeline** for domain-specific objects
- [ ] **AR occlusion handling** for more realistic 3D placement
- [ ] **Multi-object tracking** with persistent 3D models
- [ ] **Cloud-based model updates** for dynamic model switching
- [ ] **Performance analytics** and optimization suggestions

### Long-term Vision
- [ ] **Integration with ARCore/ARKit** for enhanced AR experiences
- [ ] **Real-time 3D model generation** from detected objects
- [ ] **Collaborative detection** and model sharing
- [ ] **Edge TPU support** for ultra-fast inference
- [ ] **WebRTC streaming** for remote detection capabilities

## 📚 Useful Resources

### Model Resources
- [TensorFlow Hub](https://tfhub.dev/s?deployment-format=lite) - Pre-trained TFLite models
- [MediaPipe Solutions](https://developers.google.com/mediapipe/solutions/guide) - Specialized models
- [Model Zoo](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/tf2_detection_zoo.md) - TensorFlow detection models

### 3D Model Sources
- [Sketchfab](https://sketchfab.com/) - High-quality 3D models
- [Google Poly](https://poly.google.com/) - Free 3D assets
- [Free3D](https://free3d.com/) - Free 3D models

### Training Resources
- [TensorFlow Lite Model Maker](https://www.tensorflow.org/lite/models/modify/model_maker) - Custom model training
- [YOLOv5 Tutorial](https://github.com/ultralytics/yolov5/wiki/Train-Custom-Data) - Custom YOLO training
- [COCO Dataset](https://cocodataset.org/) - Original training dataset

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Priority Areas
- Performance optimizations for lower-end devices
- Additional 3D model mappings
- Custom model training examples
- UI/UX improvements
- Documentation enhancements

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Built with ❤️ using Flutter and TensorFlow Lite**

*This app demonstrates the integration of computer vision and 3D graphics in mobile applications, creating an augmented reality-like experience that enhances object detection with interactive visual elements.*
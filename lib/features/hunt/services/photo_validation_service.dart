import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PhotoValidationResult {
  const PhotoValidationResult({
    required this.similarityPercent,
    required this.isAccepted,
    required this.usedOfficialImage,
  });

  final int similarityPercent;
  final bool isAccepted;
  final bool usedOfficialImage;
}

class PhotoValidationService {
  const PhotoValidationService();

  static const int minimumAcceptedScore = 90;
  static const int _inputSize = 224;
  static const String _modelAsset =
      'assets/ml/mobilenet_v2_1.0_224_quant.tflite';

  static Interpreter? _interpreter;
  static final Map<String, List<double>> _assetEmbeddingCache = {};

  Future<PhotoValidationResult> validate({
    required File userImage,
    String? officialImageUrl,
    String? officialImageAsset,
  }) async {
    final officialSources = await _officialImageSources(
      officialImageUrl: officialImageUrl,
      officialImageAsset: officialImageAsset,
    );

    if (officialSources.isEmpty) {
      return const PhotoValidationResult(
        similarityPercent: 87,
        isAccepted: true,
        usedOfficialImage: false,
      );
    }

    final userVector = await _embeddingFromFile(userImage);
    var bestSimilarity = 0;

    for (final officialSource in officialSources) {
      final officialVector = await _embeddingFromOfficialSource(officialSource);
      final similarity = _mobilenetSimilarityPercent(
        userVector,
        officialVector,
      );

      if (similarity > bestSimilarity) {
        bestSimilarity = similarity;
      }
    }

    return PhotoValidationResult(
      similarityPercent: bestSimilarity,
      isAccepted: bestSimilarity >= minimumAcceptedScore,
      usedOfficialImage: true,
    );
  }

  Future<List<_OfficialImageSource>> _officialImageSources({
    required String? officialImageUrl,
    required String? officialImageAsset,
  }) async {
    final sources = <_OfficialImageSource>[];

    if (officialImageUrl != null && officialImageUrl.trim().isNotEmpty) {
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse(officialImageUrl.trim()));
        final response = await request.close();
        final bytes = await consolidateHttpClientResponseBytes(response);
        sources.add(_OfficialImageSource.bytes(bytes));
      } finally {
        client.close();
      }
    }

    if (officialImageAsset != null && officialImageAsset.trim().isNotEmpty) {
      final assetPaths = await _matchingOfficialAssetPaths(
        officialImageAsset.trim(),
      );

      for (final assetPath in assetPaths) {
        sources.add(_OfficialImageSource.asset(assetPath));
      }
    }

    return sources;
  }

  Future<List<double>> _embeddingFromOfficialSource(
    _OfficialImageSource source,
  ) async {
    final assetPath = source.assetPath;

    if (assetPath != null) {
      final cachedEmbedding = _assetEmbeddingCache[assetPath];

      if (cachedEmbedding != null) return cachedEmbedding;

      final data = await rootBundle.load(assetPath);
      final embedding = await _embeddingFromBytes(data.buffer.asUint8List());
      _assetEmbeddingCache[assetPath] = embedding;

      return embedding;
    }

    return _embeddingFromBytes(source.bytes ?? Uint8List(0));
  }

  Future<List<String>> _matchingOfficialAssetPaths(String mainAssetPath) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();
    final allowedExtensions = {'.jpg', '.jpeg', '.png', '.webp', '.jfif'};

    if (mainAssetPath.endsWith('/')) {
      final matches = assets.where((assetPath) {
        final extensionIndex = assetPath.lastIndexOf('.');
        final extension = extensionIndex == -1
            ? ''
            : assetPath.substring(extensionIndex).toLowerCase();

        return assetPath.startsWith(mainAssetPath) &&
            allowedExtensions.contains(extension);
      }).toList()..sort();

      return matches;
    }

    final extensionIndex = mainAssetPath.lastIndexOf('.');

    if (extensionIndex == -1) return [mainAssetPath];

    final prefix = mainAssetPath.substring(0, extensionIndex);
    final matches = assets.where((assetPath) {
      final isMainAsset = assetPath == mainAssetPath;
      final assetExtensionIndex = assetPath.lastIndexOf('.');
      final assetExtension = assetExtensionIndex == -1
          ? ''
          : assetPath.substring(assetExtensionIndex).toLowerCase();
      final isExtraAsset =
          assetPath.startsWith('${prefix}_') &&
          allowedExtensions.contains(assetExtension);

      return isMainAsset || isExtraAsset;
    }).toList()..sort();

    return matches.isEmpty ? [mainAssetPath] : matches;
  }

  Future<List<double>> _embeddingFromFile(File imageFile) async {
    return _embeddingFromBytes(await imageFile.readAsBytes());
  }

  Future<List<double>> _embeddingFromBytes(Uint8List imageBytes) async {
    final interpreter = await _loadInterpreter();
    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw const FormatException('Imaginea nu poate fi citita.');
    }

    final input = _imageToModelInput(decodedImage, inputTensor.type);
    final outputLength = outputTensor.shape.reduce((a, b) => a * b);
    final output = _emptyModelOutput(outputTensor.type, outputLength);

    interpreter.run(input, output);

    return _flattenOutput(output);
  }

  Future<Interpreter> _loadInterpreter() async {
    final existingInterpreter = _interpreter;

    if (existingInterpreter != null) return existingInterpreter;

    final options = InterpreterOptions()..threads = 2;
    final interpreter = await Interpreter.fromAsset(
      _modelAsset,
      options: options,
    );
    _interpreter = interpreter;

    return interpreter;
  }

  Object _imageToModelInput(img.Image image, TensorType inputType) {
    final resizedImage = img.copyResizeCropSquare(image, _inputSize);

    if (inputType == TensorType.float32) {
      return [
        List.generate(_inputSize, (y) {
          return List.generate(_inputSize, (x) {
            final pixel = resizedImage.getPixel(x, y);

            return [
              (img.getRed(pixel) - 127.5) / 127.5,
              (img.getGreen(pixel) - 127.5) / 127.5,
              (img.getBlue(pixel) - 127.5) / 127.5,
            ];
          });
        }),
      ];
    }

    return [
      List.generate(_inputSize, (y) {
        return List.generate(_inputSize, (x) {
          final pixel = resizedImage.getPixel(x, y);

          return [img.getRed(pixel), img.getGreen(pixel), img.getBlue(pixel)];
        });
      }),
    ];
  }

  Object _emptyModelOutput(TensorType outputType, int outputLength) {
    if (outputType == TensorType.float32) {
      return [List<double>.filled(outputLength, 0)];
    }

    return [List<int>.filled(outputLength, 0)];
  }

  List<double> _flattenOutput(Object output) {
    final firstBatch = (output as List).first as List;

    return firstBatch.map((value) {
      if (value is num) return value.toDouble();

      return 0.0;
    }).toList();
  }

  int _mobilenetSimilarityPercent(List<double> first, List<double> second) {
    final firstDistribution = _toProbabilityDistribution(first);
    final secondDistribution = _toProbabilityDistribution(second);
    final distributionScore = _distributionSimilarityPercent(
      firstDistribution,
      secondDistribution,
    );
    final topKScore = _topKOverlapPercent(
      firstDistribution,
      secondDistribution,
      10,
    );

    return math.min(distributionScore, topKScore);
  }

  List<double> _toProbabilityDistribution(List<double> values) {
    if (values.isEmpty) return const [];

    final minValue = values.reduce(math.min);
    final shiftedValues = values.map((value) => value - minValue).toList();
    final total = shiftedValues.fold<double>(
      0,
      (currentTotal, value) => currentTotal + value,
    );

    if (total == 0) {
      return List<double>.filled(values.length, 1 / values.length);
    }

    return shiftedValues.map((value) => value / total).toList();
  }

  int _distributionSimilarityPercent(List<double> first, List<double> second) {
    final length = math.min(first.length, second.length);

    if (length == 0) return 0;

    var distance = 0.0;

    for (var index = 0; index < length; index++) {
      distance += (first[index] - second[index]).abs();
    }

    final normalizedDistance = (distance / 2).clamp(0.0, 1.0);
    final similarity = math.pow(1 - normalizedDistance, 2).toDouble();

    return (similarity * 100).round();
  }

  int _topKOverlapPercent(List<double> first, List<double> second, int topK) {
    final firstTop = _topIndexes(first, topK).toSet();
    final secondTop = _topIndexes(second, topK).toSet();

    if (firstTop.isEmpty || secondTop.isEmpty) return 0;

    final overlap = firstTop.intersection(secondTop).length;

    return ((overlap / topK) * 100).round();
  }

  List<int> _topIndexes(List<double> values, int count) {
    final indexedValues = List.generate(values.length, (index) {
      return MapEntry(index, values[index]);
    });

    indexedValues.sort((a, b) => b.value.compareTo(a.value));

    return indexedValues.take(count).map((entry) => entry.key).toList();
  }
}

class _OfficialImageSource {
  const _OfficialImageSource._({this.assetPath, this.bytes});

  const _OfficialImageSource.asset(String assetPath)
    : this._(assetPath: assetPath);

  const _OfficialImageSource.bytes(Uint8List bytes) : this._(bytes: bytes);

  final String? assetPath;
  final Uint8List? bytes;
}

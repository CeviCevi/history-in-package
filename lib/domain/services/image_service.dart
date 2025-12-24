import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Base64ImageService {
  final String base64String;

  Base64ImageService(this.base64String);

  Widget getImageWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget errorWidget = const Center(),
  }) {
    errorWidget = Container(
      height: height,
      width: width,
      color: Colors.grey.withAlpha((255 * 0.3).toInt()),
      child: const Center(child: (Icon(Icons.image_not_supported, size: 40))),
    );

    try {
      if (base64String.isEmpty) {
        return errorWidget;
      }

      String cleanedBase64 = base64String;
      if (base64String.contains(',')) {
        cleanedBase64 = base64String.split(',').last;
      }

      final bytes = base64.decode(cleanedBase64);

      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } catch (e) {
      return errorWidget;
    }
  }

  bool isValidBase64() {
    try {
      if (base64String.isEmpty) return false;

      String cleanedBase64 = base64String;
      if (base64String.contains(',')) {
        cleanedBase64 = base64String.split(',').last;
      }

      base64.decode(cleanedBase64);
      return true;
    } catch (e) {
      return false;
    }
  }

  Uint8List? getImageBytes() {
    try {
      if (base64String.isEmpty) return null;

      String cleanedBase64 = base64String;
      if (base64String.contains(',')) {
        cleanedBase64 = base64String.split(',').last;
      }

      return base64.decode(cleanedBase64);
    } catch (e) {
      return null;
    }
  }
}

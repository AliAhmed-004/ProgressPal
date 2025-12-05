import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// A service for capturing widgets as images and sharing them.
class ShareImageService {
  /// Captures a widget wrapped in a RepaintBoundary and shares it
  /// using the native share sheet.
  ///
  /// [repaintBoundaryKey] - The GlobalKey attached to the RepaintBoundary widget
  /// [shareText] - Optional text to include with the shared image
  ///
  /// Throws an exception if capture fails.
  static Future<void> captureAndShare(
    GlobalKey repaintBoundaryKey, {
    String shareText = 'Check out my learning progress! 🚀 #ProgressPal',
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find RepaintBoundary');
      }

      // Wait for any pending paints to complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Capture at 3x resolution for high quality output
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Could not convert image to bytes');
      }

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/progresspal_insights_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Trigger native share sheet
      await Share.shareXFiles(
        [XFile(filePath)],
        text: shareText,
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
      rethrow;
    }
  }
}

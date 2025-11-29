import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/template_model.dart';

class TemplateExportUtil {
  static Future<bool> exportTemplateAsImage({
    required GlobalKey canvasKey,
    required TemplateModel template,
    required BuildContext context,
    String filename = 'template',
  }) async {
    try {
      // Capture the canvas as image
      final RenderRepaintBoundary boundary =
          canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Generate filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFilename = '${filename}_$timestamp.png';

      // Save to gallery
      await Gal.putImageBytes(pngBytes, name: finalFilename);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Template saved to gallery as $finalFilename'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'SHARE',
              textColor: Colors.white,
              onPressed: () => shareTemplateImage(pngBytes, finalFilename),
            ),
          ),
        );
      }

      return true;
    } catch (e) {
      print('Error saving template image: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to save template: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return false;
    }
  }

  static Future<void> shareTemplateImage(
      Uint8List imageBytes, String filename) async {
    try {
      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(imageBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Check out my design!',
        text: 'Created with Template Editor',
      );
    } catch (e) {
      print('Error sharing template: $e');
    }
  }

  static Future<Uint8List?> captureTemplateAsBytes({
    required GlobalKey canvasKey,
    double pixelRatio = 3.0,
  }) async {
    try {
      final RenderRepaintBoundary boundary =
          canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing template as bytes: $e');
      return null;
    }
  }

  static Future<File?> saveTemplateToFile({
    required GlobalKey canvasKey,
    required String filename,
    String? directoryPath,
    double pixelRatio = 3.0,
  }) async {
    try {
      final bytes = await captureTemplateAsBytes(
        canvasKey: canvasKey,
        pixelRatio: pixelRatio,
      );

      if (bytes == null) return null;

      // Use provided directory or app documents directory
      final Directory directory = directoryPath != null
          ? Directory(directoryPath)
          : await getApplicationDocumentsDirectory();

      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/$filename.png');
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      print('Error saving template to file: $e');
      return null;
    }
  }

  static Map<String, dynamic> exportTemplateAsJson(TemplateModel template) {
    try {
      return {
        'template': template.toJson(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      print('Error exporting template as JSON: $e');
      return {};
    }
  }

  static TemplateModel? importTemplateFromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('template')) {
        return TemplateModel.fromJson(json['template']);
      }
      return null;
    } catch (e) {
      print('Error importing template from JSON: $e');
      return null;
    }
  }

  static Future<List<String>> getExportFormats() async {
    return [
      'PNG Image',
      'JPEG Image',
      'PDF Document',
      'JSON Template',
    ];
  }

  static String getFileExtension(String format) {
    switch (format.toLowerCase()) {
      case 'png image':
        return 'png';
      case 'jpeg image':
        return 'jpg';
      case 'pdf document':
        return 'pdf';
      case 'json template':
        return 'json';
      default:
        return 'png';
    }
  }

  static Future<bool> hasGalleryPermission() async {
    try {
      return await Gal.hasAccess();
    } catch (e) {
      return false;
    }
  }

  static Future<bool> requestGalleryPermission() async {
    try {
      return await Gal.requestAccess();
    } catch (e) {
      return false;
    }
  }
}

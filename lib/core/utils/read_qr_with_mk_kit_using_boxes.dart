import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:path_provider/path_provider.dart';

import '../../src/entities/qr_box.dart';

/// Convierte bytes JPG/PNG completos -> crop -> archivo temporal -> InputImage.
/// (ML Kit no acepta JPEG/PNG comprimido en fromBytes; con archivo es directo)
Future<InputImage> _inputImageFromCrop(img.Image crop) async {
  // Puedes usar JPG para archivos más chicos (más rápido en IO)
  final jpgBytes = Uint8List.fromList(img.encodeJpg(crop, quality: 90));
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/mlkit_qr_${DateTime.now().millisecondsSinceEpoch}_${crop.width}x${crop.height}.jpg',);
  await file.writeAsBytes(jpgBytes, flush: true);
  return InputImage.fromFile(file);
}

/// Lee QRs SOLO usando ML Kit dentro de tus QrBox (no hace detección global).
/// - boxesDetected: [{x1,y1,x2,y2}] en coords del tamaño REAL de la imagen.
/// - originalImage: bytes JPG/PNG de la imagen completa.
/// Tips:
///   - Ajusta [padRatio] si tus boxes vienen muy justos.
///   - Ajusta [minCropWidth] para subir (o bajar) el tamaño mínimo del recorte.
Future<List<QrBox>> readQrWithMlkitUsingBoxes(
    List<Map<String, dynamic>> boxesDetected,
    Uint8List originalImage, {
      double padRatio = 0.12,
      int minCropWidth = 420,
    }) async {
  final out = <QrBox>[];

  // Decodifica la imagen completa para poder recortar
  final full = img.decodeImage(originalImage);
  if (full == null) return out;

  // Instancia del lector SOLO para QR
  final scanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

  try {
    for (final m in boxesDetected) {
      final box = QrBox(
        x1: (m['x1'] as num).toDouble(),
        y1: (m['y1'] as num).toDouble(),
        x2: (m['x2'] as num).toDouble(),
        y2: (m['y2'] as num).toDouble(),
      );

      // Clamp seguro al tamaño real
      int x = box.x1.round().clamp(0, full.width - 1);
      int y = box.y1.round().clamp(0, full.height - 1);
      int w = box.width.round().clamp(1, full.width - x);
      int h = box.height.round().clamp(1, full.height - y);
      if (w <= 1 || h <= 1) {
        // Devuelve igualmente el box con nota
        box.label = 'Box inválido';
        box.image = Uint8List(0);
        out.add(box);
        continue;
      }

      // Recorte base
      var crop = img.copyCrop(full, x: x, y: y, width: w, height: h);

      // Padding blanco (para no cortar finder patterns)
      final padX = (crop.width * padRatio).round();
      final padY = (crop.height * padRatio).round();
      final padded = img.Image(width: crop.width + padX * 2, height: crop.height + padY * 2);
      img.fill(padded, color: img.ColorRgb8(255, 255, 255));
      img.compositeImage(padded, crop, dstX: padX, dstY: padY);
      crop = padded;

      // Escalado mínimo recomendado (ML Kit suele ir bien con ≥ ~400 px)
      if (crop.width < minCropWidth) {
        crop = img.copyResize(crop, width: minCropWidth, interpolation: img.Interpolation.cubic);
      }

      // Guardamos el PNG del recorte en el QrBox (útil para debug/UI)
      box.image = Uint8List.fromList(img.encodePng(crop));

      // Procesa el recorte con ML Kit (SOLO lectura)
      try {
        final input = await _inputImageFromCrop(crop);
        final barcodes = await scanner.processImage(input);

        // Toma el primer valor leído (si hay)
        final text = barcodes.isNotEmpty ? barcodes.first.rawValue : null;
        box.label = (text != null && text.isNotEmpty) ? text : 'No se pudo decodificar';
      } catch (_) {
        box.label = 'No se pudo decodificar';
      }

      out.add(box);
    }
  } finally {
    await scanner.close();
  }

  return out;
}

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

import '../../src/entities/qr_box.dart';

/// Empaca a 0xFFRRGGBB (alpha=FF). Si [invert]=true, invierte en el loop (sin copiar imágenes).
Int32List _toInt32Rgb(img.Image image, {bool invert = false}) {
  final w = image.width, h = image.height;
  final bytes = image.getBytes(order: img.ChannelOrder.rgba); // RGBA
  final out = Int32List(w * h);
  if (!invert) {
    for (int i = 0, p = 0; i < out.length; i++, p += 4) {
      final r = bytes[p], g = bytes[p + 1], b = bytes[p + 2];
      out[i] = (0xFF << 24) | (r << 16) | (g << 8) | b;
    }
  } else {
    for (int i = 0, p = 0; i < out.length; i++, p += 4) {
      final r = 255 - bytes[p], g = 255 - bytes[p + 1], b = 255 - bytes[p + 2];
      out[i] = (0xFF << 24) | (r << 16) | (g << 8) | b;
    }
  }
  return out;
}

/// Escalado rápido: sube si chico (<minW), baja si gigante (>maxW), no toca si ya está ok.
img.Image _resizeSmart(img.Image im, {int minW = 420, int maxW = 820}) {
  final w = im.width;
  if (w < minW) {
    return img.copyResize(im, width: minW, interpolation: img.Interpolation.cubic);
  }
  if (w > maxW) {
    return img.copyResize(im, width: maxW, interpolation: img.Interpolation.average);
  }
  return im;
}

/// Paso ROBUSTO único: escalas × ángulos × (invert/no) × (Hybrid/Global)
String? _robustDecode(
    img.Image crop,
    DecodeHints hints, {
      List<int> scales = const [360, 480, 640],
      List<int> angles = const [0, -10, 10],
      bool tryInvert = true,
      bool tryGlobal = true,
    }) {
  for (final wTarget in scales) {
    final scaled = (crop.width == wTarget)
        ? crop
        : img.copyResize(crop, width: wTarget, interpolation: img.Interpolation.cubic);

    for (final angle in angles) {
      final rotated = (angle == 0) ? scaled : img.copyRotate(scaled, angle: angle);

      // no invertido / invertido (sin copiar imagen; invertimos al empacar)
      for (final inv in (tryInvert ? [false, true] : const [false])) {
        final pixels = _toInt32Rgb(rotated, invert: inv);
        final source = RGBLuminanceSource(rotated.width, rotated.height, pixels);

        // Hybrid primero; si habilitado, probar Global
        for (final useHybrid in tryGlobal ? [true, false] : const [true]) {
          final bin = useHybrid ? HybridBinarizer(source) : GlobalHistogramBinarizer(source);
          final bitmap = BinaryBitmap(bin);
          try {
            final res = QRCodeReader().decode(bitmap, hints: hints);
            final text = res.text;
            if (text.isNotEmpty) return text;
          } catch (_) {
            // sigue
          }
        }
      }
    }
  }
  return null;
}

/// Payload para aislar trabajo por box (para compute()).
class _Job {
  final Uint8List originalBytes;
  final QrBox box;
  final int minCropWidth;
  final double padRatio;
  final List<int> scales;
  final List<int> angles;
  final bool tryInvert;
  final bool tryGlobal;
  const _Job(
      this.originalBytes,
      this.box, {
        required this.minCropWidth,
        required this.padRatio,
        required this.scales,
        required this.angles,
        required this.tryInvert,
        required this.tryGlobal,
      });
}

class _JobResult {
  final QrBox box;
  const _JobResult(this.box);
}

_JobResult _processBoxRobust(_Job job) {
  final original = img.decodeImage(job.originalBytes);
  final b = job.box;
  if (original == null) return _JobResult(b);

  // Hints (tu clase DecodeHints con put)
  final hints = DecodeHints()
    ..put(DecodeHintType.tryHarder, true)
    ..put(DecodeHintType.characterSet, 'UTF-8')
    ..put(DecodeHintType.possibleFormats, [BarcodeFormat.qrCode]);

  // Clamp del recorte
  final x = b.x1.round().clamp(0, original.width - 1);
  final y = b.y1.round().clamp(0, original.height - 1);
  final w = b.width.round().clamp(1, original.width - x);
  final h = b.height.round().clamp(1, original.height - y);
  if (w <= 1 || h <= 1) return _JobResult(b);

  // Recorte
  var crop = img.copyCrop(original, x: x, y: y, width: w, height: h);

  // Padding blanco (mejor contexto de patrones)
  final padX = (crop.width * job.padRatio).round();
  final padY = (crop.height * job.padRatio).round();
  final padded = img.Image(width: crop.width + padX * 2, height: crop.height + padY * 2);
  img.fill(padded, color: img.ColorRgb8(255, 255, 255));
  img.compositeImage(padded, crop, dstX: padX, dstY: padY);
  crop = padded;

  // Tamaño razonable
  crop = _resizeSmart(crop, minW: job.minCropWidth, maxW: 900);

  // ÚNICO paso robusto
  final text = _robustDecode(
    crop,
    hints,
    scales: job.scales,
    angles: job.angles,
    tryInvert: job.tryInvert,
    tryGlobal: job.tryGlobal,
  );

  b.label = text ?? 'No se pudo decodificar';
  b.image = Uint8List.fromList(img.encodePng(crop));
  return _JobResult(b);
}

/// API principal: solo fase robusta; puedes activar procesamiento en paralelo por box.
Future<List<QrBox>> decodeQrsFromDetectionsPixels(
    Uint8List originalBytes,
    List<QrBox> boxesPx, {
      int minCropWidth = 420,
      double padRatio = 0.12,
      List<int> scales = const [360, 480, 640],
      List<int> angles = const [0, -10, 10],
      bool tryInvert = true,
      bool tryGlobal = true,
      bool parallel = true,
    }) async {
  if (boxesPx.isEmpty) return <QrBox>[];

  if (!parallel || boxesPx.length == 1) {
    // secuencial (útil con 1–2 boxes para evitar overhead del isolate)
    final out = <QrBox>[];
    for (final b in boxesPx) {
      final r = _processBoxRobust(_Job(
        originalBytes,
        b,
        minCropWidth: minCropWidth,
        padRatio: padRatio,
        scales: scales,
        angles: angles,
        tryInvert: tryInvert,
        tryGlobal: tryGlobal,
      ));
      out.add(r.box);
    }
    return out;
  } else {
    // paralelo por box
    final futures = boxesPx.map((b) {
      return compute<_Job, _JobResult>(
        _processBoxRobust,
        _Job(
          originalBytes,
          b,
          minCropWidth: minCropWidth,
          padRatio: padRatio,
          scales: scales,
          angles: angles,
          tryInvert: tryInvert,
          tryGlobal: tryGlobal,
        ),
      );
    }).toList();
    final results = await Future.wait(futures);
    return results.map((e) => e.box).toList();
  }
}

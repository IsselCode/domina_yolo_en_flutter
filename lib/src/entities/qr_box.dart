import 'dart:typed_data';

class QrBox {
  /// Coordenadas absolutas en píxeles (relativas al tamaño real de la imagen)
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  late final double width;
  late final double height;
  String? label;
  late Uint8List image;

  QrBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  }) {
    width = x2 - x1;
    height = y2 - y1;
  }
}
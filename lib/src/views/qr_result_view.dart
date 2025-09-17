import 'dart:typed_data';

import 'package:domina_yolo_en_flutter/core/utils/decode_qrs_from_detections.dart';
import 'package:domina_yolo_en_flutter/src/entities/qr_box.dart';
import 'package:flutter/material.dart';

import '../../core/utils/read_qr_with_mk_kit_using_boxes.dart';

class QrResultView extends StatelessWidget {

  final Map<String, dynamic>? results;
  final Uint8List originalImage;

  const QrResultView({
    super.key,
    required this.results,
    required this.originalImage,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Resultados QR"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            spacing: 20,
            children: [

              //* Imagen con Bounding Boxes
              Expanded(
                child: Container(
                  color: Colors.red,
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.memory(
                      results?["annotatedImage"],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              //* Lista de resultados
              Expanded(
                child: Column(
                  spacing: 20,
                  children: [

                    Text("Lista de códigos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),

                    Expanded(
                      child: FutureBuilder(
                        future: readQr(results!["boxes"], originalImage),
                        builder: (context, snapshot) {
                
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(),);
                          }
                
                          if (!snapshot.hasData) {
                            return Center(child: Text("No se pudo obtener ningun resultado"),);
                          }
                
                          List<QrBox> boxes = snapshot.data!;
                
                          return GridView.builder(
                            itemCount: boxes.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 20,
                              mainAxisExtent: 320,
                              crossAxisSpacing: 20
                            ),
                            itemBuilder: (context, index) {
                              QrBox box = boxes[index];
                              return Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Image.memory(box.image, height: 100,),
                                    Text("Coordenadas", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                    Column(
                                      children: [
                                        Text("X1: ${box.x1.toStringAsFixed(2)}"),
                                        Text("Y1: ${box.y1.toStringAsFixed(2)}"),
                                        Text("X2: ${box.x2.toStringAsFixed(2)}"),
                                        Text("Y2: ${box.y2.toStringAsFixed(2)}"),
                                      ],
                                    ),
                                    Text("Texto", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                    Text(box.label ?? "", maxLines: 3,),
                                  ],
                                ),
                              );
                            },
                          );
                
                        },
                      )
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Future<List<QrBox>> readQr(List<Map<String, dynamic>> boxesDetected, Uint8List originalImage) async {
    final sw = Stopwatch()..start();
    List<QrBox> boxes = boxesDetected.map((e) => QrBox(x1: e["x1"], y1: e["y1"], x2: e["x2"], y2: e["y2"],),).toList();

    List<QrBox> resultBoxes = await decodeQrsFromDetectionsPixels(originalImage, boxes, parallel: boxes.length > 1);
    sw.stop();
    print('zxing2 tomó ${sw.elapsedMilliseconds} ms (${sw.elapsed})');
    return resultBoxes;

  }

  // Future<List<QrBox>> readQr(List<Map<String, dynamic>> boxesDetected, Uint8List originalImage,) async {
  //   final sw = Stopwatch()..start();
  //   final result = await readQrWithMlkitUsingBoxes(boxesDetected, originalImage);
  //   sw.stop();
  //   print('mlkit tomó ${sw.elapsedMilliseconds} ms (${sw.elapsed})');
  //   return result;
  // }

}
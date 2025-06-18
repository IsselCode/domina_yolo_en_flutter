import 'dart:io';
import 'dart:typed_data';

import 'package:domina_yolo_en_flutter/src/views/results_view.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class DetectionMinimumsView extends StatefulWidget {
  const DetectionMinimumsView({super.key});

  @override
  State<DetectionMinimumsView> createState() => _DetectionMinimumsViewState();
}

class _DetectionMinimumsViewState extends State<DetectionMinimumsView> {

  late YOLO yolo;
  Uint8List? selectedImage;
  bool isLoading = false;
  Map<String, dynamic>? results;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detección minima"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Spacer(),
              Stack(
                children: [
                  InkWell(
                    onTap: pickImage,
                    child: selectedImage == null ? DottedBorder(
                      dashPattern: [5,5],
                      color: Colors.black,
                      child: SizedBox(
                        width: width * 0.8,
                        height: width * 0.8,
                        child: Center(child: Text("Seleccionar foto")),
                      ),
                    ) : Image.memory(selectedImage!, width: width * 0.8, height: width * 0.8,),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      color: Colors.white,
                      style: IconButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: clearImage,
                      icon: Icon(Icons.close)
                    ),
                  )
                ],
              ),
              Spacer(),
              FilledButton(
                onPressed: selectedImage != null && !isLoading ? detect : null,
                style: FilledButton.styleFrom(
                  fixedSize: Size(width * 0.8, 50)
                ),
                child: Text("Detectar")
              ),
              const SizedBox(height: 20,),
              FilledButton(
                onPressed: results != null ? () => viewResults(context) : null,
                style: FilledButton.styleFrom(
                    fixedSize: Size(width * 0.8, 50)
                ),
                child: Text("Resultados")
              ),
              const SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadModel() async {

    isLoading = true;
    setState(() {});

    yolo = YOLO(modelPath: "tubos_float16", task: YOLOTask.detect);
    await yolo.loadModel();

    isLoading = false;
    setState(() {});
  }

  Future<void> pickImage() async {

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    File file = File(image.path);

    Uint8List imageBytes = await file.readAsBytes();
    selectedImage = imageBytes;

    setState(() {});
  }

  void clearImage() {
    selectedImage = null;
    setState(() {});
  }

  Future<void> detect() async {
    setState(() {isLoading = true;});
    results = await yolo.predict(selectedImage!, confidenceThreshold: 0.5);
    setState(() {isLoading = false;});
  }

  void viewResults(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsView(results: results!,),));
  }

}

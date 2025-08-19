import 'dart:io';
import 'dart:typed_data';

import 'package:domina_yolo_en_flutter/core/app/enums.dart';
import 'package:domina_yolo_en_flutter/src/views/results_view.dart';
import 'package:domina_yolo_en_flutter/src/widgets/drop_down_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class DetectionMinimumsView extends StatefulWidget {
  const DetectionMinimumsView({super.key});

  @override
  State<DetectionMinimumsView> createState() => _DetectionMinimumsViewState();
}

class _DetectionMinimumsViewState extends State<DetectionMinimumsView> {

  YOLO? yolo;
  Uint8List? selectedImage;
  bool isLoading = false;
  Map<String, dynamic>? results;

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detección minima"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [

              SizedBox(
                width: 300,
                child: DropDownWidget(
                  selected: null,
                  onChanged: (value) => loadModel(value!),
                ),
              ),

              const SizedBox(height: 50,),

              // Seleccion de imagen
              Stack(
                children: [
                  InkWell(
                    onTap: () => pickImage(ImageSource.gallery),
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
                  // Abrir camara
                  Positioned(
                    top: 5,
                    right: selectedImage == null ? 5 : 53,
                    child: IconButton(
                      style: IconButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () async => await pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt)
                    ),
                  ),
                  // Limpiar imagen
                  if (selectedImage != null)
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
                  fixedSize: Size(width * 0.8, 50),
                  disabledBackgroundColor: Colors.grey
                ),
                child: Text("Detectar")
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadModel(TensorflowModel model) async {

    isLoading = true;
    setState(() {});

    // Liberar instancia previa (si existe)
    if (yolo != null) {
      await yolo!.dispose(); // importante para limpiar la instancia nativa
      yolo = null;
    }

    // Crear nueva instancia con el modelo seleccionado
    yolo = YOLO(modelPath: model.asset, task: YOLOTask.detect);
    await yolo!.loadModel();

    // Finalizar para habilitar el botón nuevamente
    isLoading = false;
    setState(() {});
  }

  Future<void> pickImage(ImageSource source) async {

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

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

    if (yolo == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Necesitar seleccionar un modelo")
      ));
      return;
    }

    try {
      setState(() {isLoading = true;});
      results = await yolo!.predict(selectedImage!, confidenceThreshold: 0.5);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsView(results: results!,),));
    } catch (e) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al realizar la detección")
      ));
    } finally {
      setState(() {isLoading = false;});
    }
  }

}

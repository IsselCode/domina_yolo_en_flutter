import 'dart:io';
import 'dart:typed_data';

import 'package:domina_yolo_en_flutter/core/app/enums.dart';
import 'package:domina_yolo_en_flutter/src/controllers/tensorflow_model_controller.dart';
import 'package:domina_yolo_en_flutter/src/views/results_view.dart';
import 'package:domina_yolo_en_flutter/src/widgets/drop_down_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import '../entities/product_entity.dart';

class DetectionMinimumsView extends StatefulWidget {

  final ProductEntity productEntity;

  const DetectionMinimumsView({
    super.key,
    required this.productEntity,
  });

  @override
  State<DetectionMinimumsView> createState() => _DetectionMinimumsViewState();
}

class _DetectionMinimumsViewState extends State<DetectionMinimumsView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      TensorflowModelController tfmController = context.read();
      tfmController.loadModel(widget.productEntity.model);
    },);

  }

  // Cada vez que el usuario entra a esta vista, la variable es nula
  Uint8List? selectedImage;
  Map<String, dynamic>? results;

  @override
  Widget build(BuildContext context) {
    TensorflowModelController tfmController = context.watch();

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productEntity.model.nombre),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [

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
                onPressed: selectedImage != null && !tfmController.isLoading ? detect : null,
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
    TensorflowModelController tfmController = context.read();

    if (tfmController.yolo == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Necesitar seleccionar un modelo")
      ));
      return;
    }

    try {
      tfmController.isLoading = true;
      results = await tfmController.yolo!.predict(selectedImage!, confidenceThreshold: 0.5);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsView(
        results: results!,
        classModel: widget.productEntity.classModel,
        type: widget.productEntity.type,
      )));
    } catch (e) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al realizar la detección")
      ));
    } finally {
      tfmController.isLoading = false;
    }
  }

}

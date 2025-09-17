import 'dart:typed_data';

import 'package:domina_yolo_en_flutter/core/app/enums.dart';
import 'package:domina_yolo_en_flutter/src/views/qr_result_view.dart';
import 'package:domina_yolo_en_flutter/src/widgets/image_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/tensorflow_model_controller.dart';

class QrDetectView extends StatefulWidget {

  QrDetectView({super.key});

  @override
  State<QrDetectView> createState() => _QrDetectViewState();
}

class _QrDetectViewState extends State<QrDetectView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      TensorflowModelController tfmController = context.read();
      tfmController.loadModel(TensorflowModel.qr);
    },);
  }

  Uint8List? selectedImage;
  Map<String, dynamic>? results;

  @override
  Widget build(BuildContext context) {
    TensorflowModelController tfmController = context.watch();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [

            //* Image Picker
            ImagePickerWidget(
              onChanged: (value) {
                selectedImage = value;
                setState(() {});
              },
            ),

            FilledButton(
              onPressed: selectedImage != null && !tfmController.isLoading ? detect : null,
              style: FilledButton.styleFrom(disabledBackgroundColor: Colors.grey),
              child: Text("Detectar")
            ),

          ],
        ),
      ),
    );
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
      results = await tfmController.yolo!.predict(selectedImage!, confidenceThreshold: 0.4);
      Navigator.push(context, MaterialPageRoute(builder: (context) => QrResultView(results: results, originalImage: selectedImage!,)));
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

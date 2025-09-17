import 'dart:typed_data';

import 'package:domina_yolo_en_flutter/core/app/enums.dart';
import 'package:domina_yolo_en_flutter/src/widgets/image_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

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
      tfmController.loadModel(TensorflowModel.pipes);
    },);
  }

  Uint8List? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            //* Image Picker
            ImagePickerWidget(
              onChanged: (value) {
                selectedImage = value;
                setState(() {});
              },
            )

          ],
        ),
      ),
    );
  }
}

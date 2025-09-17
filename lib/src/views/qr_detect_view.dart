import 'dart:typed_data';

import 'package:domina_yolo_en_flutter/src/widgets/image_picker_widget.dart';
import 'package:flutter/material.dart';

class QrDetectView extends StatelessWidget {

  QrDetectView({super.key});

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
              },
            )

          ],
        ),
      ),
    );
  }
}

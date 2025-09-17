import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {

  final ValueChanged<Uint8List?> onChanged;

  const ImagePickerWidget({
    super.key,
    required this.onChanged,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {

  Uint8List? selectedImage;

  Future<void> pickImage(ImageSource source) async {

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image == null) {
      return;
    }

    File file = File(image.path);

    Uint8List imageBytes = await file.readAsBytes();
    selectedImage = imageBytes;

    widget.onChanged(selectedImage);

    setState(() {});
  }

  void clearImage() {
    selectedImage = null;
    widget.onChanged(selectedImage);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Stack(
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
    );
  }
}

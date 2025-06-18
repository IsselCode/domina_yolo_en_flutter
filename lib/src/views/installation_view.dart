import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class InstallationView extends StatelessWidget {
  const InstallationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => onPressed(context),
          child: Text("Test YOLO")
        ),
      ),
    );
  }

  void onPressed(BuildContext context) async {

    try {

      final yolo = YOLO(
        modelPath: "tubos_float16",
        task: YOLOTask.detect
      );

      await yolo.loadModel();

      print("Modelo cargado");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Modelo cargado"))
      );

    } catch (e) {

      print("Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"))
      );

    }

  }

}

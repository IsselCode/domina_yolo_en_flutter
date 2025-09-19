import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/yolo.dart';

import '../../core/app/enums.dart';

class TensorflowModelController extends ChangeNotifier {

  YOLO? yolo;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadModel(TensorflowModel model) async {

    isLoading = true;

    // Liberar instancia previa (si existe)
    if (yolo != null) {
      await yolo!.dispose();
      yolo = null;
    }

    // Crear nueva instancia con el modelo seleccionado
    yolo = YOLO(modelPath: model.asset, task: YOLOTask.detect, useGpu: false);
    await yolo!.loadModel();

    // Finalizar para habilitar el botón nuevamente
    isLoading = false;
  }

}
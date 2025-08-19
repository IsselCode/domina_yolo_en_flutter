import 'package:domina_yolo_en_flutter/src/models/firebase_model.dart';
import 'package:flutter/material.dart';

import '../entities/product_entity.dart';

class DetectionController extends ChangeNotifier {

  FirebaseModel firebaseModel;

  DetectionController({
    required this.firebaseModel
  });

  Future<List<ProductEntity>> getTotals() async {
    return await firebaseModel.getTotals();
  }

}
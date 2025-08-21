import 'package:domina_yolo_en_flutter/src/models/firebase_model.dart';
import 'package:flutter/material.dart';

import '../../core/app/enums.dart';
import '../entities/product_entity.dart';

class DetectionController extends ChangeNotifier {

  FirebaseModel firebaseModel;

  DetectionController({
    required this.firebaseModel
  });

  List<ProductEntity> products = staticProducts;

  /// Mantiene los slots y el orden de staticProducts,
  /// pero sobreescribe con los datos de cloud si el nombre coincide.
  List<ProductEntity> _mergeByName(List<ProductEntity> staticProducts, List<ProductEntity> cloudProducts,) {
    final byName = {for (final p in staticProducts) p.name: p};
    for (final p in cloudProducts) {
      if (byName.containsKey(p.name)) {
        byName[p.name] = p;
      }
    }

    // Respeta el orden original de staticProducts (y su longitud).
    return staticProducts.map((p) => byName[p.name]!).toList();
  }

  Future<bool> getTotals() async {
    List<ProductEntity> response = await firebaseModel.getTotals();
    products = _mergeByName(staticProducts, response);
    return true;
  }

  // TODO: PROXIMO COMMIT
  // Future<void> applyMovementToTotal(ProductType productType, DeltaType deltaType, int quantity,) async {
  //
  //   int signed = await firebaseModel.applyMovementToTotalsBatch(
  //     productType: productType,
  //     quantity: quantity
  //   );
  //
  //   int indexProduct = products.indexWhere((element) => element.type.name == productType.name,);
  //   products[indexProduct].quantity += signed;
  //   notifyListeners();
  // }

}
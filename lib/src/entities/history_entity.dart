import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domina_yolo_en_flutter/core/app/enums.dart';

class HistoryProductEntity {

  ProductType productType;
  String image;
  DeltaType deltaType;
  int quantity;
  int signedQuantity;
  DateTime ts;

  HistoryProductEntity({
    required this.productType,
    required this.deltaType,
    required this.quantity,
    required this.signedQuantity,
    required this.ts,
    required this.image
  });

  factory HistoryProductEntity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    ProductType productType = ProductType.fromString(data["productId"])!;
    DeltaType deltaType = DeltaType.fromString(data["deltaType"])!;

    return HistoryProductEntity(
      productType: productType,
      deltaType: deltaType,
      quantity: data["quantity"],
      signedQuantity: data["signedQuantity"],
      ts: (data["ts"] as Timestamp?)!.toDate(),
      image: productImageByType[productType]!
    );
  }

}
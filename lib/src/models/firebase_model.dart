import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domina_yolo_en_flutter/src/entities/history_entity.dart';

import '../../core/app/enums.dart';
import '../entities/product_entity.dart';

class FirebaseModel {

  FirebaseFirestore firestore;

  FirebaseModel({
    required this.firestore
  });

  // Convierte el doc totals a una entidad para un producto dado
  ProductEntity mapTotalsToEntity(
      DocumentSnapshot<Map<String, dynamic>> totalsDoc,
      ProductType type,
      ) {
    final data = totalsDoc.data() ?? const {};

    final stockMap = Map<String, dynamic>.from(data['stock'] ?? {});
    final updatedMap = Map<String, dynamic>.from(data['lastUpdated'] ?? {});

    final quantity = (stockMap[type.name] as num?)?.toInt() ?? 0;

    final ts = updatedMap[type.name];
    final lastUpdated = ts is Timestamp
        ? ts.toDate()
        : DateTime.fromMillisecondsSinceEpoch(0);

    return ProductEntity(
      type: type,
      quantity: quantity,
      lastUpdated: lastUpdated,
    );
  }

  Future<List<ProductEntity>> getTotals() async {
    final doc = await firestore.doc('inventory/totals').get();
    return ProductType.values.map((t) => mapTotalsToEntity(doc, t)).toList();
  }

  Future<List<HistoryProductEntity>> getHistoryMovements() async {

    Query<Map<String, dynamic>> colRef = firestore.collection("inventoryMovements").orderBy("ts", descending: true);

    QuerySnapshot<Map<String, dynamic>> querySnap = await colRef.get();

    return querySnap.docs.map((d) => HistoryProductEntity.fromDoc(d)).toList();

  }

  Future<int> applyMovementToTotalsBatch({
    required ProductType productType,
    required DeltaType deltaType,
    required int quantity,
  }) async {
    assert(quantity > 0, 'La cantidad debe ser positiva');
    // Variación neta ya con signo
    final signed = deltaType == DeltaType.increase ? quantity : -quantity;

    final totalsRef = firestore.doc('inventory/totals');
    final movementRef = firestore.collection('inventoryMovements').doc();

    final batch = firestore.batch();

    // 1) Incremento/decremento atómico y timestamp por producto
    batch.set(totalsRef, {
      'stock': {
        productType.name: FieldValue.increment(signed),
      },
      'lastUpdated': {
        productType.name: FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));

    // 2) Historial
    batch.set(movementRef, {
      'productId': productType.name,
      'deltaType': deltaType.name,
      'quantity': quantity,
      'signedQuantity': signed,
      'ts': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return signed;
  }



}
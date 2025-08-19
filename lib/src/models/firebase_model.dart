import 'package:cloud_firestore/cloud_firestore.dart';

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

// Cargar los 3 desde el único doc
  Future<List<ProductEntity>> getTotals() async {
    final db = FirebaseFirestore.instance;
    final doc = await db.doc('inventory/totals').get();
    return ProductType.values.map((t) => mapTotalsToEntity(doc, t)).toList();
  }

}
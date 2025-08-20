import '../../core/app/enums.dart';

class ProductEntity {
  final ProductType type;
  final int quantity;
  final DateTime lastUpdated;

  const ProductEntity({
    required this.type,
    required this.quantity,
    required this.lastUpdated,
  });

  String get name => type.label;
  String get image => productImageByType[type]!;
  TensorflowModel get model => tensorflowModelByType[type]!;
}

List<ProductEntity> staticProducts = List.generate(
  ProductType.values.length,
  (index) {
    ProductType productType = ProductType.values[index];
    return ProductEntity(
      type: productType,
      quantity: 0,
      lastUpdated: DateTime.now()
    );
  },
);
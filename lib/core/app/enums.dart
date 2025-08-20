enum TensorflowModel {
  pipes(
    nombre: "Clasificador de Tubos",
    asset: "tubos_float16",
  ),
  boxes(
    nombre: "Clasificador de Cajas",
    asset: "cajas_float16",
  );

  final String nombre;
  final String asset;

  const TensorflowModel({
    required this.nombre,
    required this.asset,
  });
}

enum DeltaType {
  increase("Incremento"),
  decrease("Decremento");

  final String label;
  const DeltaType(this.label);

  static DeltaType? fromString(String? value) {
    if (value == null) return null;
    try {
      return DeltaType.values.byName(value);
    } catch (_) {
      return null; // unknown string
    }
  }

}

enum ProductType {
  Tubos("Tubos"),
  M8X16("M8X16"),
  TM8("T M8");

  final String label;
  const ProductType(this.label);

  static ProductType? fromString(String? v) {
    if (v == null) return null;
    try { return ProductType.values.byName(v); } catch (_) { return null; }
  }
}

// Assets locales por producto (estáticos en la app)
const Map<ProductType, String> productImageByType = {
  ProductType.Tubos: 'assets/1.png',
  ProductType.M8X16: 'assets/2.png',
  ProductType.TM8: 'assets/3.png',
};

// Modelos locales por producto (estáticos en la app)
const Map<ProductType, TensorflowModel> tensorflowModelByType = {
  ProductType.Tubos: TensorflowModel.pipes,
  ProductType.M8X16: TensorflowModel.boxes,
  ProductType.TM8: TensorflowModel.boxes,
};
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
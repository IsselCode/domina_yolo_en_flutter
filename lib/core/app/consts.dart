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
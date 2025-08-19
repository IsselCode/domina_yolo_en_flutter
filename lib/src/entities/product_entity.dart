class ProductEntity {

  String name;
  String image;
  int quantity;
  DateTime lastUpdated;

  ProductEntity({
    required this.name,
    required this.image,
    required this.quantity,
    required this.lastUpdated
  });

}

List<ProductEntity> staticProducts = [
  ProductEntity(
    name: "Tubos",
    image: "assets/1.png",
    quantity: 0,
    lastUpdated: DateTime.now()
  ),
  ProductEntity(
    name: "M8X16",
    image: "assets/2.png",
    quantity: 0,
    lastUpdated: DateTime.now()
  ),
  ProductEntity(
    name: "T M8",
    image: "assets/3.png",
    quantity: 0,
    lastUpdated: DateTime.now()
  ),
];
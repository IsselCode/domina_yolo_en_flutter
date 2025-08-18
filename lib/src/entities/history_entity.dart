class HistoryProductEntity {

  String productName;
  int delta;
  int balanceAfter;
  DateTime ts;

  HistoryProductEntity({
    required this.productName,
    required this.delta,
    required this.balanceAfter,
    required this.ts,
  });

}
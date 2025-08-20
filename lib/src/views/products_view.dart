import 'package:domina_yolo_en_flutter/src/controllers/detection_controller.dart';
import 'package:domina_yolo_en_flutter/src/dialogs/stock_movement_dialog.dart';
import 'package:domina_yolo_en_flutter/src/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/grid_view_product_widget.dart';
import 'detection_minimums_view.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  /// Mantiene los slots y el orden de staticProducts,
  /// pero sobreescribe con los datos de cloud si el nombre coincide.
  List<ProductEntity> _mergeByName(
      List<ProductEntity> staticProducts,
      List<ProductEntity> cloudProducts,
      ) {
    final byName = {for (final p in staticProducts) p.name: p};
    for (final p in cloudProducts) {
      if (byName.containsKey(p.name)) {
        byName[p.name] = p;
      }
    }

    // Respeta el orden original de staticProducts (y su longitud).
    return staticProducts.map((p) => byName[p.name]!).toList();
  }

  late Future<List<ProductEntity>> _future;

  @override
  void initState() {
    super.initState();
    DetectionController detectionController = context.read();
    _future = detectionController.getTotals();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Productos"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);

            final cloud = snapshot.data ?? const <ProductEntity>[];
            final merged = _mergeByName(staticProducts, cloud);

            return GridView.builder(
              itemCount: merged.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                final p = merged[index];
                return GridViewProductWidget(
                  key: ValueKey(p.name),
                  image: p.image,
                  name: p.name,
                  qnty: p.quantity,
                  lastUpdated: p.lastUpdated,
                  onTapIaButton: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetectionMinimumsView(),)
                  ),
                  onTap: () async {
                    final result = await stockMovementDialog(
                      context: context,
                      productName: p.name,
                      available: p.quantity
                    );

                    print(result!.deltaType);
                    print(result.quantity);
                  },
                );
              },
            );

          },
        ),
      ),
    );
  }
}

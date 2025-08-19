import 'package:domina_yolo_en_flutter/src/entities/product_entity.dart';
import 'package:flutter/material.dart';

import '../../core/app/enums.dart';
import '../widgets/grid_view_product_widget.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

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

  @override
  Widget build(BuildContext context) {

    List<ProductEntity> cloudProducts = [
      ProductEntity(
        type: ProductType.Tubos,
        quantity: 8,
        lastUpdated: DateTime.now()
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Productos"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: FutureBuilder(
          future: Future.delayed(Duration(seconds: 2)),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);

            final cloud = cloudProducts ?? const <ProductEntity>[];
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
                  onTap: () {
                    debugPrint('Abrir diálogo para "${p.name}"');
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

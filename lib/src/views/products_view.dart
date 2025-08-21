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

  late Future<bool> _future;

  @override
  void initState() {
    super.initState();
    DetectionController detectionController = context.read();
    _future = detectionController.getTotals();
  }

  @override
  Widget build(BuildContext context) {
    DetectionController detectionController = context.watch();

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

            if (!snapshot.hasData) {
              return Center(child: Text("Ocurrio un error"),);
            }

            return GridView.builder(
              itemCount: detectionController.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                final p = detectionController.products[index];
                return GridViewProductWidget(
                  key: ValueKey(p.name),
                  image: p.image,
                  name: p.name,
                  qnty: p.quantity,
                  lastUpdated: p.lastUpdated,
                  onTapIaButton: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetectionMinimumsView(productEntity: p,),)
                  ),
                  onTap: () async {
                    final result = await stockMovementDialog(
                      context: context,
                      productName: p.name,
                      available: p.quantity
                    );

                    if (result != null){
                      await detectionController.applyMovementToTotal(
                        p.type,
                        result.deltaType,
                        result.quantity
                      );
                    }
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

import 'package:domina_yolo_en_flutter/src/views/products_view.dart';
import 'package:domina_yolo_en_flutter/src/views/qr_detect_view.dart';
import 'package:flutter/material.dart';

class SelectAppView extends StatelessWidget {
  const SelectAppView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            //* Productos
            FilledButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsView(),)),
              child: Text("Productos")
            ),
            //* Códigos QR
            FilledButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QrDetectView(),)),
              child: Text("QR")
            ),
          ],
        ),
      ),
    );
  }
}

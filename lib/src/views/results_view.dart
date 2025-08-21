import 'package:domina_yolo_en_flutter/core/app/enums.dart';
import 'package:domina_yolo_en_flutter/src/controllers/detection_controller.dart';
import 'package:domina_yolo_en_flutter/src/views/products_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultsView extends StatelessWidget {

  final Map<String, dynamic> results;
  final String classModel;
  final ProductType type;

  const ResultsView({
    super.key,
    required this.results,
    required this.classModel,
    required this.type
  });

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    int total = results["boxes"].where( (element) => element["class"] == classModel).length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Resultados"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.memory(
                results["annotatedImage"],
                width: width * 0.8,
                height: width * 0.8,
              ),
              const SizedBox(height: 20,),
              Text("$total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
              Text(type.label, style: TextStyle(fontSize: 18),),

              Spacer(),

              FilledButton(
                onPressed: () async {
                  DetectionController detectionController = context.read();
                  await detectionController.applyMovementToTotal(
                    type,
                    DeltaType.increase,
                    total
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => ProductsView(),),
                    (route) => false,
                  );
                },
                style: FilledButton.styleFrom(
                  fixedSize: Size(width * 0.8, 50)
                ),
                child: Text("Guardar resultados")
              ),
            ],
          ),
        ),
      ),
    );
  }
}

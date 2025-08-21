import 'package:domina_yolo_en_flutter/core/app/enums.dart';
import 'package:domina_yolo_en_flutter/src/controllers/detection_controller.dart';
import 'package:domina_yolo_en_flutter/src/entities/history_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HistoryMovementsView extends StatefulWidget {
  const HistoryMovementsView({super.key});

  @override
  State<HistoryMovementsView> createState() => _HistoryMovementsViewState();
}

class _HistoryMovementsViewState extends State<HistoryMovementsView> {


  late Future<List<HistoryProductEntity>> _future;

  @override
  void initState() {
    super.initState();
    DetectionController detectionController = context.read();
    _future = detectionController.getHistoryMovements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial de movimientos"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Shimmer.fromColors(
                  baseColor: const Color(0xff18192c).withAlpha(100),
                  highlightColor: const Color(0xff18192c).withAlpha(20),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                    ),
                  )
              );
            }

            List<HistoryProductEntity> historyMovements = snapshot.data!;
            
            return ListView.separated(
              itemCount: historyMovements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10,),
              itemBuilder: (context, index) {
                HistoryProductEntity hm = historyMovements[index];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  leading: Image.asset(hm.image, height: 80, width: 80,),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(hm.productType.label)),
                      Flex(
                        spacing: 20,
                        direction: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              DateFormat("dd/MM/yy").format(hm.ts),
                              textAlign: TextAlign.end,
                            )
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              textAlign: TextAlign.end,
                              DateFormat("hh:mm:ss").format(hm.ts)
                            )
                          ),
                        ],
                      )
                    ],
                  ),
                  trailing: SizedBox(
                    width: 25,
                    child: Text(
                      hm.signedQuantity.toString(),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hm.deltaType == DeltaType.increase ? Colors.green : Colors.red
                      ),
                    ),
                  ),
                );
              },
            );
          }
        ),
      ),
    );
  }
}

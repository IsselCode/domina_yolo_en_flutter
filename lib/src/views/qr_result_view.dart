import 'package:flutter/material.dart';

class QrResultView extends StatelessWidget {

  final Map<String, dynamic>? results;

  const QrResultView({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(results);

    return Scaffold(
      appBar: AppBar(
        title: Text("Resultados"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [

              Expanded(
                child: Container(
                  color: Colors.red,
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.memory(
                      results?["annotatedImage"],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: ListView.separated(
                  itemCount: 5,
                  separatorBuilder: (context, index) => const SizedBox(height: 10,),
                  itemBuilder: (context, index) {
                    return SizedBox.shrink();
                  },
                )
              )

            ],
          ),
        ),
      ),
    );
  }
}

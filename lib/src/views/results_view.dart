import 'package:flutter/material.dart';

class ResultsView extends StatelessWidget {

  final Map<String, dynamic> results;

  const ResultsView({super.key, required this.results});

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Resultados"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.memory(
              results["annotatedImage"],
              width: width * 0.8,
              height: width * 0.8,
            ),
            const SizedBox(height: 20,),
            Text("${results["boxes"].length}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
            Text("Tubos detectados", style: TextStyle(fontSize: 18),)
          ],
        ),
      ),
    );
  }
}

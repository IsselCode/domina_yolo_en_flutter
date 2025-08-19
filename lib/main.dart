import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domina_yolo_en_flutter/src/controllers/detection_controller.dart';
import 'package:domina_yolo_en_flutter/src/models/firebase_model.dart';
import 'package:domina_yolo_en_flutter/src/views/detection_minimums_view.dart';
import 'package:domina_yolo_en_flutter/src/views/installation_view.dart';
import 'package:domina_yolo_en_flutter/src/views/products_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => FirebaseModel(firestore: FirebaseFirestore.instance),),
        ChangeNotifierProvider(create: (context) => DetectionController(firebaseModel: context.read()),)
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Color(0xffe7e7e7),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ProductsView(),
      ),
    );
  }
}
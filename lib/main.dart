import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taskly/data/services/auth_gate.dart';
import 'package:taskly/firebase_options.dart';
import 'app/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
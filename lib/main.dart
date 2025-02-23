import 'package:flutter/material.dart';
import 'package:watch_app/presentation/vibration_screen.dart';

void main() {
  runApp(MindfulnessApp());
}

class MindfulnessApp extends StatelessWidget {
  const MindfulnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VibrationScreen(),
    );
  }
}

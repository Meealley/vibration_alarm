import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:watch_app/util/button.dart';

class VibrationScreen extends StatefulWidget {
  const VibrationScreen({super.key});

  @override
  State<VibrationScreen> createState() => _VibrationScreenState();
}

class _VibrationScreenState extends State<VibrationScreen> {
  bool isVibrating = false;
  int interval = 1;
  int intensity = 128;
  Timer? timer;

  void _toggleVibration() {
    if (isVibrating) {
      timer?.cancel();
    } else {
      timer = Timer.periodic(Duration(minutes: interval), (timer) async {
        if (await Vibration.hasVibrator() == true) {
          Vibration.vibrate(duration: 500, amplitude: intensity);
        }
      });
    }
    setState(() {
      isVibrating = !isVibrating;
    });
  }

  void _onIntervalChanged(value) {
    setState(() {
      interval = value.toInt();
    });
  }

  void _onIntensityChanged(value) {
    setState(() {
      intensity = value.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Vibration App',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Vibration Interval (minutes)",
                style: GoogleFonts.manrope(fontSize: 12),
              ),
              Slider(
                value: interval.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: "$interval min",
                onChanged: _onIntervalChanged,
                activeColor: Colors.blue,
              ),
              // Slider(value: interval.toDouble(), onChanged: onChanged)
              Text(
                "Vibration Interval (minutes)",
                style: GoogleFonts.manrope(fontSize: 12),
              ),
              GestureDetector(
                onVerticalDragUpdate: (_) {},
                child: Slider(
                  value: intensity.toDouble(),
                  min: 0,
                  max: 255,
                  divisions: 10,
                  label: "$intensity",
                  onChanged: _onIntensityChanged,
                  activeColor: Colors.blue,
                ),
              ),

              // SizedBox(
              //   height: 7,
              // ),

              WatchButton(
                text: isVibrating ? "Stop Vibrating" : "Start Vibrating",
                onTap: _toggleVibration,
              ),
              SizedBox(
                height: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
              fontSize: 18,
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
              // Text(
              //   "Vibration Interval (minutes)",
              //   style: GoogleFonts.manrope(fontSize: 12),
              // ),
              _buildSlider(
                title: 'Vibration Interval (minutes)',
                value: interval.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: _onIntervalChanged,
                label: '$interval min',
              ),
              _buildSlider(
                title: 'Vibration Intensity',
                value: intensity.toDouble(),
                min: 0,
                max: 255,
                divisions: 10,
                onChanged: _onIntensityChanged,
                label: '$intensity',
              ),
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

  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required void Function(double) onChanged,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.blueAccent.withOpacity(0.3),
            thumbColor: Colors.blueAccent,
            valueIndicatorColor: Colors.blueAccent,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: label,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

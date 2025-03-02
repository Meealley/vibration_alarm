import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

class VibrationAlarmScreen extends StatefulWidget {
  const VibrationAlarmScreen({super.key});

  @override
  _VibrationAlarmScreenState createState() => _VibrationAlarmScreenState();
}

class _VibrationAlarmScreenState extends State<VibrationAlarmScreen> {
  // Default values
  int _interval = 1; // minutes
  int _intensity = 2; // medium
  int _duration = 1; // seconds
  bool _isRunning = false;
  Timer? _timer;
  Timer? _countdownTimer;
  DateTime? _nextVibrationTime;
  String _remainingTime = "";

  @override
  void initState() {
    super.initState();
    _checkVibrationSupport();
  }

  @override
  void dispose() {
    _stopVibration();
    super.dispose();
  }

  // Check if device supports vibration
  Future<void> _checkVibrationSupport() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    bool? hasAmplitudeControl = await Vibration.hasAmplitudeControl();

    debugPrint('Has vibrator: $hasVibrator');
    debugPrint('Has amplitude control: $hasAmplitudeControl');
  }

  // Get vibration amplitude based on intensity
  int _getAmplitude() {
    // Samsung Galaxy Watch supports amplitude control
    // Values range from 1-255
    switch (_intensity) {
      case 1:
        return 64; // Light
      case 2:
        return 128; // Medium
      case 3:
        return 255; // Strong
      default:
        return 128;
    }
  }

  // Method to trigger vibration
  Future<void> _vibrate() async {
    try {
      final int amplitude = _getAmplitude();
      final int durationMs = _duration * 1000;

      // For longer durations, create a pattern with short pauses
      if (_duration > 1) {
        List<int> pattern = [];
        for (int i = 0; i < _duration; i++) {
          pattern.add(800); // 800ms on
          if (i < _duration - 1) {
            pattern.add(200); // 200ms off between pulses
          }
        }

        Vibration.vibrate(
          pattern: pattern,
          intensities: List.filled(pattern.length, amplitude),
          repeat: -1, // Don't repeat
        );

        // Cancel after pattern completes
        await Future.delayed(
            Duration(milliseconds: pattern.reduce((a, b) => a + b)));
        Vibration.cancel();
      } else {
        // Simple vibration for short durations
        Vibration.vibrate(duration: durationMs, amplitude: amplitude);
      }

      // Update next vibration time
      _updateNextVibrationTime();
    } catch (e) {
      debugPrint('Error triggering vibration: $e');
    }
  }

  void _updateNextVibrationTime() {
    if (_isRunning) {
      setState(() {
        _nextVibrationTime = DateTime.now().add(Duration(minutes: _interval));
      });

      // Start countdown timer
      _startCountdownTimer();
    }
  }

  void _startCountdownTimer() {
    // Cancel existing timer if any
    _countdownTimer?.cancel();

    // Update countdown every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextVibrationTime != null) {
        final remaining = _nextVibrationTime!.difference(DateTime.now());

        if (remaining.isNegative) {
          setState(() {
            _remainingTime = "00:00";
          });
        } else {
          final minutes = remaining.inMinutes;
          final seconds = remaining.inSeconds % 60;
          setState(() {
            _remainingTime =
                "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
          });
        }
      }
    });
  }

  // Start vibration alarm
  void _startVibration() {
    setState(() {
      _isRunning = true;
    });

    // Initial vibration
    _vibrate();

    // Set up timer for repeated vibrations
    _timer = Timer.periodic(Duration(minutes: _interval), (timer) {
      _vibrate();
    });
  }

  // Stop vibration alarm
  void _stopVibration() {
    _timer?.cancel();
    _timer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    Vibration.cancel();

    setState(() {
      _isRunning = false;
      _nextVibrationTime = null;
      _remainingTime = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on a small screen like a watch
    final isSmallScreen = MediaQuery.of(context).size.width < 200;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vibration Alarm',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Interval Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Interval:',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            iconSize: 16,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.white,
                            ),
                            onPressed: _isRunning
                                ? null
                                : () {
                                    if (_interval > 1) {
                                      setState(() {
                                        _interval--;
                                      });
                                    }
                                  },
                          ),
                          SizedBox(
                            width: 40,
                            child: Center(
                              child: Text(
                                '$_interval min',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            iconSize: 16,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                            ),
                            onPressed: _isRunning
                                ? null
                                : () {
                                    if (_interval < 10) {
                                      setState(() {
                                        _interval++;
                                      });
                                    }
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Intensity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Intensity:',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            iconSize: 16,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.white,
                            ),
                            onPressed: _isRunning
                                ? null
                                : () {
                                    if (_intensity > 1) {
                                      setState(() {
                                        _intensity--;
                                      });
                                    }
                                  },
                          ),
                          SizedBox(
                            width: 40,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                    _intensity,
                                    (index) => const Icon(
                                          Icons.vibration,
                                          size: 12,
                                          color: Colors.white,
                                        )),
                              ),
                            ),
                          ),
                          IconButton(
                            iconSize: 16,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                            ),
                            onPressed: _isRunning
                                ? null
                                : () {
                                    if (_intensity < 3) {
                                      setState(() {
                                        _intensity++;
                                      });
                                    }
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Duration Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duration:',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            iconSize: 16,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.white,
                            ),
                            onPressed: _isRunning
                                ? null
                                : () {
                                    if (_duration > 1) {
                                      setState(() {
                                        _duration--;
                                      });
                                    }
                                  },
                          ),
                          SizedBox(
                            width: 40,
                            child: Center(
                              child: Text(
                                '$_duration sec',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            iconSize: 16,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                            ),
                            onPressed: _isRunning
                                ? null
                                : () {
                                    if (_duration < 5) {
                                      setState(() {
                                        _duration++;
                                      });
                                    }
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Next vibration countdown
                  if (_isRunning && _remainingTime.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Next: $_remainingTime',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // Start/Stop Button
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning ? Colors.red : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(120, 36),
                      ),
                      onPressed: _isRunning ? _stopVibration : _startVibration,
                      child: Text(
                        _isRunning ? 'STOP' : 'START',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Note about screen staying on
                  if (_isRunning)
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Keep app open',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

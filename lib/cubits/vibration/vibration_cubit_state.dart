// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:equatable/equatable.dart';

part of 'vibration_cubit_cubit.dart';

enum VibrationStatus { stopped, vibrating }

class VibrationCubitState extends Equatable {
  final int intensity;
  final int duration;
  final int interval;
  final VibrationStatus status;

  const VibrationCubitState({
    required this.intensity,
    required this.duration,
    required this.interval,
    required this.status,
  });

  factory VibrationCubitState.initial() {
    return VibrationCubitState(
      intensity: 128,
      duration: 500,
      interval: 1,
      status: VibrationStatus.stopped,
    );
  }

  @override
  List<Object> get props => [intensity, duration, interval, status];

  @override
  bool get stringify => true;

  VibrationCubitState copyWith({
    int? intensity,
    int? duration,
    int? interval,
    VibrationStatus? status,
  }) {
    return VibrationCubitState(
      intensity: intensity ?? this.intensity,
      duration: duration ?? this.duration,
      interval: interval ?? this.interval,
      status: status ?? this.status,
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'vibration_cubit_state.dart';

class VibrationCubit extends Cubit<VibrationCubitState> {
  VibrationCubit() : super(VibrationCubitState.initial());

  void updateVibrationSettings(int intensity, int duration, int interval) {
    emit(state.copyWith(
        intensity: intensity, duration: duration, interval: interval));
    if (state.status == VibrationStatus.vibrating) {
      startVibration(intensity, duration, interval);
    }
  }

  void startVibration(int intensity, int duration, int interval) {
    emit(state.copyWith(
        intensity: intensity,
        duration: duration,
        interval: interval,
        status: VibrationStatus.vibrating));
    print(
        'Vibrating with intensity $intensity, duration $duration ms, and interval $interval min');
  }

  void stopVibration() {
    emit(state.copyWith(status: VibrationStatus.stopped));
    print('Vibration stopped');
  }

  void restartVibration() {
    stopVibration();
    startVibration(state.intensity, state.duration, state.interval);
    print('Vibration restarted');
  }
}

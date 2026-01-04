import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:power_line_walker/models/power_line_point.dart';

final idProvider = StateProvider<String>((ref) {
  return '';
});

final selectedPointProvider = StateProvider<PowerLinePoint?>((ref) {
  return null;
});

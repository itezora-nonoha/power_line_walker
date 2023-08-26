import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:power_line_walker/models/power_line_point.dart';

void main() {
  List<PowerLinePoint> powerLinePointList = [];
  setUp(() {
    powerLinePointList.add(PowerLinePoint(
        latlng: LatLng(35, 135), names: ['東日本線-1'], createdAt: DateTime.now()));
    powerLinePointList.add(PowerLinePoint(
        latlng: LatLng(35, 135), names: ['東日本線-1-乙'], createdAt: DateTime.now()));
  });

  group('Method Testing', () {
    group('gererateUniqueKey', () {
      test("extraText is None", () {
        expect(powerLinePointList[0].generateUniqueKey(), '東日本線-0001');
      });

      test("extraText is Exist", () {
        expect(powerLinePointList[1].generateUniqueKey(), '東日本線-0001-乙');
      });
    });
  });
}

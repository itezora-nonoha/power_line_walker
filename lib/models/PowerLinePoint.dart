import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PowerLinePoint {
  // double _latitude;
  // double _longitude;
  final LatLng latlng;
  // final String names;
  final List<String> names;
  // String note;
  final DateTime createdAt;

  PowerLinePoint({required this.latlng, required this.names, required this.createdAt});

  factory PowerLinePoint.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return PowerLinePoint(
        latlng: LatLng(data?['latitude'], data?['longitude']),
        names: List.from(data?['names']),
        createdAt: data?['createdAt'].toDate()
      );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "latitude": latlng.latitude,
      "longitude": latlng.longitude,
      "names": names,
      "createdAt": createdAt,
    };
  }
  // String getFirstNames(){
  //   return this.names[0];
  // }
  @override
  String toString(){
    return '$latlng ... $names';
  }
}

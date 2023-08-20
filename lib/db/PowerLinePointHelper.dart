import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_line_walker/models/PowerLinePoint.dart';

class PowerLinePointHelper {
  PowerLinePointHelper._getInstance();
  static final PowerLinePointHelper instance = PowerLinePointHelper._getInstance();
  // static List<PowerLinePoint> points = [];
  final _db = FirebaseFirestore.instance;

  static const _collectionName = 'points';
  // static const _collectionName = 'points_preview';
  // static const _subCollectionBookings = 'bookings';

  Future<List<DocumentSnapshot>> selectAllPowerLinePoints() async {
    final collectionRef = _db
        .collection(_collectionName)
        .withConverter(
          fromFirestore: PowerLinePoint.fromFirestore,
          toFirestore: (PowerLinePoint points, _) => points.toFirestore(),
        );
    final collectionSnap = await collectionRef.get();
    return collectionSnap.docs;
  }

  Future<PowerLinePoint?> selectPowerLinePoint(String pointName) async {
    final docRef = _db
        .collection(_collectionName)
        .doc(pointName)
        .withConverter(
            fromFirestore: PowerLinePoint.fromFirestore,
            toFirestore: (PowerLinePoint points, _) => points.toFirestore());
    final docSnap = await docRef.get();
    return docSnap.data();
  }

  Future<void> insert(PowerLinePoint powerLinePoint) async {
    final docRef = _db
        .collection(_collectionName)
        .doc(powerLinePoint.names[0])
        .withConverter(
            fromFirestore: PowerLinePoint.fromFirestore,
            toFirestore: (PowerLinePoint powerLinePoint, _) => powerLinePoint.toFirestore());
    return await docRef.set(powerLinePoint);
  }

  Future<void> delete(String pointName) async {
    return await _db
        .collection(_collectionName)
        .doc(pointName)
        .delete();
  }
}

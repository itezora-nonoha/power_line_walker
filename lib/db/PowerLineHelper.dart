import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_line_walker/models/power_line.dart';

class PowerLineHelper {
  PowerLineHelper._getInstance();
  static final PowerLineHelper instance = PowerLineHelper._getInstance();
  // static List<PowerLine> points = [];
  final _db = FirebaseFirestore.instance;

  // static const _collectionPoints = 'points';
  static const _collectionName = 'powerLines';
  // static const _subCollectionBookings = 'bookings';

  Future<List<DocumentSnapshot>> selectAllPowerLines() async {
    final collectionRef = _db
        .collection(_collectionName)
        .withConverter(
          fromFirestore: PowerLine.fromFirestore,
          toFirestore: (PowerLine points, _) => points.toFirestore(),
        );
    final collectionSnap = await collectionRef.get();
    return collectionSnap.docs;
  }

  Future<PowerLine?> selectPowerLine(String powerLineName) async {
    final docRef = _db
        .collection(_collectionName)
        .doc(powerLineName)
        .withConverter(
            fromFirestore: PowerLine.fromFirestore,
            toFirestore: (PowerLine p, _) => p.toFirestore());
    final docSnap = await docRef.get();
    return docSnap.data();
  }

  Future<void> insert(PowerLine powerLine) async {
    final docRef = _db
        .collection(_collectionName)
        .doc(powerLine.name)
        .withConverter(
            fromFirestore: PowerLine.fromFirestore,
            toFirestore: (PowerLine p, _) => p.toFirestore());
    return await docRef.set(powerLine);
  }

  Future<void> delete(String powerLineName) async {
    return await _db
        .collection(_collectionName)
        .doc(powerLineName)
        .delete();
  }
}

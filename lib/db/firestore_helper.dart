import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:power_line_walker/models/booking.dart';

class FirestoreHelper {
  FirestoreHelper._getInstance();
  static final FirestoreHelper instance = FirestoreHelper._getInstance();

  final _db = FirebaseFirestore.instance;

  static const _collectionUsers = 'users';
  static const _subCollectionBookings = 'bookings';

  Future<List<DocumentSnapshot>> selectAllBookings(String userId) async {
    final collectionRef = _db
        .collection(_collectionUsers)
        .doc(userId)
        .collection(_subCollectionBookings)
        .withConverter(
          fromFirestore: Booking.fromFirestore,
          toFirestore: (Booking bookings, _) => bookings.toFirestore(),
        );
    final collectionSnap = await collectionRef.get();
    return collectionSnap.docs;
  }

  Future<Booking?> selectBooking(String userId, String place) async {
    final docRef = _db
        .collection(_collectionUsers)
        .doc(userId)
        .collection(_subCollectionBookings)
        .doc(place)
        .withConverter(
            fromFirestore: Booking.fromFirestore,
            toFirestore: (Booking booking, _) => booking.toFirestore());
    final docSnap = await docRef.get();
    return docSnap.data();
  }

  Future<void> insert(Booking booking, String userId) async {
    final docRef = _db
        .collection(_collectionUsers)
        .doc(userId)
        .collection(_subCollectionBookings)
        .doc(booking.place)
        .withConverter(
            fromFirestore: Booking.fromFirestore,
            toFirestore: (Booking booking, _) => booking.toFirestore());
    return await docRef.set(booking);
  }

  Future<void> delete(String userId, String docId) async {
    return await _db
        .collection(_collectionUsers)
        .doc(userId)
        .collection(_subCollectionBookings)
        .doc(docId)
        .delete();
  }
}

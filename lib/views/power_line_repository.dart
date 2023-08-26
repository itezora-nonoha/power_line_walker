import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:power_line_walker/firebase_options.dart';
import 'package:power_line_walker/models/power_line.dart';
import 'package:power_line_walker/models/power_line_point.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class PowerLineRepository {
  PowerLineRepository._getInstance();
  static final PowerLineRepository instance = PowerLineRepository._getInstance();
  final _database = FirebaseFirestore.instance;
  
  // Firestoreに対して、全量読み込みを実施する
  Future<String> fullReload() async {
    await _loadPowerLinePointList().then((value) {
      print('${_powerLinePointList.length} PowerLinePoint is Loaded. (PowerLineRepository)');
    });
    await _loadPowerLineList().then((value) {
      print('${_powerLineList.length} PowerLine is Loaded. (PowerLineRepository)');
    });
    return 'complete';
  }

  // ------------------------------ PowerLinePoint ------------------------------
  List<PowerLinePoint> _powerLinePointList = [];

  // 現時点でローカル上に保持しているデータを返却する
  List<PowerLinePoint> getPowerLinePointList(){
    return _powerLinePointList;
  }

  Future<String> _loadPowerLinePointList() async {
    
    // FirestoreからPowerLinePointの一覧を取得する
    List<DocumentSnapshot> powerLineLatLngListSnapshot = await _selectAllPowerLinePoints();

    // Firestoreから取得したSnapShot情報を、PowerLinePointのリストに変換する
    _powerLinePointList = powerLineLatLngListSnapshot.map((doc) => PowerLinePoint(
        latlng: LatLng(doc['latitude'], doc['longitude']),
        names: List.from(doc['names']),
        createdAt: doc['createdAt'].toDate()
      )).toList();

    return Future<String>.value('complete');
  }
  
  // すべての地点情報をFirestoreから読み込む
  Future<List<DocumentSnapshot>> _selectAllPowerLinePoints() async {
    final collectionRef = _database
        .collection('points')
        .withConverter(
          fromFirestore: PowerLinePoint.fromFirestore,
          toFirestore: (PowerLinePoint points, _) => points.toFirestore(),
        );
    final collectionSnap = await collectionRef.get();
    return collectionSnap.docs;
  }

  // 任意1件の地点情報を読み込む
  Future<PowerLinePoint?> selectPowerLinePoint(String pointName) async {
    final docRef = _database
        .collection('points')
        .doc(pointName)
        .withConverter(
            fromFirestore: PowerLinePoint.fromFirestore,
            toFirestore: (PowerLinePoint points, _) => points.toFirestore());
    final docSnap = await docRef.get();
    return docSnap.data();
  }

  // 地点情報を登録する
  Future<void> insert(PowerLinePoint powerLinePoint) async {
    final docRef = _database
        .collection('points')
        .doc(powerLinePoint.generateUniqueKey())
        .withConverter(
            fromFirestore: PowerLinePoint.fromFirestore,
            toFirestore: (PowerLinePoint powerLinePoint, _) => powerLinePoint.toFirestore());
    return await docRef.set(powerLinePoint);
  }

  // ------------------------------ PowerLine ------------------------------
  List<PowerLine> _powerLineList = [];
  // 現時点でローカル上に保持しているデータを返却する

  List<PowerLine> getPowerLineList(){
    return _powerLineList;
  }

  Future<String> _loadPowerLineList() async {
    
    // FirestoreからPowerLineの一覧を取得する
    List<DocumentSnapshot> docSnapshot = await _selectAllPowerLines();

    // Firestoreから取得したSnapShot情報を、PowerLineのリストに変換する
    _powerLineList = docSnapshot.map((doc) => PowerLine(
            name: doc['name'],
            transmissionVoltage: doc['transmissionVoltage']
      )).toList();

    return Future<String>.value('complete');
  }
  
  // すべての地点情報をFirestoreから読み込む
  Future<List<DocumentSnapshot>> _selectAllPowerLines() async {
    final collectionRef = _database
        .collection('powerLines')
        .withConverter(
          fromFirestore: PowerLine.fromFirestore,
          toFirestore: (PowerLine points, _) => points.toFirestore(),
        );
    final collectionSnap = await collectionRef.get();
    return collectionSnap.docs;
  }
}

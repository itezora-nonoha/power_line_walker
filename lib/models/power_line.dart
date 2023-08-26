import 'package:cloud_firestore/cloud_firestore.dart';

class PowerLine {
  final String name;
  final double transmissionVoltage;

  PowerLine({required this.name, required this.transmissionVoltage});

  factory PowerLine.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return PowerLine(
        name: data?['name'],
        transmissionVoltage: data?['transmissionVoltage'],
      );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "transmissionVoltage": transmissionVoltage,

    };
  }

  @override
  String toString(){
    return '$name ... {$transmissionVoltage}kV';
  }
}

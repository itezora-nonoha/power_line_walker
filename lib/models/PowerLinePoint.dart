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

  String generateUniqueKey(){
    // 併架されている場合の実際の鉄塔表示名を取得
    String powerPointLabel = names[0];
    List<String> labelNameSplit = powerPointLabel.split('-');
  
    String labelName = labelNameSplit[0];
    double labelNumber = double.parse(labelNameSplit[1]);
    String labelNumberPadding = labelNumber.toString().padLeft(4, "0");
  
    String pointKey = '$labelName-$labelNumberPadding';

    // 「送電路線名-鉄塔番号」の後ろに更に文字列がついている場合に、そのテキストを付記する
    if (labelNameSplit.length > 2){
      String str = '${labelNameSplit[0]}-${labelNameSplit[1]}';
      String extraText = str.substring(pointKey.length);
      pointKey ='$pointKey$extraText';
    }
    return pointKey;
  }
}

import 'dart:typed_data';



class emp{
  int id;
  String name;
  String checkin;
  String checkout;
  String assi;
  double salery;
  Uint8List imageBytes;
  emp({
    required this.id,
    required this.name,
    required this.checkin,
    required this.checkout,
    required this.assi,
    required this.salery,
    required this.imageBytes,
  });
  factory emp.fromMap(Map<String, dynamic> map) {
    return emp(
      id: map['id'],
      name: map['name'],
      checkin: map['checkin'],
      checkout: map['checkout'],
      assi: map['assi'],
      salery: map['salery'],
      imageBytes: map['image']
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'checkin': checkin,
      'checkout': checkout,
      'assi': assi,
      'salery': salery,
      'image' :imageBytes
    };
  }
}
import 'dart:typed_data';

class pro {
  int id;
  String name;
  String category;
  int quantity;
  double sell;
  double sellprice;
  Uint8List image;

  pro({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.sell,
    required this.sellprice,
    required this.image
  });

  // To convert a Map to a pro object
  factory pro.fromMap(Map<String, dynamic> map) {
    return pro(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'],
      sell: map['sell'],
      sellprice: map['sellprice'],
      image: map['image'],
    );
  }

  // To convert a pro object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'sell': sell,
      'sellprice': sellprice,
    };
  }
}

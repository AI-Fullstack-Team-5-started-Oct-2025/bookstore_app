//  Product Model
/*
  Create: 10/12/2025 13:57, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: Product Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Product {
  // Properties
  int? id;
  int? pbid;  //  ProductBase id
  int? mfid;  //  Manufacturer id
  final String color;
  final int size;
  final int basePrice;

  // Constructor
  Product({
    this.id,
    this.pbid,
    this.mfid,
    required this.color,
    required this.size,
    required this.basePrice,
  });

  Product.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      pbid = map['pbid'] as int?,
      mfid = map['mfid'] as int?,
      color = map['color'] as String,
      size = map['size'] as int,
      basePrice = map['basePrice'] as int;

  static const List<String> keys = ['id', 'pbid', 'mfid', 'color', 'size', 'basePrice'];
}

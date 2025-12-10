//  ProductBase Model
/*
  Create: 10/12/2025 14:05, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: ProductBase Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class ProductBase {
  // Properties
  int? id;
  final String name;
  final String color;

  // Constructor
  ProductBase({this.id, required this.name, required this.color});

  ProductBase.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      name = map['name'] as String,
      color = map['color'] as String;
  
  static const List<String> keys = ['id', 'name', 'color'];
}
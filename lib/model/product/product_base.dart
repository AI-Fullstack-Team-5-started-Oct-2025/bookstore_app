//  ProductBase Model
/*
  Create: 10/12/2025 14:05, Creator: Chansol, Park
  Update log: 
    11/12/2025 10:53, 'Point 1, Redesign entire Model', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: ProductBase Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class ProductBase {
  // Properties
  int? id;
  int? pid; //  Product id
  final String pName;
  final String pDescription;
  final String pGender;
  final String pStatus;
  final String pFeatureType;
  final String pCategory;
  final String pModelNumber;

  // Constructor
  ProductBase({
    this.id,
    required this.pid,
    required this.pName,
    required this.pDescription,
    required this.pGender,
    required this.pStatus,
    required this.pFeatureType,
    required this.pCategory,
    required this.pModelNumber,
  });

  ProductBase.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      pid = map['pid'] as int?,
      pName = map['pName'] as String,
      pDescription = map['pDescription'] as String,
      pGender = map['pGender'] as String,
      pStatus = map['pStatus'] as String,
      pFeatureType = map['pFeatureType'] as String,
      pCategory = map['pCategory'] as String,
      pModelNumber = map['pModelNumber'] as String;

  static const List<String> keys = [
    'id',
    'pid',
    'pName',
    'pDescription',
    'pGender',
    'pStatus',
    'pFeatureType',
    'pCategory',
    'pModelNumber',
  ];
}

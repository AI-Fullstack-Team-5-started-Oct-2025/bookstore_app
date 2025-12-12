//  PurchaseItem Model
/*
  Create: 10/12/2025 12:42, Creator: Chansol, Park
  Update log: 
    DUMMY 9/29/2025 09:53, 'Point X, Description', Creator: Chansol, Park
    12/12/2025 14:27, 'Point 1, Removed quantity', Creator: Chansol, Park
    12/12/2025 14:27, 'Point 2, Purchase item Quantity, rebuild attributes, toMap', Creator: Chansol, Park
    12/12/2025 15:26, 'Point 3, Purchase item Status, toMap', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: PurchaseItem Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class PurchaseItem {
  //  Properties
  //  Point 1
  int? id;
  int? pid; //  Product id
  //  Point 2
  int pcQuantity; //  Purchase Item Quantity
  String pcStatus;  //  'Onway', 'Waiting for transaction', 'complete', 'return request', 'return done'



  // Constructor
  PurchaseItem({
    this.id,
    this.pid,
    required this.pcQuantity,
    required this.pcStatus  //  
  });

  PurchaseItem.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      pid = map['pid'] as int?,
      pcQuantity = map['pcQuantity'] as int,
      pcStatus = map['pcStatus'] as String;

  //  Point 2
  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{
      'pid': pid,
      'asid': pcQuantity,
      'pcStatus': pcStatus
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const List<String> keys = ['id', 'pid', 'pcQuantity', 'pcStatus'];
}
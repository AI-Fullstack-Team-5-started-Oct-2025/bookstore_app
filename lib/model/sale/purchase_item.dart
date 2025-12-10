//  PurchaseItem Model
/*
  Create: 10/12/2025 12:42, Creator: Chansol, Park
  Update log: 
    DUMMY 9/29/2025 09:53, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: PurchaseItem Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class PurchaseItem {
  //  Properties
  int? id;
  int? pid;
  int? asid;
  int? pdid;
  final String returnDate;
  final String unitPrice;
  final String quantity;

  // Constructor
  PurchaseItem({
    this.id,
    this.pid,
    this.asid,
    this.pdid,
    required this.returnDate,
    required this.unitPrice,
    required this.quantity
  });

  PurchaseItem.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      pid = map['pid'] as int?,
      asid = map['asid'] as int?,
      pdid = map['pdid'] as int?,
      returnDate = map['returnDate'] as String,
      unitPrice = map['unitPrice'] as String,
      quantity = map['quantity'] as String;

  static const List<String> keys = ['id', 'pid', 'asid', 'pdid', 'returnDate', 'unitPrice', 'quantity'];
}
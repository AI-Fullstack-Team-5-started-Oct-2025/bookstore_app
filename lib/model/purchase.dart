//  Purchase Model
/*
  Create: 10/12/2025 12:35, Creator: Chansol, Park
  Update log: 
    DUMMY 9/29/2025 09:53, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: Purchase Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Purchase {
  //  Properties
  int? id;
  int? cid;
  int? sid;
  final String pickupDate;
  final String orderCode;
  final String timeStamp;

  // Constructor
  Purchase({
    this.id,
    this.cid,
    this.sid,
    required this.pickupDate,
    required this.orderCode,
    required this.timeStamp
  });

  Purchase.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      cid = map['cid'] as int?,
      sid = map['sid'] as int?,
      pickupDate = map['pickupDate'] as String,
      orderCode = map['orderCode'] as String,
      timeStamp = map['timeStamp'] as String;

  static const List<String> keys = ['id', 'cid', 'sid', 'pickupDate', 'orderCode', 'timeStamp'];
}

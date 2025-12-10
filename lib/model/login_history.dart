//  LoginHistory Model
/*
  Create: 10/12/2025 12:26, Creator: Chansol, Park
  Update log: 
    DUMMY 9/29/2025 09:53, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: LoginHistory Model
*/

class LoginHistory {
  // Properties
  int? id;
  int? cid;
  final String loginTime;
  final String status;
  final double version;

  // Constructor
  LoginHistory({
    this.id,
    this.cid,
    required this.loginTime,
    required this.status,
    required this.version,
  });

  LoginHistory.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      cid = map['cid'] as int?,
      loginTime = map['loginTime'] as String,
      status = map['status'] as String,
      version = (map['version'] as num).toDouble();

  static const List<String> keys = ['id', 'cid', 'loginTime', 'status', 'version'];
}

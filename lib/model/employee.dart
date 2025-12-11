//  Customer Model
/*
  Create: 12/11/2025 15:38, Creator: taekkwon, kim
  Update log: 
    12/11/2025 15:38, 'create Employee Model', Creator: taekkwon, kim
    12/11/2025 15:38, 'add Function toMap', Creator: taekkwon, kim
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: Employee Model
*/

class Employee {
  // Properties
  int? id;
  final String eemail;
  final String ephoneNumber;
  final String ename;
  final String epassword;

  // Constructor
  Employee({
    this.id,
    required this.eemail,
    required this.ephoneNumber,
    required this.ename,
    required this.epassword,
  });

  Employee.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      eemail = map['eemail'] as String,
      ephoneNumber = map['ephoneNumber'] as String,
      ename = map['ename'] as String,
      epassword = map['epassword'] as String;

  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{
      'eemail': eemail,
      'ephoneNumber': ephoneNumber,
      'ename': ename,
      'epassword': epassword,
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const List<String> keys = [
    'id',
    'eemail',
    'ephoneNumber',
    'ename',
    'epassword',
  ];
}

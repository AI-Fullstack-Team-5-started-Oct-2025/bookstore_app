//  Customer Model
/*
  Create: 10/12/2025 12:11, Creator: Chansol, Park
  Update log: 
    12/11/2025 10:53, 'remove nickname and imagePath', Creator: 
    12/11/2025 10:53, 'add Function toMap', Creator: taekkwon, kim
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: Customer Model
*/

class Customer {
  // Properties
  int? id;
  final String cemail;
  final String cphoneNumber;
  final String cname;
  final String cpassword;

  // Constructor
  Customer({
    this.id,
    required this.cemail,
    required this.cphoneNumber,
    required this.cname,
    required this.cpassword,
  });

  Customer.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      cemail = map['cemail'] as String,
      cphoneNumber = map['cphoneNumber'] as String,
      cname = map['cname'] as String,
      cpassword = map['cpassword'] as String;

  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{
      'cemail': cemail,
      'cphoneNumber': cphoneNumber,
      'cname': cname,
      'cpassword': cpassword,
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const List<String> keys = [
    'id',
    'cemail',
    'cphoneNumber',
    'cname',
    'cpassword',
  ];
}

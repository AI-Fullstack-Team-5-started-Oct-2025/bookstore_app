//  Customer Model
/*
  Create: 12/11/2025 15:38, Creator: taekkwon, kim
  Update log: 
    12/11/2025 15:38, 'create Employee Model', Creator: taekkwon, kim
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: Employee Model
*/

class Employee {
  // Properties
  int? id;
  final String email;
  final String phoneNumber;
  final String name;
  final String password;

  // Constructor
  Employee({
    this.id,
    required this.email,
    required this.phoneNumber,
    required this.name,
    required this.password,
  });

  Employee.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      email = map['email'] as String,
      phoneNumber = map['phoneNumber'] as String,
      name = map['name'] as String,
      password = map['password'] as String;

  static const List<String> keys = [
    'id',
    'email',
    'phoneNumber',
    'name',
    'password',
  ];
}

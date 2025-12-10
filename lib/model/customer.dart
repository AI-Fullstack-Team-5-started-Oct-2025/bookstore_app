//  Customer Model
/*
  Create: 10/12/2025 12:11, Creator: Chansol, Park
  Update log: 
    DUMMY 9/29/2025 09:53, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: Customer Model
*/

class Customer {
  // Properties
  int? id;
  final String email;
  final String phoneNumber;
  final String name;
  final String nickname;
  final String password;
  final String imagePath;

  // Constructor
  Customer({
    this.id,
    required this.email,
    required this.phoneNumber,
    required this.name,
    required this.nickname,
    required this.password,
    required this.imagePath
  });

  Customer.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      email = map['email'] as String,
      phoneNumber = map['phoneNumber'] as String,
      name = map['name'] as String,
      nickname = map['nickname'] as String,
      password = map['password'] as String,
      imagePath = map['imagePath'] as String;

  static const List<String> keys = ['id', 'email', 'phoneNumber', 'name', 'nickname', 'password', 'imagePath'];
}

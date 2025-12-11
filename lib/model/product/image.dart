//  Images Model
/*
  Create: 10/12/2025 14:13, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: Images Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Image {
  // Properties
  int? id;
  int? pbid;
  final String imagePath;

  // Constructor
  Image({this.id, this.pbid, required this.imagePath});

  Image.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      pbid = map['pbid'] as int?,
      imagePath = map['imagePath'] as String;
  
  static const List<String> keys = ['id', 'pbid', 'imagePath'];
}
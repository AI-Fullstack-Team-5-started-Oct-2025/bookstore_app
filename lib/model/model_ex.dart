class ModelEx {
  // Properties
  int? id;
  final String value1;
  final double value2;

  // Constructor
  ModelEx({this.id, required this.value1, required this.value2});

  ModelEx.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      value1 = map['value1'] as String,
      value2 = (map['value2'] as num).toDouble();
  
  static const List<String> keys = ['id', 'value1', 'value2'];
  static const List<String> types = ['int?', 'String', 'double'];
}

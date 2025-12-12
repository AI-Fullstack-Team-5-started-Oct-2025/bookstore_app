import 'package:bookstore_app/Restitutor_custom/dao_custom.dart';

//  AssemblyDBHandler
/*
  Create: 12/12/2025 17:35, Creator: Chansol, Park
  Update log: 
    DUMMY 9/29/2025 09:53, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: AssemblyDBHandler
*/

class AssemblyDBHandler {
  final String dbName;
  final int dVersion;

  AssemblyDBHandler({
    required this.dbName,
    required this.dVersion,
  });

  Future<Map<String, List<int>>> insertMultiTableBatch(
    MultiTableBatch batch,
  ) async {
    final db = await RDB.instance(dbName, dVersion);

    final Map<String, List<int>> resultIds = {};

    await db.transaction((txn) async {
      for (final tableBatch in batch.tables) {
        final tName = tableBatch.tableName;
        final rows = tableBatch.rows;
        final List<int> rowIds = [];

        for (final data in rows) {
          final keys = data.keys.join(', ');
          final placeholders =
              List.filled(data.length, '?').join(', ');
          final sql =
              'INSERT INTO $tName ($keys) VALUES ($placeholders)';

          final rowId =
              await txn.rawInsert(sql, data.values.toList());
          rowIds.add(rowId);
        }

        resultIds[tName] = rowIds;
      }
    });

    return resultIds;
  }
}
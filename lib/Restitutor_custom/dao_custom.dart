import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';
import 'package:bookstore_app/config.dart' as config;

//  Custom DB DAOs
/*
  Create: 8/12/2025, Creator: Chansol, Park
  Update log: 
    9/29/2025 09:53, 'Point 1, CRUD table using keys', Creator: Chansol, Park
    9/29/2025 11:17, 'Delete OBSOLETE Functions', Creator: Chansol, Park
    9/29/2025 11:28, 'Point 2, Total class refactored by GPT', Creator: Chansol, Park
    12/12/2025 17:08, 'Point 3, Created Insert multyple datas from multiple/single Table, TableBatch Class', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: DB DAO presets
*/

//  Version, db preset
final String dbName = '${config.kDBName}${config.kDBFileExt}';
final int dVersion = config.kVersion;

//  Point 3
//  single TableBatch
class TableBatch {
  final String tableName;
  final List<Map<String, Object?>> rows;
  TableBatch({required this.tableName, required this.rows});
}
//  multi TableBatch
class MultiTableBatch {
  final List<TableBatch> tables;

  MultiTableBatch({required this.tables});
}

//  AppDatabase onCreate
class RDB {
  static Database? _db;

  static Future<Database> instance(String dbName, int dVersion) async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), dbName);

    _db = await openDatabase(path, version: dVersion);
    if (_db == null) {
      throw Exception('Database is EMPTY');
    }

    return _db!;
  }

  Future<void> validateTableColumns({
    required Database db,
    required String tableName,
    //  ModelEx.keys on expectedColumns
    required List<String> expectedColumns,
  }) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');

    final actualColumns = result.map((row) => row['name'] as String).toList();

    actualColumns.sort();
    final sortedExpected = [...expectedColumns]..sort();

    if (actualColumns.length != sortedExpected.length ||
        !ListEquality().equals(actualColumns, sortedExpected)) {
      print('❌ SCHEMA MISMATCH for $tableName');
      print('  Expected: $sortedExpected');
      print('  Actual:   $actualColumns');
      throw Exception('Schema mismatch for table $tableName');
    } else {
      print('✅ SCHEMA OK for $tableName: $actualColumns');
    }
  }
}

class RDAO<T> {
  final String dbName;
  final String tableName;
  final int dVersion;
  final T Function(Map<String, Object?>) fromMap;

  RDAO({
    required this.dbName,
    required this.tableName,
    required this.dVersion,
    required this.fromMap,
  });

  Future<List<T>> queryAll() async {
    final db = await RDB.instance(dbName, dVersion);
    final sql = 'SELECT * FROM $tableName';
    final results = await db.rawQuery(sql);
    return results.map((e) => fromMap(e)).toList();
  }

  //  DBHandler.queryK({'Key': value})
  Future<List<T>> queryK(Map<String, Object?> keyList) async {
    if (keyList.isEmpty) {
      throw ArgumentError('keyList must NOT be empty');
    }
    final db = await RDB.instance(dbName, dVersion);
    final keyClause = keyList.keys.map((key) => '$key = ?').join(' AND ');
    final values = keyList.values.toList();
    final sql = 'SELECT * FROM $tableName WHERE $keyClause';

    final results = await db.rawQuery(sql, values);
    if (results.isEmpty) {
      throw Exception('EMPTY');
    }
    return results.map((e) => fromMap(e)).toList();
  }

  //  DBHandler.insertK(Tablename.toMap());
  Future<int> insertK(Map<String, Object?> data) async {
    try {
      final db = await RDB.instance(dbName, dVersion);

      final keys = data.keys.join(', ');
      final placeholders = List.filled(data.length, '?').join(', ');
      final sql = 'INSERT INTO $tableName ($keys) VALUES ($placeholders)';

      final result = await db.rawInsert(sql, data.values.toList());

      // 성공 → rowId 반환 (rawInsert는 rowId를 반환)
      return result;
    } on DatabaseException catch (e) {
      // SQLite 관련 에러
      print('INSERT DB Error in $tableName → $e');
      return -1; // 실패 시 구분 값
    } catch (e) {
      // 그 외 모든 오류
      print('UNKNOWN INSERT Error in $tableName → $e');
      return -1; // 실패 시 구분 값
    }
  }

  //  Point 3
  // DBHandler.insertBatch(singleTableBatch);
  Future<List<int>> insertBatch(TableBatch batch) async {
    final List<int> resultIds = [];

    if (batch.rows.isEmpty) {
      return resultIds;
    }

    try {
      final db = await RDB.instance(dbName, dVersion);

      await db.transaction((txn) async {
        for (final data in batch.rows) {
          if (data.isEmpty) {
            continue;
          }

          final keys = data.keys.join(', ');
          final placeholders = List.filled(data.length, '?').join(', ');
          final sql =
              'INSERT INTO ${batch.tableName} ($keys) VALUES ($placeholders)';

          final rowId = await txn.rawInsert(sql, data.values.toList());
          resultIds.add(rowId);
        }
      });

      return resultIds;
    } on DatabaseException catch (e) {
      print('INSERT BATCH DB Error in ${batch.tableName} → $e');
      return List.filled(batch.rows.length, -1);
    } catch (e) {
      print('UNKNOWN INSERT BATCH Error in ${batch.tableName} → $e');
      return List.filled(batch.rows.length, -1);
    }
  }

  // DBHandler.updateK(Tablename.toMap(), KeyListTable.toMap())
  Future<int> updateK(
    Map<String, Object?> data,
    Map<String, Object?> keyList,
  ) async {
    if (data.isEmpty) {
      throw ArgumentError('data must NOT be empty');
    }
    if (keyList.isEmpty) {
      throw ArgumentError('keyList must NOT be empty');
    }
    final db = await RDB.instance(dbName, dVersion);

    final setClause = data.keys.map((k) => '$k = ?').join(', ');
    final keyClause = keyList.keys.map((k) => '$k = ?').join(' AND ');

    final sql = 'UPDATE $tableName SET $setClause WHERE $keyClause';
    final values = [...data.values, ...keyList.values];
    return db.rawUpdate(sql, values);
  }
}

import 'package:bookstore_app/config.dart' as config;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
//  import 'package:bookstore_app/config.dart' as config;

//  Custom DB DAO's
/*
  Create: 8/12/2025, Creator: Chansol, Park
  Update log: 
    9/29/2025 09:53, 'Point 1, CRUD table using keys', Creator: Chansol, Park
    9/29/2025 11:17, 'Delete OBSOLETE Functions', Creator: Chansol, Park
    11/29/2025 11:28, 'Point 2, Total class refactored by GPT', Creator: Chansol, Park
    11/29/2025 11:28, 'Point 3, Customer, Employee added', Creator: Chansol, Park
    12/12/2025 10:55, 'Point 4, Customer.CPname > Customer.cName', Creator: Zero
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: DB DAO presets
*/

//  Version, db preset
final String dbName = '${config.kDBName}${config.kDBFileExt}';
final int dVersion = config.kVersion;

//  AppDatabase onCreate
class DBCreation {
  static Database? _db;

  static Future<Database> creation(String dbName, int dVersion) async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), dbName);

    _db = await openDatabase(
      path,
      version: dVersion,
      onCreate: (db, version) async {

        //  Product
        await db.execute('''
          create table Product (
            id integer primary key autoincrement,
            pbid integer,
            mfid integer,
            size integer,
            basePrice integer
          )
        ''');

        //  ProductBase
        await db.execute('''
          create table ProductBase (
            id integer primary key autoincrement,
            pName text,
            pDescription text,
            pColor text,
            pGender text,
            pStatus text,
            pFeatureType text,
            pCategory text,
            pModelNumber text
          )
        ''');

        //  Manufacturer
        await db.execute('''
          create table Manufacturer (
            id integer primary key autoincrement,
            mName text
          )
        ''');

        //  ProductImage
        await db.execute('''
          create table ProductImage (
            id integer primary key autoincrement,
            pbid integer,
            imagePath text
          )
        ''');

        //  Point3
        //  Customer
        await db.execute('''
          create table Customer (
            id integer primary key autoincrement,
            cEmail text,
            cPhoneNumber text,
            cName text,
            cPassword text
          )
        ''');// Point 4
        
        //  Employee
        await db.execute('''
          create table Employee (
            id integer primary key autoincrement,
            eEmail text,
            ePhoneNumber text,
            eName text,
            ePassword text
          )
        ''');
      },
    );

    return _db!;
  }
}

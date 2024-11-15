import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    // if (_database != null) {
    //   return _database!;
    // }
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'video_database.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        print("version ==>> ${version}");
        var batch = db.batch();
        // We create all the tables
        createTableMessageV1(batch);
        await batch.commit();
      },
      onDowngrade: onDatabaseDowngradeDelete,
      onConfigure: onConfigure,
    );
  }

  void createTableMessageV1(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS message');
    batch.execute('''
CREATE TABLE videos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT, 
      filePath TEXT
      )
''');
  }


  Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

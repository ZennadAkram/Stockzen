import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stockzen/att.dart';
import 'package:stockzen/emp.dart';
import 'package:stockzen/prod.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String path = join(directory.path, 'app_database.db');
      print('Database path: $path');  // Log the path to verify
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate1,
      );
    } catch (e) {
      print('Database initialization failed: $e');
      final logFile = File('error_log.txt');
      await logFile.writeAsString('Database initialization failed: $e');
      throw e;
    }
  }
  void _onCreate1(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY ,
        name TEXT,
        category TEXT,
        quantity INTEGER,
        sell REAL,
        sellprice REAL,
        image BLOB
      )
    ''');
    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER ,
        attend TEXT,
        date TEXT,
        FOREIGN KEY (id) REFERENCES employe(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE employe(
        id INTEGER PRIMARY KEY ,
        name TEXT,
        checkin TEXT,
        checkout TEXT,
        assi TEXT,
        salery REAL,
        image BLOB
      )
    ''');
  }

  // Insert a new item
  Future<void> insertproducts(int id, String name, String category, int quantity, double sell, double sellprice,Uint8List image) async {
    final db = await database;
    await db.insert(
      'items',
      {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'sell': sell,
        'sellprice': sellprice,
        'image': image
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<void> insertat(int id,String attend,String date)async {
    final db=await database;
    await db.insert('attendance',{
    'id':id,
    'attend':attend,
    'date' :date
    },
      conflictAlgorithm: ConflictAlgorithm.replace,

    );

  }
  Future<void> insertemply(int id,String name, String checkin, String checkout, String assi, double salery,  Uint8List imageBytes) async {
    final db = await database;
    await db.insert(
      'employe',
      {
        'id': id,
        'name': name,
        'checkin': checkin,
        'checkout': checkout,
        'assi': assi,
        'salery': salery,
        'image' :imageBytes,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
Future<bool> checkdate(String date,int id) async {
    final db=await database;
    final List<Map<String, dynamic>> result=await db.rawQuery(''
        'SELECT * FROM attendance WHERE date=? AND id=?' ,
      [date,id]
    );
    return result.isNotEmpty;
}
  Future<void> update(int id, String att, String date) async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE attendance SET attend = ? WHERE id = ? AND date = ?',
        [att, id, date]
    );
  }
  Future<void> delete(int id) async{
    final db=await database;
    await db.rawDelete('DELETE FROM attendance WHERE id=?',
    [id]
    );
  }


  Future<List<pro>> getItems() async {
    final db = await DatabaseHelper().database;

    // Fetch rows from the database
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM items');

    // Convert List<Map<String, dynamic>> to List<Pro>
    return List.generate(maps.length, (i) {
      return pro.fromMap(maps[i]);
    });

  }
  Future<List<att>> getat() async {
    final db = await DatabaseHelper().database;

    // Fetch rows from the database
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM attendance');

    // Convert List<Map<String, dynamic>> to List<Pro>
    return List.generate(maps.length, (i) {
      return att.fromMap(maps[i]);
    });

  }
  Future<List<emp>> getItemsemp() async {
    final db = await DatabaseHelper().database;

    // Fetch rows from the database
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM employe');

    // Convert List<Map<String, dynamic>> to List<Pro>
    return List.generate(maps.length, (i) {
      return emp.fromMap(maps[i]);
    });

  }



  Future<void> updatepro(int id,String name,String category,int quantity,double sell,double sellprice,Uint8List image  ) async{
    final db=await DatabaseHelper().database;
    await db.rawUpdate('UPDATE items SET name=?, category=?, quantity=?, sell=?, sellprice=?, image=? WHERE id=?',
    [name,category,quantity,sell,sellprice,image,id],
    );

  }
  Future<void> updateemp(int id,String name,String checkin,String checkout,String assi,double salery,Uint8List imageBytes) async{
    final db=await DatabaseHelper().database;
    await db.rawUpdate('UPDATE employe SET name=?, checkin=?, checkout=?, assi=?, salery=?, image=? WHERE id=?',
      [name,checkin,checkout,assi,salery,imageBytes,id],
    );

  }
  Future<void> deletepro(int id) async{
    final db=await DatabaseHelper().database;
    db.execute('DELETE FROM items WHERE id=?',
    [id],
    );

  }
  Future<void> deleteemp(int id) async {
    final db = await DatabaseHelper().database;
    db.execute('DELETE FROM employe WHERE id=?',
      [id],
    );
  }
  // Delete an item

}

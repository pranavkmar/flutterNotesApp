import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_keeper/models/note.dart';

class DataBaseHelper {
  static DataBaseHelper _dataBaseHelper; //Singleton DatabaseHelper

  static Database _database; //Singleton Database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DataBaseHelper._createInstance(); //Named Constructor to create instance of DataBaseHelper
  factory DataBaseHelper() {
    if (_dataBaseHelper == null) {
      _dataBaseHelper = DataBaseHelper
          ._createInstance(); //This is executed only once, singleton Object
    }
    return _dataBaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDataBase();
    }
    return _database;
  }

  Future<Database> initializeDataBase() async {
    //Get the directory path for both android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    //Open or create the database at the given path
    var notesDataBase = openDatabase(path, version: 1, onCreate: _createDb);

    return notesDataBase;
  }

  void _createDb(Database db, int newVersion) async {
    //TODO:
    await db.execute(
        'CREATE TABLE  $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

//Fetch Operation : Get all the note Objects fro database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = await db
        .rawQuery("SELECT * FROM $noteTable  ORDER BY $colPriority ASC");
    // or can use
//     var result = await db.query(noteTable,orderBy: '$colPriority ASC');
    return result;
  }

  // Insert Operation

  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
  }

  //Update Operation
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Operation
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  //get the number of records

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //Get the 'Map List' [List<Map>] and Convert it to 'Note List' from Database
  Future<List<Note>> getNoteList() async{
    //Get 'Map List' from database
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    //For Loop to create a 'Note List' from a 'Map List'
    for(int i=0; i < count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}

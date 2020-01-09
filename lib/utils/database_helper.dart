import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_keeper/models/note.dart';

class DataBaseHelper {
  static DataBaseHelper _dataBaseHelper; //Singleton DatabaseHelper

  static Database _database; //Singleton Database

  String noteTable = 'note_table';
  String colId= 'id';
  String colTitle= 'title';
  String colDescription= 'description';
  String colPriority= 'priority';
  String colDate= 'date';

  DataBaseHelper._createInstance(); //Named Constructor to create instance of DataBaseHelper
  factory DataBaseHelper() {
    if (_dataBaseHelper == null) {
      _dataBaseHelper = DataBaseHelper
          ._createInstance(); //This is executed only once, singleton Object
    }
    return _dataBaseHelper;
  }



  void _createDb(Database db,int newVersion) async{
    //TODO:
    await db.execute('CREATE TABLE ');
  }
}

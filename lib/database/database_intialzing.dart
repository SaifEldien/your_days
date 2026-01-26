import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sqflite/sqflite.dart';

import '../models/day.dart';
import '../models/user.dart';
import 'database_functions.dart';

class SqlDataBase {
  static late Database _db;
  static const String _usersTable = "CREATE TABLE Users("
      "email TEXT PRIMARY KEY,"
      "name TEXT,"
      "registerDate TEXT,"
      "image VARBINARY"
      ");";
  static const String _daysTable =  "CREATE TABLE Days("
      "details TEXT,"
      "name TEXT,"
      "date TEXT,"
      "status Text,"
      "lastUpdateDate Text,"
      "mood INTEGER,"
      "userEmail TEXT REFERENCES Users(email) ON DELETE CASCADE"
      ");";
  static const String _highlightsTable =  "CREATE TABLE Highlights("
      "title TEXT,"
      "image VARBINARY,"
      "highlight_id TEXT PRIMARY KEY,"
      "date TEXT REFERENCES Days(date) ON DELETE CASCADE"
      ");";

  static initializeDb() async {
    _db = (await openDatabase('yourDaysDatabase.db', version: 1,
        onCreate: (db, version) async {
          print("Created db");
        }));

    await _db.execute(_usersTable).then((value) async {print("Created table");}).catchError((onError) {
      onError.toString().contains('already exists')? print('table already exists '):
      print( 'error in creating table $onError');
    });

    await _db.execute(_daysTable).then((value) async {print("Created table");}).catchError((onError) {
      onError.toString().contains('already exists')? print('table already exists '):
      print( 'error in creating table $onError');
    });

    await  _db.execute(_highlightsTable).then((value) async {print("Created table");}).catchError((onError) {
      onError.toString().contains('already exists')? print('table already exists '):
      print( 'error in creating table $onError');
    });

  }

  static addToUsers(UserClass user) async => await SqlDatabaseQueries.insertIntoUsers(_db,user);

  static usersDays(String userEmail) async => await SqlDatabaseQueries.retrieveUserDays(_db,userEmail);

  static user(String userEmail) async => await SqlDatabaseQueries.retrieveUser(_db,userEmail);

  static addADay(Day day) async => await SqlDatabaseQueries.insertIntoDays(_db, day);

  static deleteADay(Day day) async => await SqlDatabaseQueries.deleteFromDays(_db, day);

  static updateADay(Day day) async => await SqlDatabaseQueries.updateDay(_db, day);

  static updateUser(UserClass user) async => await SqlDatabaseQueries.updateUser(_db, user);

  static deleteAll(String userEmail) async => await SqlDatabaseQueries.deleteAll(_db, userEmail);


}
/*
class SqlDataBase {
  static initializeDb() async {
    await Hive.initFlutter();
    await Hive.openBox('users');
    await Hive.openBox('days');
    await Hive.openBox('highlights');
  }
  static addToUsers(UserClass user) async => await SqlDataBaseQueries.insertIntoUsers(user,tableName: 'users');

  static usersDays(String userEmail) async => await SqlDataBaseQueries.retrieveUserDays(userEmail, tableName: 'days');

  static user(String userEmail) async => await SqlDataBaseQueries.retrieveUser(userEmail,tableName: 'users');

  static addADay(Day day) async => await SqlDataBaseQueries.insertIntoDays(day, tableName: 'days');

  static deleteADay(Day day) async => await SqlDataBaseQueries.deleteFromDays(day,tableName: 'days');

  static updateADay(Day day) async => await SqlDataBaseQueries.updateDay(day,tableName: 'days');

  static updateUser(UserClass user) async => await SqlDataBaseQueries.updateUser(user,tableName: 'users');

}
*/
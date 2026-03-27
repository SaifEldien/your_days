import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../fearutes/data/models/day.dart';
import '../../fearutes/data/models/user.dart';
import 'database_functions.dart';

class SqlDataBase {
  static late Database _db;
  static const String _usersTable =
      "CREATE TABLE Users("
      "email TEXT PRIMARY KEY,"
      "name TEXT,"
      "registerDate TEXT,"
      "image VARBINARY"
      ");";
  static const String _daysTable =
      "CREATE TABLE Days("
      "details TEXT,"
      "name TEXT,"
      "date TEXT,"
      "status TEXT,"
      "lastUpdateDate TEXT,"
      "moodId INTEGER,"
      "userEmail TEXT REFERENCES Users(email) ON DELETE CASCADE,"
      "PRIMARY KEY (date, userEmail)"
      ");";
  static const String _highlightsTable =
      "CREATE TABLE Highlights("
      "title TEXT,"
      "status TEXT,"
      "image VARBINARY,"
      "highlight_id TEXT PRIMARY KEY,"
      "date TEXT REFERENCES Days(date) ON DELETE CASCADE"
      ");";

  static Future<void> initializeDb() async {
    _db = (await openDatabase(
      'yourDaysDatabase.db',
      version: 1,
      onCreate: (db, version) async {
        debugPrint("Created db");
      },
    ));

    await _db
        .execute(_usersTable)
        .then((value) async {
          debugPrint("Created table");
        })
        .catchError((onError) {
          onError.toString().contains('already exists')
              ? debugPrint('table already exists ')
              : debugPrint('error in creating table $onError');
        });

    await _db
        .execute(_daysTable)
        .then((value) async {
          debugPrint("Created table");
        })
        .catchError((onError) {
          onError.toString().contains('already exists')
              ? debugPrint('table already exists ')
              : debugPrint('error in creating table $onError');
        });

    await _db
        .execute(_highlightsTable)
        .then((value) async {
          debugPrint("Created table");
        })
        .catchError((onError) {
          onError.toString().contains('already exists')
              ? debugPrint('table already exists ')
              : debugPrint('error in creating table $onError');
        });
  }

  static Future<void> addToUsers(UserClass user) async =>
      await SqlDatabaseQueries.insertIntoUsers(_db, user);

  static Future<List<Day>> usersDays(String userEmail) async =>
      await SqlDatabaseQueries.retrieveUserDays(_db, userEmail);

  static Future<UserClass> user(String userEmail) async =>
      await SqlDatabaseQueries.retrieveUser(_db, userEmail);

  static Future<void> addADay(Day day) async =>
      await SqlDatabaseQueries.insertIntoDays(_db, day);

  static Future<void> deleteADay(Day day) async =>
      await SqlDatabaseQueries.deleteFromDays(_db, day);

  static Future<void> deleteAHighlight(String id) async =>
      await SqlDatabaseQueries.deleteAHighlight(_db, id);

  static Future<void> updateADay(Day day) async =>
      await SqlDatabaseQueries.updateDay(_db, day);

  static Future<void> updateUser(UserClass user) async =>
      await SqlDatabaseQueries.updateUser(_db, user);

  static Future<void> deleteAll(String userEmail) async =>
      await SqlDatabaseQueries.deleteAll(_db, userEmail);

  static Future<void> addMultipleDays(List<Day> days) async =>
      await SqlDatabaseQueries.addMultipleDays(_db, days);
}

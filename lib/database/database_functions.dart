import 'package:hive/hive.dart';
import 'package:sqflite/sqflite.dart';
import '../const/functions.dart';
import '../database/database_intialzing.dart';

import '../models/day.dart';
import '../models/highlight.dart';
import '../models/user.dart';

class SqlDatabaseQueries {
  static Future<void> insertIntoUsers(Database db, UserClass user) async {
    String sql = "INSERT INTO Users (email,name,registerDate,image"
        ") VALUES('${user.email}','${user.name}','${user.registerDate}', '${user.image}')";
    await db.transaction((txn) => txn.rawInsert(sql).then((value) {
          print("$value insertion done");
        }).catchError((onError) {}));
  }

  static Future<void> insertIntoDays(Database db, Day day) async {
    await db.transaction((txn) => txn.rawInsert(
            'INSERT INTO Days (details,name,date,mood,userEmail,status,lastUpdateDate) VALUES(?,?,?,?,?,?,?)',
            [
              '${day.details}',
              '${day.name}',
              '${day.date}',
              '${day.mood!.id}',
              '${day.userEmail}',
              '${day.status}',
              '${day.lastUpdateDate}'
            ]).then((value) {
          print("$value insertion done");
        }).catchError((onError) {
          print(onError);
        }));
    for (int i = 0; i < day.highlights!.length; i++) {
      await insertIntoHighlights(db, day.highlights![i]);
    }
  }

  static Future<void> deleteFromDays(Database db, Day day) async {
    String sql =
        "DELETE FROM Days WHERE userEmail = '${day.userEmail}' AND date = '${day.date}'";
    await db.transaction((txn) => txn.rawInsert(sql).then((value) {
          print("$value DELETION DAY done");
        }).catchError((onError) {}));
    await deleteFromHighlights(db, day);

  }

  static Future<void> insertIntoHighlights(Database db, Highlight highlight) async {
    await db.transaction((txn) => txn.rawInsert(
        'INSERT INTO Highlights (title,image,highlight_id,date) VALUES(?,?,?,?)'
        , ['${highlight.title}','${highlight.image}','${highlight.id}', '${highlight.date}']
    ).then((value) {
          print("$value insertion done highlights");
        }).catchError((onError) {
          print(onError);
        }));
  }

  static Future<void> deleteFromHighlights(Database db, Day day) async {
    String sql = "DELETE FROM Highlights WHERE highlight_id LIKE '%${day.date}|${day.userEmail}%' ";
    await db.transaction((txn) => txn.rawInsert(sql).then((value) {
          print("$value deletion done highlights");
        }).catchError((onError) {
          print(onError);
        }));
  }

  static Future<void> deleteAllHighlights(Database db, String userEmail) async {
    String sql = "DELETE FROM Highlights WHERE highlight_id LIKE '%$userEmail%' ";
    await db.transaction((txn) => txn.rawInsert(sql).then((value) {
      print("$value deletion done all highlights");
    }).catchError((onError) {
      print(onError);
    }));
  }

  static Future<void> deleteAllDays(Database db, String userEmail) async {
    String sql = "DELETE FROM Days WHERE userEmail='$userEmail' ";
    await db.transaction((txn) => txn.rawInsert(sql).then((value) {
      print("$value deletion done all days");
    }).catchError((onError) {
      print(onError);
    }));
  }

  static Future<void> deleteAll(Database db, String userEmail) async {
      await deleteAllDays(db, userEmail);
      await deleteAllHighlights(db, userEmail);

  }

  static Future<UserClass> retrieveUser(Database db, String email) async {
    String sql = "SELECT * FROM Users WHERE email = '$email'";
    List users = await db.rawQuery(sql);
    return UserClass.fromJson(users.first, await SqlDataBase.usersDays(email));
  }

  static Future<List<Day>> retrieveUserDays(Database db, String email) async {
    String sql = "SELECT * FROM Days WHERE userEmail = '$email'";
    List days = await db.rawQuery(sql);
    List<Day> daysList = [];
    for (int i = 0; i < days!.length; i++) {
      daysList.add(
          Day.fromJson(
          days[i], await retrieveDayHighlights(db, '${days[i]['date']}|${email}')
          ));
    }
    return sortDays(daysList);
  }

  static Future<List<Highlight>> retrieveDayHighlights(Database db, String highlightId) async {
    String sql = "SELECT * FROM Highlights WHERE highlight_id LIKE '%$highlightId%'";
    List highlights = await db.rawQuery(sql);
    List <Highlight> list = List.generate(highlights.length, (index) => Highlight.fromJson(highlights[index]));
    return list;
  }

  static Future<void> updateDay(Database db, Day day) async {
    await deleteFromDays(db, day);
    await deleteFromHighlights(db, day);
    await insertIntoDays(db, day);

  }

  static Future<void> updateUser(Database db, UserClass user) async {
    await db.transaction((txn) => txn.rawInsert(
        "Update Users SET name = ? , image = ? WHERE email = '${user.email}'",
        [
          '${user.name}',
          '${user.image}',
        ]).then((value) {
      print("$value user update done");
    }).catchError((onError) {
      print(onError);
    }));
  }




}
/*
class SqlDataBaseQueries {
  static  insertIntoUsers  (UserClass user, {required String tableName}) async {
    var table = await Hive.openBox(tableName);
    await table.add(user.toJson());
  }
  static  insertIntoDays (Day day, {required String tableName}) async {
    var table = await Hive.openBox(tableName);
    await table.add(day.toJson());
  }
  static  insertIntoHighlights (Highlight highlight, {required String tableName}) async {
    var table = await Hive.openBox(tableName);
    await table.add(highlight.toJson());
  }

  static  deleteFromDays (Day day, {required String tableName}) async {
    var table = await Hive.openBox(tableName);
    await table.delete(day.toJson());
  }
  static  deleteFromHighlights (Highlight highlight, {required String tableName}) async {
    var table = await Hive.openBox(tableName);
    await table.delete(highlight.toJson());
  }

  static retrieveDayHighlights (String highlightId, {required String tableName}) async {
    var table = await Hive.openBox(tableName);
    return  table.values.toList().where((element) => element["highlightId"].toString().contains(highlightId)).map((e) => Highlight.fromJson(e)).toList();
  }

  static retrieveUserDays (String userEmail, {required String tableName}) async {
    var table = await Hive.openBox(tableName);
    List days = table.values.toList().where((element) => element["userEmail"] == userEmail).toList();
    List<Day> daysList = [];

    for (int i = 0; i < days!.length; i++) {
      daysList.add(
          Day.fromJson(
              days[i], await retrieveDayHighlights('${days[i]['date']}|$userEmail', tableName: tableName))
          );
    }
    return sortDays(daysList);
  }

  static retrieveUser (String userEmail, {required String tableName})async  {
    var table = await Hive.openBox(tableName);
    return UserClass.fromJson(table.values.toList().firstWhere((element) => element["email"]==userEmail),await SqlDataBase.usersDays(userEmail));
  }

  static updateDay (Day day, {required String tableName}) async {

  }

  static updateUser (UserClass user, {required String tableName}) async {

  }
}
 */
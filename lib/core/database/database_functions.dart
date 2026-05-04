import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../fearutes/data/models/day.dart';
import '../../fearutes/data/models/highlight.dart';
import '../../fearutes/data/models/user.dart';
import 'database_intialzing.dart';


class SqlDatabaseQueries {
  static Future<void> insertIntoUsers(Database db, UserClass user) async {
    await db.insert(
      'Users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    ).then((value) => debugPrint("✅ User insertion done"));
  }

  static Future<void> updateDay(Database db, Day day) async {
    try {
      await db.transaction((txn) async {
        await txn.insert(
          'Days',
          day.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        if (day.deletedHighlights != null && day.deletedHighlights!.isNotEmpty) {
          for (var h in day.deletedHighlights!) {
            await txn.delete(
              'Highlights',
              where: 'highlight_id = ?',
              whereArgs: [h.id],
            );
          }
        }
        if (day.highlights != null) {
          for (var h in day.highlights!) {
            await txn.insert(
              'Highlights',
              {
                'highlight_id': h.id,
                'title': h.title,
                'date': day.date,
                'image': h.image,
                'status': 'available',
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });
      debugPrint("✅ Update Flowless Done");
    } catch (e) {
      debugPrint("❌ Update Error: $e");
      rethrow;
    }
  }  static Future<List<Day>> retrieveUserDays(Database db, String email) async {
    // 1. جلب الأيام فقط الخاصة باليوزر
    final List<Map<String, dynamic>> dayMaps = await db.query(
      'Days',
      where: 'userEmail = ?',
      whereArgs: [email.trim()],
      orderBy: 'date DESC',
    );

    if (dayMaps.isEmpty) return [];

    // 2. جلب الـ Highlights باستخدام الـ Email المباشر (بدون LIKE لو أمكن)
    // والأفضل نعتمد على عمود الـ date لربطهم
    final List<Map<String, dynamic>> allHighlightMaps = await db.query(
      'Highlights',
      where: 'highlight_id LIKE ?',
      whereArgs: ['%|$email%'],
    );

    Map<String, List<Highlight>> highlightsByDate = {};

    for (var hMap in allHighlightMaps) {
      String? dateKey = hMap['date']?.toString().trim();
      if (dateKey != null) {
        if (!highlightsByDate.containsKey(dateKey)) {
          highlightsByDate[dateKey] = [];
        }
        highlightsByDate[dateKey]!.add(Highlight.fromJson(hMap));
      }
    }
    return dayMaps.map((dayMap) {
      String date = dayMap['date'].toString().trim();
      List<Highlight> dayHighlights = highlightsByDate[date] ?? [];
      return Day.fromJson(dayMap, dayHighlights, email: email);
    }).toList();
  }
  static Future<void> insertIntoDays(Database db, Day day) async {
    try {
      await db.transaction((txn) async {
        int id = await txn.rawInsert(
          'INSERT OR REPLACE INTO Days (details,name,date,moodId,userEmail,status,lastUpdateDate) VALUES(?,?,?,?,?,?,?)',
          [
            day.details,
            day.name,
            day.date,
            day.mood!.id,
            day.userEmail,
            day.status,
            day.lastUpdateDate,
          ],
        );
        debugPrint("$id insertion done for day");
        if (day.highlights != null) {
          for (var h in day.highlights!) {
            await insertIntoHighlights(txn, h);
          }
        }
      });
    } catch (e) {
      debugPrint("❌ Error in insertIntoDays: $e");
    }
  }



  static Future<void> deleteFromDays(Database db, Day day) async {
    await db.transaction((txn) async {
      await txn.delete(
        'Days',
        where: 'userEmail = ? AND date = ?',
        whereArgs: [day.userEmail, day.date],
      );

      if (day.highlights != null && day.highlights!.isNotEmpty) {
        await txn.delete(
          'Highlights',
          where: 'date = ? AND highlight_id LIKE ?',
          whereArgs: [day.date, '%${day.userEmail}%'],
        );
      }
    });
  }

  static Future<void> deleteAHighlight(Database db, String id) async {
    try {
      int result = await db.delete(
        'highlights',
        where: 'highlight_id = ?',
        whereArgs: [id],
      );
      if (result > 0) {
        debugPrint("Success: Highlight $id permanently removed from Local DB.");
      } else {
        debugPrint("Warning: No highlight found with id $id to delete.");
      }
    } catch (e) {
      debugPrint("Error in hardDeleteHighlight: $e");
      rethrow;
    }
  }

  static Future<void> insertIntoHighlights(
      DatabaseExecutor db,
      Highlight highlight,
      ) async {
    try {
      final int rowId = await db.rawInsert(
        'INSERT OR REPLACE INTO Highlights (title, status, image, highlight_id, date) VALUES (?, ?, ?, ?, ?)',
        [
          highlight.title,
          highlight.status ?? 'available',
          highlight.image,
          highlight.id,
          highlight.date,
        ],
      );
      debugPrint("✅ Raw Insert Success into highlights: Row ID $rowId");
    } catch (e) {
      debugPrint("❌ SQL Error in Highlights: $e");
      rethrow;
    }
  }

  static Future<void> deleteFromHighlights(Database db, Day day) async {
    String sql =
        "DELETE FROM Highlights WHERE highlight_id LIKE '%${day.date}|${day.userEmail}%' ";
    await db.transaction(
      (txn) => txn
          .rawInsert(sql)
          .then((value) {
            debugPrint("$value deletion done highlights");
          })
          .catchError((onError) {
            debugPrint(onError);
          }),
    );
  }

  static Future<void> deleteAllHighlights(Database db, String userEmail) async {
    String sql =
        "DELETE FROM Highlights WHERE highlight_id LIKE '%$userEmail%' ";
    await db.transaction(
      (txn) => txn
          .rawInsert(sql)
          .then((value) {
            debugPrint("$value deletion done all highlights");
          })
          .catchError((onError) {
            debugPrint(onError);
          }),
    );
  }

  static Future<void> deleteAllDays(Database db, String userEmail) async {
    String sql = "DELETE FROM Days WHERE userEmail='$userEmail' ";
    await db.transaction(
      (txn) => txn
          .rawInsert(sql)
          .then((value) {
            debugPrint("$value deletion done all days");
          })
          .catchError((onError) {
            debugPrint(onError);
          }),
    );
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

  static Future<List<Highlight>> retrieveDayHighlights(
    Database db,
    String highlightId,
  ) async {
    String sql =
        "SELECT * FROM Highlights WHERE highlight_id LIKE '%$highlightId%'";
    List highlights = await db.rawQuery(sql);
    List<Highlight> list = List.generate(
      highlights.length,
      (index) => Highlight.fromJson(highlights[index]),
    );
    return list;
  }

  static Future<void> updateUser(Database db, UserClass user) async {
    await db.transaction(
      (txn) => txn
          .rawInsert(
            "Update Users SET name = ? , image = ? WHERE email = '${user.email}'",
            ['${user.name}', '${user.image}'],
          )
          .then((value) {
            debugPrint("$value user update done");
          })
          .catchError((onError) {
            debugPrint(onError);
          }),
    );
  }

  static Future<void> addMultipleDays(Database db, List<Day> days) async {
    await db.transaction((txn) async {
      for (var day in days) {
        debugPrint("Day Date: ${day.toJson()}");
        await txn.insert(
          'Days',
          day.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      final hBatch = txn.batch();
      for (var day in days) {
        if (day.highlights != null && day.highlights!.isNotEmpty) {
          for (var h in day.highlights!) {
            debugPrint("Highlight ID: ${h.id}");
            hBatch.insert(
              'Highlights',
              {
                'highlight_id': h.id,
                'title': h.title,
                'date': h.date,
                'image': h.image,
                'status': h.status ?? 'available',
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }

      // 3. تنفيذ كل الـ Highlights مرة واحدة
      await hBatch.commit(noResult: true);
    });

    debugPrint("✅ Database Synced: ${days.length} days and their highlights linked successfully.");
  }
}

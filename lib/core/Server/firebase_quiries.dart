import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../fearutes/data/models/day.dart';
import '../../fearutes/data/models/highlight.dart';
import '../../fearutes/data/models/user.dart';
import '../database/database_intialzing.dart';


class FireBaseQueries {
  static Future<void> addDays(UserClass user) async {
    final userEmail = user.email!;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    int count = 0;
    for (var day in user.days) {
      var dayRef = FirebaseFirestore.instance
          .collection(userEmail)
          .doc("Days")
          .collection("Days")
          .doc(day.date);

      batch.set(dayRef, day.toJson());
      count++;

      if (day.highlights != null) {
        for (var highlight in day.highlights!) {
          var hRef = dayRef.collection("Highlights").doc(highlight.id);
          batch.set(hRef, {
            'id': highlight.id,
            'date': highlight.date,
            'title': highlight.title,
            'image': highlight.image,
          });
          count++;
          if (count >= 450) {
            await batch.commit();
            batch = FirebaseFirestore.instance.batch();
            count = 0;
          }
        }
      }
      if (count >= 450) {
        await batch.commit();
        batch = FirebaseFirestore.instance.batch();
        count = 0;
      }
    }
    if (count > 0) {
      await batch.commit();
    }
  }

  static Future<List<Day>?> retrieveDays(String email) async {
    try {
      var snapShots = await FirebaseFirestore.instance
          .collection(email)
          .doc("Days")
          .collection("Days")
          .get();

      var fetchTasks = snapShots.docs.map((doc) async {
        Map dayData = doc.data();
        var highlights = await retrieveHighlights(dayData['date'], email);
        return Day.fromJson(dayData, highlights, email:  email);
      }).toList();
      debugPrint("done retreving days ${fetchTasks.length}");
      return await Future.wait(fetchTasks);
    } catch (e) {
      debugPrint("The Fucking Error is : $e");
    }
    return null;
  }

  static Future<void> addUser(UserClass user) async {
    await FirebaseFirestore.instance
        .collection(user.email!)
        .doc('info')
        .set({
          'email': user.email,
          'image': user.image,
          'name': user.name,
          'registerDate': user.registerDate,
        })
        .then((value) => () {});
  }

  static Future<UserClass?> retrieveUser(String email) async {
    DocumentSnapshot snapshots = await FirebaseFirestore.instance
        .collection(email)
        .doc("info")
        .get();
    if (!snapshots.exists) return null;
    var data = snapshots;
    return UserClass(
      data.get('email'),
      data.get('name'),
      data.get('image'),
      data.get('registerDate'),
      [],
    );
  }

  static Future<void> addHighlights(Day day) async {
    List<Highlight> highlights = day.highlights!;
    for (int i = 0; i < highlights.length; i++) {
      await FirebaseFirestore.instance
          .collection(day.userEmail!)
          .doc("Days")
          .collection("Days")
          .doc(highlights[i].date)
          .collection("Highlights")
          .doc(highlights[i].id)
          .set({
            'id': highlights[i].id,
            'date': highlights[i].date,
            'title': highlights[i].title,
            'image': highlights[i].image,
          })
          .then((value) => () {});
    }
  }

  static Future<void> setBackupDate(String userEmail, String date) async {
    await FirebaseFirestore.instance
        .collection(userEmail)
        .doc("BackupDate")
        .set({'date': date})
        .then((value) => () {});
  }

  static Future<void> uploadData(UserClass user) async {
    try {
      await addUser(user);
      await addDays(user);
      await deleteDataUploaded(user);
      setBackupDate(user.email!, DateTime.now().toString());
      debugPrint("Backup Successful");
    } catch (e) {
      debugPrint("Backup Failed: $e");
      rethrow;
    }
  }

  static Future<String> retrieveBackUpDate(String email) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(email)
          .doc("BackupDate")
          .get();
      var data = documentSnapshot;
      return data["date"].toString();
    } catch (e) {
      return '';
    }
  }

  static Future<List<Highlight>> retrieveHighlights(
    String dayDate,
    String userEmail,
  ) async {
    List<Highlight> highlights = [];
    QuerySnapshot<Map<String, dynamic>> snapShots = await FirebaseFirestore
        .instance
        .collection(userEmail)
        .doc("Days")
        .collection("Days")
        .doc(dayDate)
        .collection("Highlights")
        .get();
    var docs = snapShots.docs;
    for (int i = 0; i < docs.length; i++) {
      final Map<String, dynamic> data = docs[i].data();
      highlights.add(Highlight.fromJson(data));
    }
    debugPrint(
      "Done retriving highlights for : $dayDate , ${highlights.length} highlights",
    );
    return highlights;
  }

  static Future<void> downloadData(UserClass user) async {
    if (user.email == null) return;
    List<Day> uploadedDays = await retrieveDays(user.email!) ?? [];
    List<Day> localDays = user.days;
    List<String?> localDates = localDays.map((day) => day.date).toList();
    List<Day> newDays = uploadedDays.where((day) {
      return !localDates.contains(day.date);
    }).toList();
    if (newDays.isEmpty) {
      debugPrint("✅ No new days to download. Local database is up to date.");
      return;
    }
    await SqlDataBase.addMultipleDays(newDays);
    debugPrint("📥 Downloaded ${newDays.length} new days from Firebase.");
  }

  static Future<void> deleteDataUploaded(UserClass user) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    try {
      List<Day> deletedDays = user.deletedDays ?? [];
      for (var day in deletedDays) {
        DocumentReference dayRef = firestore
            .collection(user.email!)
            .doc('Days')
            .collection('Days')
            .doc(day.date);
        var highlightsSnapshot = await dayRef.collection('Highlights').get();
        for (var doc in highlightsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        batch.delete(dayRef);
        SqlDataBase.deleteADay(day);
      }
      List<Day> allDays = user.days;
      for (var day in allDays) {
        DocumentReference dayRef = firestore
            .collection(user.email!)
            .doc('Days')
            .collection('Days')
            .doc(day.date);
        if (day.deletedHighlights != null &&
            day.deletedHighlights!.isNotEmpty) {
          for (var h in day.deletedHighlights!) {
            DocumentReference hRef = dayRef.collection('Highlights').doc(h.id);
            batch.delete(hRef);
            SqlDataBase.deleteAHighlight(h.id!);
          }
          debugPrint(
            "Cleaned ${day.deletedHighlights!.length} highlights from day: ${day.date}",
          );
        }
      }
      await batch.commit();
      debugPrint("Full Sync Cleanup Completed.");
    } catch (e) {
      debugPrint("Cleanup Failed: $e");
      throw Exception("Global Sync Delete Failed");
    }
  }

  static Future<void> deleteInfo(String email) async {
    await FirebaseFirestore.instance.collection(email).doc("info").delete();
  }
}

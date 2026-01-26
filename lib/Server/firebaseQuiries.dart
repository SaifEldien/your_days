import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../const/functions.dart';
import '../const/vars.dart';
import '../database/database_intialzing.dart';
import '../models/day.dart';
import '../models/highlight.dart';
import '../models/user.dart';

class FireBaseQueries {
  static Future<void> addUser(UserClass user) async {
    await FirebaseFirestore.instance.collection(user!.email!).doc('info').set({
      'email': user.email,
      'image': user.image,
      'name': user.name,
      'registerDate': user.registerDate
    }).then((value) => () {});
  }

  static Future<bool> userExist(String email) async {
    var querySnapshot = await FirebaseFirestore.instance.collection(email).doc('info').get();
    return querySnapshot.exists;
  }

  static Future<UserClass> retrieve(String email) async {
    DocumentSnapshot snapshots =
        await FirebaseFirestore.instance.collection(email).doc("info").get();
    var data = snapshots;
    return UserClass(data.get('email'), data.get('name'), data.get('image'), data.get('registerDate'), []);
  }

  static Future<void> addDays(UserClass user) async {
    List <Day> days = user.days!;
    for (int i=0;i<days.length;i++) {
      await FirebaseFirestore.instance.collection(user!.email!).doc("Days").collection("Days").doc(days[i].date).set({
      'date': days[i].date ,
      'name': days[i].name,
      'details': days[i].details,
      'moodId': days[i].mood!.id,
        'lastUpdateDate' : days[i].lastUpdateDate,
        'status' : days[i].status
    }).then((value) => () {});
      await addHighlights(days[i]);
    }

  }

  static Future<void> addHighlights(Day day) async {
    List<Highlight> highlights = day.highlights! ;
    for (int i=0;i<highlights.length;i++) {
      await FirebaseFirestore.instance.collection(day.userEmail!).
      doc("Days").collection("Days").doc(highlights[i].date).
      collection("Highlights").doc(highlights[i].id).set({
      'id': highlights[i].id,
      'date': highlights[i].date,
      'title': highlights[i].title,
      'image': highlights[i].image
    }).then((value) => () {});
  }
  }

  static Future<void> setBackupDate(String userEmail,String date) async {
      await FirebaseFirestore.instance.collection(userEmail!).
      doc("BackupDate").set({
        'date': date,
      }).then((value) => () {});
  }

  static Future<void> uploadData(UserClass user) async {
    await deleteDataUploaded(user);
    await addUser(user);
    await addDays(user);
    await setBackupDate(user.email!, DateTime.now().toString());
  }

  static Future<String> retrieveBackUpDate(String email) async {
    try {
      DocumentSnapshot documentSnapshot =
      await FirebaseFirestore.instance.collection(email)
          .doc("BackupDate")
          .get();
      var data = documentSnapshot;
      return data["date"].toString();
    }
    catch (e) {return '';}
  }

  static Future<List<Day>> retrieveDays(String email) async {
    List <Day> days= [];
    QuerySnapshot snapShots =  await FirebaseFirestore.instance.collection(email).doc("Days").collection("Days").get();
   var docs = snapShots.docs;
   for (int i=0;i<docs.length;i++) {
     days.add( Day(moods[docs[i]['moodId']],docs[i]['name'],docs[i]['date'],docs[i]['details'],email, [], docs[i]['lastUpdateDate'],docs[i]['status']));
   }
   return days;
  }

  static Future<List<Highlight>> retrieveHighlights(Day day) async {
    List <Highlight> highlights= [];
    QuerySnapshot snapShots =  await FirebaseFirestore.instance.collection(day.userEmail!).
    doc("Days").collection("Days").doc(day.date).collection("Highlights").get();
    var docs = snapShots.docs;
    for (int i=0;i<docs.length;i++) {
      highlights.add(
        Highlight(docs[i]['id'], docs[i]['date'], docs[i]['title'], docs[i]['image'])
      );
    }
    return highlights;
  }

  static Future<void> downloadData(UserClass user) async {
    List<Day> uploadedDays = await retrieveDays(user.email!);
    List <Day> currentDays = await SqlDataBase.usersDays(user.email!);
    for (int i=0;i<uploadedDays.length;i++) {
      if (isDayExist(currentDays,uploadedDays[i].date)) {
        continue;
      } else {
        uploadedDays[i].highlights =await retrieveHighlights(uploadedDays[i]);
        await SqlDataBase.addADay(uploadedDays[i]);
      }
    }
    UserClass userClass = await retrieve(user.email!);
    await SqlDataBase.updateUser(userClass);
  }

  static Future<void> deleteDataUploaded(UserClass user ,{bool isUpload = true}) async {
    await deleteDays(user.email!);
    await deleteInfo(user.email!);
    if (!isUpload) {
      await removePref("userEmail");
      await FirebaseAuth.instance.currentUser!.delete();
     // await FirebaseAuth.instance.signOut();
    }
 }

static deleteDays(String email) async {
  var collection = FirebaseFirestore.instance.collection(email).doc("Days").collection("Days");
  var snapshots = await collection.get();
  for (var doc in snapshots.docs) {
    print(doc.get('date'));
   await deleteHighLights(email, doc.get('date'));
    await doc.reference.delete();
  }
}

static deleteHighLights(String email,String date) async {
  var collection = FirebaseFirestore.instance.collection(email).doc("Days")
      .collection("Days").doc(date).collection("Highlights");
  var snapshots = await collection.get();
  for (var doc in snapshots.docs) {
    await doc.reference.delete();
  }
}

static deleteInfo(String email) async {
  await FirebaseFirestore.instance.collection(email!).doc("info").delete();
}


}

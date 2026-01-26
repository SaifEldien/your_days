
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern


  static const channelId = "1";

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static  final AndroidNotificationDetails _androidNotificationDetails =
 AndroidNotificationDetails(
      'chanel id', 'channel NAME',
      priority: Priority.high,
      importance: Importance.max,
      ledColor: Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500);
  //var iOS = new IOSNotificationDetails();

  static final NotificationDetails notificationDetails =  NotificationDetails(
    android: _androidNotificationDetails,
  );

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>();
    final bool? granted = await androidImplementation?.requestPermission();
    }

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
    );
    // *** Initialize timezone here ***
    tz.initializeTimeZones();
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }


  static Future<void> showNotification(int id, String title, String body,
      String payload) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({required String title,required String body,
    Map? eventTime
  }) async {
    int days =0;
    int hours = 0;
    int minutes =0;
    int seconds = 1;
    if (eventTime!=null) {
      days =  eventTime['days']?? 0;
      hours =  eventTime['hours']?? 0;
      minutes =  eventTime['minutes']?? 0;
     seconds=  eventTime['seconds']?? 1;
    }

    final scheduledTime = DateTime.now().add(Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds
    ));
    await flutterLocalNotificationsPlugin.zonedSchedule(
       int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(6)),
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      //payload: payload,
     // matchDateTimeComponents: dateTimeComponents,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future getNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
    await FlutterLocalNotificationsPlugin().pendingNotificationRequests();
    return pendingNotificationRequests;
  }


  Future<void> onSelectNotification(String? payload) async {
    // await navigatorKey.currentState
    //     ?.push(MaterialPageRoute(builder: (_) => DetailsPage(payload: payload)));
  }



}


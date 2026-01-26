import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';

import '../Server/firebaseQuiries.dart';
import '../bloC/app_theme_bloc/app_theme_cubit.dart';
import '../components/custom_drawer.dart';
import '../database/database_intialzing.dart';
import '../models/day.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../notification/notification_services.dart';
import '../screens/auth_screens/login_screen.dart';
import '../screens/chart_screen.dart';
import '../screens/days_screen.dart';
import '../screens/filteredDaysScreen.dart';
import '../screens/on_boarding.dart';
import 'vars.dart';

Future setPref(String key, var value) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString(key, value);
}

getPref(String key) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.get(key);
}

removePref(String key) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.remove(key);
}

goTo(context, page, {add = false}) async {
  if (add) {
    await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => page,
        ));
  } else {
    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => page,
      ),
      (route) => false, //if you want to disable back feature set to false
    );
  }
}

showToast(String message, {long = false}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: long ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 14);
}

showAlert(context, confirmText, Function functionToExecute) {
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );
  Widget continueButton = TextButton(
      child: const Text("Yes"),
      onPressed: () async {
        functionToExecute();
        Navigator.of(context, rootNavigator: true).pop();
      });
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.grey[200],
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.0))),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        confirmText,
      ],
    ),
    actions: [
      Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cancelButton,
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
            ),
            continueButton,
          ],
        ),
      )
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showLoading(BuildContext context, bool show) {
  show == true
      ? showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: Container(
                    height: 50,
                    width: 50,
                    child: const CircularProgressIndicator()),
              ),
            );
          },
        )
      : Navigator.of(context, rootNavigator: true).pop('dialog');
}

formatDate(DateTime date) {
  return date.toString().substring(0, 10);
}

pickImage({@required context}) async {
  XFile? pickedFile;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 70,
                ),
                onPressed: () async {
                  pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 90,
                    maxHeight: 1000,
                  );
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                }),
            TextButton(
              child: const Icon(
                Icons.wallpaper,
                color: Colors.white,
                size: 70,
              ),
              onPressed: () async {
                pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 90,
                  maxHeight: 1000,
                );
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            )
          ],
        ),
      );
    },
  );

  return base64Encode(File(pickedFile!.path)!.readAsBytesSync());
}

showImage(String image) {
  //print(image);
  return base64Decode(image);
}

bool isValidEmail(email) {
  return RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(email);
}

Future<void> pickColor(context) async {
  Color col = BlocProvider.of<AppThemeCubit>(context).color;
  await showDialog(
    context: context,
    builder: (BuildContext) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // title: const Text('Pick a color!',),
        content: SingleChildScrollView(
          child: BlockPicker(
            onColorChanged: (Color value) async {
              await BlocProvider.of<AppThemeCubit>(context)
                  .changeColor(value.value);
            },
            pickerColor: col,
          ),
        )),
  );
}

pickFont(context) async {
  await showDialog(
    context: context,
    builder: (BuildContext) => AlertDialog(
      backgroundColor: Colors.grey[200],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      //backgroundColor: Colors.transparent,
      elevation: 0,
      // title: const Text('Pick a color!',),
      content: SingleChildScrollView(
          child: SizedBox(
        width: double.maxFinite,
        child: FontPicker(
          initialFontFamily: 'Anton',
          showInDialog: true,
          onFontChanged: (PickerFont font) async {
            await BlocProvider.of<AppThemeCubit>(context).changeFont(font.fontFamily);
            print(font.fontFamily);
            //_selectedFont = font;
            print(
                "${font.fontFamily} with font weight ${font.fontWeight} and font style ${font.fontStyle}.}");
          },
        ),
      )),
    ),
  );
}

List<Day> sortDays(List<Day> list) {
  List<Day> days = list;
  for (int i = 0; i < days.length; i++) {
    for (int j = 0; j < days.length; j++) {
      if (DateTime.parse(days[j]!.date!)
          .isBefore(DateTime.parse(days[i]!.date!))) {
        Day temp = days[i];
        days[i] = days[j];
        days[j] = temp;
      }
    }
  }
  return days;
}

double numberOfOccurence(List<Day> days, int id) {
  double number = 0;
  for (int i = 0; i < days.length; i++) {
    days[i].mood!.id == id ? number++ : null;
  }
  return number;
}

checkConnection({toast = true}) async {
  try {
     await InternetAddress.lookup('www.google.com')
        .timeout(Duration(milliseconds: 750));
  } catch (e) {
    if (toast == true) showToast("No internet access!");
    return false;
  }
  return true;
}
  setHomeWallpaper (value) {
   String homeWallpaper = 'assets/images/home wallpapers/blue1.jpg';
   if (value == 4294951175) {
    homeWallpaper = 'assets/images/home wallpapers/orange2.jpg';
  } else if (value == 4294940672)
    homeWallpaper = 'assets/images/home wallpapers/orange3.jpg';
  else if (value == 4294924066)
    homeWallpaper = 'assets/images/home wallpapers/orange4.jpg';
  else if (value == 4286141768)
    homeWallpaper = 'assets/images/home wallpapers/brown1.jpg';
  else if (value == 4288585374)
    homeWallpaper = 'assets/images/home wallpapers/grey1.jpg';
  else if (value == 4284513675)
    homeWallpaper = 'assets/images/home wallpapers/grey2.jpg';
  else if (value == 4278190080)
    homeWallpaper = 'assets/images/home wallpapers/black1.jpg';

  return homeWallpaper;
}

int highLightsNumber(List conts) {
  int num = 0;
  for (int i = 0; i < conts.length; i++) if (conts[i].text != '') num++;
  return num;
}

drawerButtons(context, user) {
  return [
    DrawerBtn(Icons.cloud_upload_sharp, "Upload a BackUp", () async {
      if (!await checkConnection()) return;

      showLoading(context, true);
      String date = await FireBaseQueries.retrieveBackUpDate(user.email!);
      if (date != '') {
        date = "you sure to upload a backup?";
      } else if (date == '') {
        date = "uploaded backup you sure?";
      }
      showLoading(context, false);
      showAlert(context, Text(date), () async {
        showLoading(context, true);
        showLoading(context, true);
        await FireBaseQueries.uploadData(user);
        showLoading(context, false);
        showLoading(context, false);
        showToast("Done!");
      });
    }),
    DrawerBtn(Icons.cloud_download_sharp, "Download Backup", () async {
      if (!await checkConnection()) return;
      showLoading(context, true);
      String date = await FireBaseQueries.retrieveBackUpDate(user.email!);
      if (date == '') {
        showToast("you don't have a backup");
        showLoading(context, false);
        return;
      }
      showLoading(context, false);
      // ignore: use_build_context_synchronously
      showAlert(
          context,
          Text(
            "you sure to download days in backup?",
          ), () async {
        showLoading(context, true);
        showLoading(context, true);
        await FireBaseQueries.downloadData(user);
        UserClass newUser = await SqlDataBase.user(user.email!);
        showLoading(context, false);
        showLoading(context, false);
        goTo(context, DaysScreen(user: newUser));
        showToast("Done!");
      });
    }),
    DrawerBtn(Icons.filter_list_outlined, "Filter Days", () {
      goTo(context, FilteredDaysScreen(days: user.days!), add: true);
    }),

    DrawerBtn(Icons.color_lens, "Themes", () {
      pickColor(context);
    }),
    DrawerBtn(Icons.font_download_sharp, "Fonts", () {
      pickFont(context);
    }),

    DrawerBtn(Icons.logout, "Logout", () async {
      showAlert(context, const Text("you want to logout?"), () async {
        await removePref("userEmail");
        await FirebaseAuth.instance.signOut();
        goTo(context, const LoginScreen());
      });
    }),
  ];
}

appBars(context, contDayFilter, user) {
  double width = MediaQuery.of(context).size.width;
  return [
    AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: MediaQuery.of(context).size.width,
      actions: [
        Container(
          child: const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              "Your Days",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            contDayFilter.text = "";
            BlocProvider.of<AppThemeCubit>(context).changeAppDays(user.days!);
            BlocProvider.of<AppThemeCubit>(context).switchBars();
          },
          child: const Icon(Icons.search, color: Colors.white, size: 30),
        ),
        Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.drag_handle_outlined,
                color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          );
        }),
      ],
    ),
    AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        Builder(builder: (context) {
          return IconButton(
              onPressed: () {
                contDayFilter.text = "";
                BlocProvider.of<AppThemeCubit>(context).switchBars();
              },
              icon: const Icon(
                Icons.arrow_back_outlined,
                color: Colors.white,
              ));
        }),
        SizedBox(
          height: 70,
          width: width - 50,
          child: TextFormField(
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search Day By Name Or Date',
              hintStyle: const TextStyle(color: Colors.white),
              suffixIcon: IconButton(
                splashRadius: 4,
                onPressed: () {
                  BlocProvider.of<AppThemeCubit>(context)
                      .changeAppDays(user.days!);
                  contDayFilter.clear();
                },
                icon: const Icon(
                  Icons.clear,
                  size: 25,
                  color: Colors.white,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            textAlignVertical: TextAlignVertical.bottom,
            controller: contDayFilter,
            onChanged: (value) {
              List<Day> days = user!.days!
                  .where((element) =>
                      element.name!
                          .toLowerCase()!
                          .startsWith(contDayFilter.text.toLowerCase()) ||
                      element.date == contDayFilter.text)
                  .toList();
              BlocProvider.of<AppThemeCubit>(context).changeAppDays(days!);
            },
          ),
        ),
      ],
    ),
  ];
}

isAfter(String data1, String date2) {
  return DateTime.parse(data1).isAfter(DateTime.parse(date2));
}

isDayExist(List days, date) {
  for (int i = 0; i < days.length; i++) {
    if (days[i].date == date) return true;
    print(days[i].date);
    print(date);
  }
  return false;
}

firebaseErrors(String error) {
  String customError = 'something Went wrong!' ;
  if (  error.contains("There is no user record corresponding to this")) {
    customError = "No User found. SingUp First!";
  }
  else if (error.contains("The password is invalid or the user does not have a password")) {
    customError = "Wrong Password!";
  }
  else if (error.contains('The email address is already in use by another account')) {
    customError =  "You're already registered. Please Login Instead!";
  }
  else if (error.contains("We have blocked all requests from this device due to unusual activity")){
    customError = "too many request. Try again later!";
  }
  print(error);
  return customError;
}

initTheme() async {
  mainColor = await getPref("color") == null ? Colors.blue : Color(int.parse(await getPref("color")));
  mainWallpaper = setHomeWallpaper(mainColor.value);
  if (await getPref('mainFont') != null) {
  mainFont = PickerFont(fontFamily: await getPref('mainFont'));
  }
}

selectScreen() async {
  late Widget home;
  if (await getPref('firstTime') == null) {
  home = const SplashScreen(screenToNevigate: LoginScreen());
  } else if (await getPref("userEmail") == null) {
  home = const LoginScreen();
  } else {
  UserClass user = await SqlDataBase.user(await getPref("userEmail"));
  home = DaysScreen(user: user);
  }
  return home;
}

reminderNotification() async {
  String notification = await getPref('notification') ?? DateTime.now().toString();
  if (!DateTime.parse(notification).isAfter(DateTime.now())) {
    for (int i = 1; i <= 3; i++) {
      await NotificationService.scheduleNotification(
          title: "How was your Day!",
          body: "Write Down Your Day!",
          eventTime: {'days': i});
    }
    await setPref('notification', DateTime.now().add(const Duration(days: 3)).toString());
}


  }
  String getDayName(DateTime date) {
    // Create a list of day names
    List<String> dayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return dayNames[date.weekday - 1]; // weekday returns 1 for Monday, 7 for Sunday
}

String getMonthName(DateTime date) {
  // List of month names
  List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  // Return the month name based on the month number
  return monthNames[date.month - 1]; // month returns 1 for January, 12 for December
}

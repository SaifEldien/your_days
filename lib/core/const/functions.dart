// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';


import '../../fearutes/data/logic/bloC/app_theme_bloc/app_theme_cubit.dart';
import '../../fearutes/data/logic/bloC/days_bloc/days_cubit.dart';
import '../../fearutes/data/logic/bloC/days_bloc/days_states.dart';
import '../../fearutes/data/logic/bloC/user_bloc/user_cubit.dart';
import '../../fearutes/data/models/day.dart';
import '../../fearutes/data/models/user.dart';
import '../../fearutes/ui/screens/filtered_days_screen.dart';
import '../Server/firebase_quiries.dart';
import '../components/custom_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../components/notification/notification_services.dart';
import 'vars.dart';

Future setPref(String key, var value) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString(key, value.toString());
}

Future<dynamic>? getPref(String key) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.get(key);
}

Future<dynamic> removePref(String key) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.remove(key);
}

void goTo(BuildContext context, Widget page, {bool add = false}) async {
  if (add) {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (BuildContext context) => page),
    );
  } else {
    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(builder: (BuildContext context) => page),
      (route) => false, //if you want to disable back feature set to false
    );
  }
}

void showToast(String message, {bool long = false, bool isError = false}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: long ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 2,
    backgroundColor: isError ? Colors.red : Colors.black,
    textColor: Colors.white,
    fontSize: 14,
  );
}

Future<void> showAlert(
  BuildContext context,
  String message,
  VoidCallback functionToExecute,
) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => const SizedBox(),
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: anim1.value,
        child: Opacity(
          opacity: anim1.value,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 15,
                    sigmaY: 15,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .2),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 20),

                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // الأزرار المخصصة
                          Row(
                            children: [
                              Expanded(
                                child: _buildDialogButton(
                                  label: "Cancel",
                                  color: Colors.white10,
                                  onTap: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildDialogButton(
                                  label: "Confirm",
                                  color: Colors.redAccent.withValues(alpha: .7),
                                  onTap: () {
                                    functionToExecute();
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Widget مساعد للأزرار عشان الكود يبقى نظيف
Widget _buildDialogButton({
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

void showLoading(BuildContext context, bool show) {
  show == true
      ? showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return PopScope(
              canPop: false,
              child: Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: const CircularProgressIndicator(),
                ),
              ),
            );
          },
        )
      : Navigator.of(context, rootNavigator: true).pop('dialog');
}

String formatDate(DateTime date) {
  return date.toString().substring(0, 10);
}

Future<String?> pickImage({required BuildContext context}) async {
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
              },
            ),
            TextButton(
              child: const Icon(Icons.wallpaper, color: Colors.white, size: 70),
              onPressed: () async {
                pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 90,
                  maxHeight: 1000,
                );
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ),
          ],
        ),
      );
    },
  );
  if (pickedFile == null) return null;
  return base64Encode(File(pickedFile!.path).readAsBytesSync());
}

bool isValidEmail(String email) {
  return RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  ).hasMatch(email);
}

Future<void> pickColor(BuildContext context) async {
  Color col = BlocProvider.of<AppThemeCubit>(context).color;
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // title: const Text('Pick a color!',),
      content: SingleChildScrollView(
        child: BlockPicker(
          onColorChanged: (Color value) async {
            await BlocProvider.of<AppThemeCubit>(
              context,
            ).changeColor(value.toARGB32());
          },
          pickerColor: col,
        ),
      ),
    ),
  );
}

String getNameFromEmail(String email) {
  if (!email.contains('@')) return "User";
  String namePart = email.split('@')[0];
  namePart = namePart.replaceAll(RegExp(r'\d'), '');
  namePart = namePart.replaceAll(RegExp(r'[._-]'), ' ');
  return namePart
      .split(' ')
      .where((s) => s.isNotEmpty)
      .map((word) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ')
      .trim();
}

Future<void> pickFont(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[200],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
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
              await BlocProvider.of<AppThemeCubit>(
                context,
              ).changeFont(font.fontFamily);
              debugPrint(font.fontFamily);
              //_selectedFont = font;
              debugPrint(
                "${font.fontFamily} with font weight ${font.fontWeight} and font style ${font.fontStyle}.}",
              );
            },
          ),
        ),
      ),
    ),
  );
}

double numberOfOccurence(List<Day> days, int id) {
  double number = 0;
  for (int i = 0; i < days.length; i++) {
    days[i].mood!.id == id ? number++ : null;
  }
  return number;
}

Future<bool> checkConnection({bool toast = true}) async {
  try {
    await InternetAddress.lookup(
      'www.google.com',
    ).timeout(Duration(milliseconds: 750));
  } catch (e) {
    if (toast == true) showToast("No internet access!");
    return false;
  }
  return true;
}

String setHomeWallpaper(int value) {
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
  for (int i = 0; i < conts.length; i++) {
    if (conts[i].text != '') num++;
  }
  return num;
}

List<DrawerBtn> drawerButtons(BuildContext context, UserClass user) {
  return [
    DrawerBtn(Icons.cloud_upload_sharp, "Upload a BackUp", () async {
      if (!await checkConnection()) return;

      showLoading(context, true);
      String date = await FireBaseQueries.retrieveBackUpDate(user.email!);
      if (date != '') {
        date = "you sure to upload a backup \n${date.substring(0, 16)} ?";
      } else if (date == '') {
        date = "uploaded backup you sure?";
      }
      showLoading(context, false);
      showAlert(context, date, () async {
        showLoading(context, true);
        showLoading(context, true);
        await FireBaseQueries.uploadData(user);
        await context.read<DaysCubit>().fetchDays();
        showLoading(context, false);
        showLoading(context, false);
        showToast("Done!");
      });
    }),
    DrawerBtn(Icons.cloud_download_sharp, "Download Backup", () async {
      if (!await checkConnection()) return;
      showLoading(context, true);
      String date = await FireBaseQueries.retrieveBackUpDate(user.email!);
      showLoading(context, false);

      // ignore: use_build_context_synchronously
      showAlert(
        context,
        "you sure to download days in backup?\n${date.substring(0, 16)}",
        () async {
          showLoading(context, true);
          showLoading(context, true);
          await FireBaseQueries.downloadData(user);
          await context.read<DaysCubit>().fetchDays();
          showLoading(context, false);
          showLoading(context, false);
          showToast("Done!");
        },
      );
    }),
    DrawerBtn(Icons.filter_list_outlined, "Filter Days", () {
      goTo(context, FilteredDaysScreen(days: user.days), add: true);
    }),
    DrawerBtn(Icons.color_lens, "Themes", () {
      pickColor(context);
    }),
    DrawerBtn(Icons.font_download_sharp, "Fonts", () {
      pickFont(context);
    }),
    DrawerBtn(Icons.format_color_fill, "Fill Empty Days (normal)", () {
      if (user.days.isEmpty) {
        showToast("you have no days!");
        return;
      }
      showAlert(context, "fill your empty days with normal days?", () async {
        showLoading(context, true);
        showLoading(context, true);
        await context.read<DaysCubit>().fillMissingDays();
        showLoading(context, false);
        showLoading(context, false);
        showToast("Done!");
      });
    }),

    DrawerBtn(Icons.logout, "Logout", () async {
      showAlert(context, "you want to logout?", () async {
        await removePref("userEmail");
        context.read<UserCubit>().checkAuthStatus();
      });
    }),
  ];
}

PreferredSizeWidget buildDynamicAppBar({
  required BuildContext context,
  required TextEditingController searchController,
  required UserClass user,
  required bool isSearching,
}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1.0),
      child: Divider(color: Colors.white.withValues(alpha: .1), thickness: 0.5),
    ),
    title: AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isSearching
          ? _buildSearchField(context, searchController, user)
          : _buildDefaultTitle(context, searchController, user),
    ),
    automaticallyImplyLeading: false,
    actions: isSearching ? [] : [_buildEndDrawerButton(context)],
  );
}

Widget _buildDefaultTitle(
  BuildContext context,
  TextEditingController controller,
  dynamic user,
) {
  return Row(
    key: const ValueKey("default_bar"),
    children: [
      const Text(
        "Your Days",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const Spacer(),
      IconButton(
        icon: const Icon(Icons.search, size: 28, color: Colors.white),
        onPressed: () {
          controller.clear();
          BlocProvider.of<AppThemeCubit>(context).switchBars();
          BlocProvider.of<AppThemeCubit>(context).changeAppDays((context.read<DaysCubit>().state as DaysLoaded).days);
        },
      ),
    ],
  );
}

Widget _buildSearchField(
  BuildContext context,
  TextEditingController controller,
  dynamic user,
) {
  return Row(
    key: const ValueKey("search_bar"),
    children: [
      IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: Colors.white,
        ),
        onPressed: () {
          controller.clear();
          BlocProvider.of<AppThemeCubit>(context).changeAppDays(user.days!);
          BlocProvider.of<AppThemeCubit>(context).switchBars();
        },
      ),
      Expanded(
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            cursorColor: Colors.white,
            onChanged: (value) => _onSearchChanged(context, value, user),
            decoration: InputDecoration(
              hintText: 'Search days...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: .5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        controller.clear();
                        BlocProvider.of<AppThemeCubit>(
                          context,
                        ).changeAppDays(user.days!);
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    ],
  );
}

// 3. منطق البحث المفصول (Separation of Concerns)
void _onSearchChanged(BuildContext context, String query, dynamic user) {
  final filtered = user.days!.where((day) {
    final name = day.name?.toLowerCase() ?? "";
    final date = day.date ?? "";
    final search = query.toLowerCase();
    return name.contains(search) || date.contains(search);
  }).toList();

  BlocProvider.of<AppThemeCubit>(context).changeAppDays(filtered);
}

Widget _buildEndDrawerButton(BuildContext context) {
  return Builder(
    builder: (ctx) => IconButton(
      icon: const Icon(
        Icons.drag_handle_rounded,
        color: Colors.white,
        size: 30,
      ),
      onPressed: () => Scaffold.of(ctx).openEndDrawer(),
    ),
  );
}

bool isAfter(String data1, String date2) {
  return DateTime.parse(data1).isAfter(DateTime.parse(date2));
}

bool isDayExist(List days, String date) {
  return days.any((day) => day.date == date);
}

String firebaseErrors(String error) {
  String customError = 'something Went wrong!';
  if (error.contains("There is no user record corresponding to this")) {
    customError = "No User found. SingUp First!";
  } else if (error.contains(
    "The password is invalid or the user does not have a password",
  )) {
    customError = "Wrong Password!";
  } else if (error.contains(
    'The email address is already in use by another account',
  )) {
    customError = "You're already registered. Please Login Instead!";
  } else if (error.contains(
    "We have blocked all requests from this device due to unusual activity",
  )) {
    customError = "too many request. Try again later!";
  }
  debugPrint(error);
  return customError;
}

Future<void> initTheme() async {
  mainColor = await getPref("color") == null
      ? Colors.blue
      : Color(int.parse(await getPref("color")));
  mainWallpaper = setHomeWallpaper(mainColor.toARGB32());
  if (await getPref('mainFont') != null) {
    mainFont = PickerFont(fontFamily: await getPref('mainFont'));
  }
}

Future<void> reminderNotification() async {
  String notification =
      await getPref('notification') ?? DateTime.now().toString();
  if (!DateTime.parse(notification).isAfter(DateTime.now())) {
    for (int i = 1; i <= 30; i++) {
      NotificationService.scheduleNotification(
        title: "How was your Day!",
        body: "Write Down Your Day!",
        eventTime: {'days': i},
      );
    }
    await setPref(
      'notification',
      DateTime.now().add(const Duration(days: 3)).toString(),
    );
  }
}

String getDayName(DateTime date) {
  List<String> dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  return dayNames[date.weekday -
      1]; // weekday returns 1 for Monday, 7 for Sunday
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
    'December',
  ];

  // Return the month name based on the month number
  return monthNames[date.month -
      1]; // month returns 1 for January, 12 for December
}

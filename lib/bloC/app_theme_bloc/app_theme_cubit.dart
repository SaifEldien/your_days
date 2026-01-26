
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import '../../const/functions.dart';
import '../../const/vars.dart';
import '../../models/day.dart';
import 'app_theme_states.dart';

class AppThemeCubit extends Cubit<AppThemeStates> {
  AppThemeCubit(super.initialState);
  Color color = mainColor ;
  int appBarIndex = 0;
  List<Day> days = [];
  PickerFont font = mainFont;
  String wallpaper = mainWallpaper;
  Future<void> changeColor (int value) async {
    color = Color(value);
    wallpaper = setHomeWallpaper(value);
   // print(color.value);
    await setPref("color", value.toString());

    emit(ChangeColorState());
  }

  Future<void> changeFont(String newFont) async {
   // color = Color(value);
   // wallpaper = setHomeWallpaper(value);
   // print(color.value);
    font = PickerFont(fontFamily: newFont);
    await setPref("mainFont", newFont);
    emit(ChangeColorState());
  }


  void switchBars ()  {
    appBarIndex==0 ? appBarIndex = 1  : appBarIndex = 0;
    emit(ChangeAppBarState());

  }

  void changeAppDays (List<Day> newDays) {
    days = newDays ;
    emit(ChangeAppDays());
  }






}
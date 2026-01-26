import 'package:flutter/material.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';

import '../models/mood.dart';

 Color mainColor = Color(4288423856);
 String mainWallpaper = 'assets/images/home wallpapers/blue1.jpg';
 PickerFont mainFont = PickerFont(fontFamily: 'Akaya Kanadaka') ;
 double opacity = 0.5;

List<Mood> moods = [
  Mood(0, Colors.yellowAccent, "Happy", "assets/emojis/Happy.png"),
  Mood(1, Color.fromRGBO(238,238,175,1), "Normal",  "assets/emojis/Normal.png"),
  Mood(2, Colors.pink, "Loved",  "assets/emojis/Loved.png"),
  Mood(3, Color.fromRGBO(175, 238, 238, 1), "Sad",  "assets/emojis/Sad.png"),
  Mood(4, Colors.blue, "Motivated",  "assets/emojis/Motivated.png"),
  Mood(5, Colors.red, "Angry",  "assets/emojis/angry.png"),
  Mood(6, Colors.greenAccent, "Tired",  "assets/emojis/tired.png"),
  Mood(7, Colors.cyan, "Confident",  "assets/emojis/Confident.png"),
  Mood(8, Colors.orange, "Clumsy",  "assets/emojis/clumsy.png"),
  Mood(9, Colors.blueGrey, "Hesitated",  "assets/emojis/Hesitated.png"),
  Mood(10, Colors.green, "Sick",  "assets/emojis/sick.png"),
  Mood(11, Colors.grey, "Anxious",  "assets/emojis/Anxious.png"),
];

Map<int, Color> color =
{
  50:const Color.fromRGBO(136,14,79, .1),
  100:const Color.fromRGBO(136,14,79, .2),
  200:const Color.fromRGBO(136,14,79, .3),
  300:const Color.fromRGBO(136,14,79, .4),
  400:const Color.fromRGBO(136,14,79, .5),
  500:const Color.fromRGBO(136,14,79, .6),
  600:const Color.fromRGBO(136,14,79, .7),
  700:const Color.fromRGBO(136,14,79, .8),
  800:const Color.fromRGBO(136,14,79, .9),
  900:const Color.fromRGBO(136,14,79, 1),
};



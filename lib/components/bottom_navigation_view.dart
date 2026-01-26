import 'package:flutter/material.dart';

import '../const/vars.dart';

class BottomNavigationView extends StatelessWidget {
  final List<BottomNavItem> items;
  final Color color;
  const BottomNavigationView({super.key, required this.items, required this.color});
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      notchMargin: 15,
      height: 120,
      elevation: 50,
      shape: const CircularNotchedRectangle(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(80)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            color: color.withOpacity(opacity),
            height: 80,
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: items),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final String text;
  final Function press;
  final bool isActive;
  final IconData icon;
  const BottomNavItem(
      {super.key,
        required this.text,
        required this.press,
        required this.isActive,
        required this.icon});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => press(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.black54,
              size: 35,
            ),
            Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
              ),
            )
          ],
        ),
      ),
    );
  }
}

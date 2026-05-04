import 'dart:ui';
import 'package:flutter/material.dart';

class BottomNavigationView extends StatelessWidget {
  final List<BottomNavItem> items;
  final Color color;

  const BottomNavigationView({
    super.key,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .1),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: items,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final bool isActive;
  final IconData icon;

  const BottomNavItem({
    super.key,
    required this.text,
    required this.press,
    required this.isActive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut, // حركة مرنة احترافية
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // خلفية خفيفة للأيقونة النشطة بأسلوب الـ Pill
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة بتكبر وتصغر (Pulse Effect)
            AnimatedScale(
              scale: isActive ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: .4),
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: .4),
              ),
              child: Text(text),
            ),
          ],
        ),
      ),
    );
  }
}

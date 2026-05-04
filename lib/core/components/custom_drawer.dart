import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_days/core/components/smart_image.dart';

import '../../fearutes/data/logic/bloC/app_theme_bloc/app_theme_cubit.dart';
import '../../fearutes/data/models/user.dart';


class CustomDrawer extends StatelessWidget {
  final UserClass user;
  final List<DrawerBtn> buttons;

  const CustomDrawer({super.key, required this.user, required this.buttons});

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<AppThemeCubit>().color;
    final isDark = themeColor == const Color(0xff000000);
    final accentColor = isDark ? Colors.white : themeColor;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.08,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: .8),
              Colors.black.withValues(alpha: .6),
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(80),
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: .08),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(80),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Column(
              children: [
                // --- Header Section ---
                _buildHeader(context, themeColor, accentColor),

                // --- Buttons Section ---
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: buttons.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (context, index) => buttons[index],
                  ),
                ),

                // --- Footer Section ---
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color themeColor,
    Color accentColor,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 30,
      ),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: .15),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: .05)),
        ),
      ),
      child: Column(
        children: [
          // User Avatar with Outer Glow
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: .2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: accentColor.withValues(alpha: .5),
              child: SmartImageWidget(imagePath: user.image ?? "", size: 100),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            user.name ?? "Anonymous",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            user.email ?? "", // لو ضفت الإيميل بيدي شكل احترافي أكتر
            style: TextStyle(
              color: Colors.white.withValues(alpha: .5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Divider(
            color: Colors.white.withValues(alpha: .05),
            indent: 50,
            endIndent: 50,
          ),
          const SizedBox(height: 10),
          const Text(
            'MY DAYS APP',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'v 3.21.0',
            style: TextStyle(color: Colors.white10, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class DrawerBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback function;

  const DrawerBtn(this.icon, this.text, this.function, {super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<AppThemeCubit>().color;
    final isDark = themeColor == const Color(0xff000000);
    final accentColor = isDark ? Colors.white : themeColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          function();
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: accentColor.withValues(alpha: .1),
        highlightColor: accentColor.withValues(alpha: .05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7.2, horizontal: 16),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: accentColor),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: .9),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              // Arrow Icon (Senior UI Touch)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: .2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

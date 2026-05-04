import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

import '../../../core/const/functions.dart';
import '../../data/logic/bloC/user_bloc/user_cubit.dart';

class SplashScreen extends StatefulWidget {
  final Widget screenToNavigate;

  const SplashScreen({super.key, required this.screenToNavigate});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int page = 0;
  late LiquidController liquidController;
  @override
  void initState() {
    super.initState();
    liquidController = LiquidController();
  }

  void _onFinish() async {
    await setPref('firstTime', false);
    context.read<UserCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(
        image: 'assets/on_boarding_images/1.jpg',
        title: "Hello There!",
        subtitle: "Let's Explore Your Diary",
        textColor: Colors.white,
      ),
      _buildPage(
        image: 'assets/on_boarding_images/3.jpg',
        title: "Write",
        subtitle: "Your day's Highlights",
        textColor: Colors.black,
      ),
      _buildPage(
        image: 'assets/on_boarding_images/2.jpg',
        title: "Choose Themes",
        subtitle: "And much more. Enjoy your journey!",
        textColor: Colors.white,
      ),
    ];
    return Scaffold(
      body: Stack(
        children: <Widget>[
          LiquidSwipe(
            pages: pages,
            enableLoop: false,
            liquidController: liquidController,
            enableSideReveal: false,
            onPageChangeCallback: (index) {
              setState(() {
                page = index;
              });
            },
            waveType: WaveType.liquidReveal,
            slideIconWidget: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white70,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _onFinish,
                  child: Text(
                    page != pages.length - 1 ? "SKIP" : "",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    pages.length,
                    (index) => _buildDot(index),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (page < pages.length - 1) {
                      liquidController.animateToPage(
                        page: page + 1,
                        duration: 600,
                      );
                    } else {
                      _onFinish();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: .2),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    page == pages.length - 1 ? "GET STARTED" : "NEXT",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String image,
    required String title,
    required String subtitle,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        color: Colors.black.withValues(
          alpha: .2,
        ), // طبقة ظل خفيفة لسهولة القراءة
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: textColor.withValues(alpha: .8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت النقطة النشطة
  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(0.0, 1.0 - ((page) - index).abs()),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return SizedBox(
      width: 25.0,
      child: Center(
        child: Material(
          color: Colors.white.withValues(alpha: page == index ? 1 : 0.5),
          type: MaterialType.circle,
          child: SizedBox(width: 8.0 * zoom, height: 8.0 * zoom),
        ),
      ),
    );
  }
}

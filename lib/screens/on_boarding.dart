import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:my_days/const/vars.dart';

import '../const/functions.dart';

class SplashScreen extends StatefulWidget {
  final Widget screenToNevigate;
  static const style = TextStyle(
    color: Colors.white,
    fontSize: 30,
    fontWeight: FontWeight.w600,
  );

  const SplashScreen({Key? key, required this.screenToNevigate}) : super(key: key);

  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  int page = 0;
  late LiquidController liquidController;
  late UpdateType updateType;
  late List <Widget> newPages;
  @override
  void initState() {
    liquidController = LiquidController();
    super.initState();
    newPages = [...pages];
    newPages.add(widget.screenToNevigate);
  }

  final pages = [
    Container(
      width: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
            image:  Image.asset(
              'assets/on_boarding_images/1.jpg',
            ).image,
            fit: BoxFit.fill,

          )
      ),
      //color: Colors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[

          Column(
            children:  [
              Text(
                "Hello There!",
                style: TextStyle(fontSize:40,color: Colors.white),
              ),
              Text(
                "Let's ",
                style: TextStyle(fontSize:40,color: Colors.white),
              ),
              Text(
                "Explore Your Diary",
                style: TextStyle(fontSize:40,color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    ),
    Container(
      width: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
            image:  Image.asset(
              'assets/on_boarding_images/3.jpg',
            ).image,
            fit: BoxFit.fill,

          )
      ),
      //color: Colors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            children:  [
              Text(
                "Write ",
                style: TextStyle(fontSize:40,color: Colors.black),

              ),
              Text(
                "Your day's ",
                style: TextStyle(fontSize:40,color: Colors.black),
              ),
              Text(
                "Highlights",
                style: TextStyle(fontSize:40,color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    ),
    Container(
      width: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
            image:  Image.asset(
              'assets/on_boarding_images/2.jpg',
            ).image,
            fit: BoxFit.fill,

          )
      ),
      //color: Colors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[

          Column(
            children:  [
              Text(
                "to choose from many ",
                style: TextStyle(fontSize:40,color: Colors.white),

              ),
              Text(
                "themes And much more.",
                style: TextStyle(fontSize:40,color: Colors.white),

              ),
              Text(
                "Enjoy your journey!",
                style: TextStyle(fontSize:40,color: Colors.white),

              ),

            ],
          ),
        ],
      ),
    ),

  ];

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((page) - index).abs(),
      ),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return SizedBox(
      width: 25.0,
      child: Center(
        child: Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: SizedBox(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              LiquidSwipe(
                pages: newPages,
                slideIconWidget: const Icon(Icons.arrow_back_ios,color: Colors.grey,),
                onPageChangeCallback: pageChangeCallback,
                waveType: WaveType.liquidReveal,
                liquidController: liquidController,
                enableSideReveal: true,
                ignoreUserGestureWhileAnimating: true,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    const Expanded(child: SizedBox()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(pages.length, _buildDot),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: TextButton(
                    onPressed: () {
                      liquidController.animateToPage(
                          page: pages.length - 1, duration: 700);
                    },
                    child: const Text("Skip to End",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: TextButton(
                    onPressed: () {
                      liquidController.jumpToPage(
                          page: liquidController.currentPage + 1 > pages.length - 1 ? goTo(context, widget.screenToNevigate) : liquidController.currentPage + 1);
                    },
                    child: const Text("Next",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              )
            ],
          ),
        ),
      );
  }

  pageChangeCallback(int lpage) {
   if (lpage==pages.length) { goTo(context, widget.screenToNevigate); return;}


    setState(() {
      page = lpage;
    });
  }
}
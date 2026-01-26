
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads/ads_services.dart';
import 'notification/notification_services.dart';

import 'bloC/app_theme_bloc/app_theme_cubit.dart';
import 'bloC/app_theme_bloc/app_theme_states.dart';
import 'const/functions.dart';
import 'const/vars.dart';
import 'database/database_intialzing.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await SqlDataBase.initializeDb();
  await NotificationService.init();
  await Firebase.initializeApp();
  await initTheme();

/*
   MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
      testDeviceIds: [
        'B5FD61B13893EF2EDDCAF0851CE84C79',
        "D807D492786B29C63E3B41922533F618"
      ]));
   */

  await _createInterstitialAd();
  runApp(MyApp(home: await selectScreen()));
  reminderNotification();
}

_createInterstitialAd() async {
  await InterstitialAd.load(
      request: const AdRequest(),
      adUnitId: AdMobService.interstitialAdUnitId.toString(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad)=> _interstitialAd = ad,
          onAdFailedToLoad:(LoadAdError error)=> _interstitialAd = null)
  );

}

InterstitialAd? _interstitialAd;



showInterstitialAd() async {
  if (_interstitialAd!=null) {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad,error) {
          ad.dispose();
          _createInterstitialAd();
        }
    );
    _interstitialAd?.show();
    _interstitialAd = null;
  }
}


class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => AppThemeCubit(ChangeColorState()),
        child: BlocBuilder<AppThemeCubit, AppThemeStates>(
            builder: (context, state) {
          Color col = BlocProvider.of<AppThemeCubit>(context).color;
          var font = BlocProvider.of<AppThemeCubit>(context).font;
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'My Days',
              theme: ThemeData(
                primarySwatch: MaterialColor(
                  col.value,
                  color,
                ),
                textTheme: Theme.of(context)
                    .textTheme
                    .apply(fontFamily: font.toTextStyle().fontFamily),

                floatingActionButtonTheme:
                    FloatingActionButtonThemeData(backgroundColor: col),
                canvasColor: Colors.transparent,
                //MaterialColor colorCustom = MaterialColor(0xFF880E4F, color);
              ),
              home: home);
        }));
  }
}

// build apk --split-per-abi  --no-shrink
//C:\flutter_sdk\flutter\bin\flutter.bat build apk --split-per-abi  --no-shrink

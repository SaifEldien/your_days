import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_days/core/components/spinning_image.dart';
import 'package:my_days/core/database/database_intialzing.dart';
import 'package:my_days/core/components/notification/notification_services.dart';

import 'core/const/functions.dart';
import 'core/const/vars.dart';
import 'fearutes/data/logic/bloC/app_theme_bloc/app_theme_cubit.dart';
import 'fearutes/data/logic/bloC/app_theme_bloc/app_theme_states.dart';
import 'fearutes/data/logic/bloC/days_bloc/days_cubit.dart';
import 'fearutes/data/logic/bloC/user_bloc/user_cubit.dart';
import 'fearutes/data/logic/bloC/user_bloc/user_states.dart';
import 'fearutes/ui/screens/auth_screens/auth_screen.dart';
import 'fearutes/ui/screens/auth_screens/login_screen.dart';
import 'fearutes/ui/screens/days_screen.dart';
import 'fearutes/ui/screens/on_boarding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    SqlDataBase.initializeDb(),
    NotificationService.init(),
    Firebase.initializeApp(),
    initTheme(),
  ]);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>(
          create: (context) => UserCubit()..checkAuthStatus(),
        ),
        BlocProvider<DaysCubit>(
          create: (context) => DaysCubit(userCubit: context.read<UserCubit>()),
        ),
        BlocProvider<AppThemeCubit>(
          create: (context) => AppThemeCubit(ChangeColorState()),
        ),
      ],
      child: const MyApp(),
    ),
  );

  reminderNotification();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeStates>(
      builder: (context, state) {
        final themeCubit = context.read<AppThemeCubit>();
        Color col = themeCubit.color;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Days',
          theme: ThemeData(
            primarySwatch: MaterialColor(col.toARGB32(), color),
            fontFamily: themeCubit.font.toTextStyle().fontFamily,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: col,
            ),
            canvasColor: Colors.transparent,
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserSuccess) {
          context.read<DaysCubit>().fetchDays();
        }
      },
      builder: (context, state) {
        if (state is UserInitial || state is UserLoading) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(mainWallpaper),
                fit: BoxFit.cover,
              ),
            ),
            child: const Scaffold(
              backgroundColor: Colors.black45,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinningImage(
                      imagePath: 'assets/images/splash.png',
                      size: 120,
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Hi...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is UserFirstTime) {
          return SplashScreen(screenToNavigate: const LoginScreen());
        } else if (state is UserSuccess) {
          return DaysScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}

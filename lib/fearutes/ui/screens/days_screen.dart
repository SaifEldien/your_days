import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_days/core/components/spinning_image.dart';

import '../../../core/components/bottom_navigation_view.dart';
import '../../../core/components/custom_drawer.dart';
import '../../../core/components/day_form.dart';
import '../../../core/components/fab.dart';
import '../../../core/components/widgets.dart';
import '../../../core/const/functions.dart';
import '../../../core/const/vars.dart';
import '../../data/logic/bloC/app_theme_bloc/app_theme_cubit.dart';
import '../../data/logic/bloC/app_theme_bloc/app_theme_states.dart';
import '../../data/logic/bloC/days_bloc/days_cubit.dart';
import '../../data/logic/bloC/days_bloc/days_states.dart';
import '../../data/logic/bloC/user_bloc/user_cubit.dart';
import '../../data/logic/bloC/user_bloc/user_states.dart';
import '../../data/models/day.dart';
import '../../data/models/user.dart';
import 'chart_screen.dart';
import 'edit_user_info_screen.dart';

class DaysScreen extends StatefulWidget {
  const DaysScreen({super.key});
  @override
  State<DaysScreen> createState() => _DaysScreenState();
}

class _DaysScreenState extends State<DaysScreen> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController contDayFilter = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (context.read<UserCubit>().state is! UserSuccess) {
      return Scaffold(
        backgroundColor: Colors.blueGrey.shade100,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    UserClass user = (context.read<UserCubit>().state as UserSuccess).user;
    return BlocBuilder<DaysCubit, DaysState>(
      builder: (context, daysState) {
        return BlocBuilder<AppThemeCubit, AppThemeStates>(
          builder: (context, state) {
            int appBarIndex = BlocProvider.of<AppThemeCubit>(
              context,
            ).appBarIndex;
            if (daysState is DaysLoading) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(mainWallpaper),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Scaffold(
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
                          "Loading your Days...",
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
            }
            List<Day> days =
                (context.read<DaysCubit>().state as DaysLoaded).days;
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    BlocProvider.of<AppThemeCubit>(context).wallpaper,
                  ),
                ),
              ),
              child: Scaffold(
                extendBody: true,
                backgroundColor: Colors.transparent,
                appBar: buildDynamicAppBar(
                  context: context,
                  searchController: contDayFilter,
                  user: user,
                  isSearching: appBarIndex == 1,
                ),
                endDrawerEnableOpenDragGesture: false,
                endDrawer: CustomDrawer(
                  user: user,
                  buttons: drawerButtons(context, user),
                ),
                body: BlocProvider.of<AppThemeCubit>(context).appBarIndex == 0
                    ? DaysList(days: days)
                    : DaysList(
                        days: BlocProvider.of<AppThemeCubit>(context).days,
                      ),
                floatingActionButton: CustomFAB(
                  text: "Add a Day",
                  icon: Icons.edit,
                  color: BlocProvider.of<AppThemeCubit>(context).color,
                  form: DayFormScreen(user: user),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: BottomNavigationView(
                  items: [
                    BottomNavItem(
                      icon: Icons.stacked_bar_chart_sharp,
                      text: 'OverView',
                      isActive: true,
                      press: () async {
                        if (days.isEmpty) {
                          showToast("you Have No Days Added");
                          return;
                        }
                        goTo(context, ChartScreen(days: days), add: true);
                      },
                    ),
                    BottomNavItem(
                      icon: Icons.person,
                      text: 'Profile',
                      isActive: true,
                      press: () {
                        goTo(context, EditUserScreen(user: user), add: true);
                      },
                    ),
                  ],
                  color: BlocProvider.of<AppThemeCubit>(context).color,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

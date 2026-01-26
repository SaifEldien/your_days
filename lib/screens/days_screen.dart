import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_days/main.dart';


import '../bloC/app_theme_bloc/app_theme_cubit.dart';
import '../bloC/app_theme_bloc/app_theme_states.dart';
import '../components/bottom_navigation_view.dart';
import '../components/custom_drawer.dart';
import '../components/day_form.dart';
import '../components/fab.dart';
import '../components/widgets.dart';
import '../const/functions.dart';
import '../models/user.dart';
import 'chart_screen.dart';
import 'edit_user_info_screen.dart';

class DaysScreen extends StatefulWidget {
  final UserClass user;
  const DaysScreen({super.key, required this.user});
  @override
  State<DaysScreen> createState() => _DaysScreenState();
}

class _DaysScreenState extends State<DaysScreen> {

  @override
  void initState() {
    super.initState();
  }
  final TextEditingController contDayFilter =
      TextEditingController(text: formatDate(DateTime.now()));
  @override
  Widget build(BuildContext context) {
    List<DayCard> cards = List.generate(widget.user.days!.length, (index) => DayCard(day: widget.user.days![index]));
    return BlocBuilder<AppThemeCubit, AppThemeStates>(
      builder: (context, state) {
      int appBarIndex = BlocProvider.of<AppThemeCubit>(context).appBarIndex;
        return Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill, image:AssetImage(BlocProvider.of<AppThemeCubit>(context).wallpaper),
          ),),
          child: Scaffold(
            extendBody: true,
            backgroundColor: Colors.transparent,
            appBar: appBars(context,contDayFilter,widget.user)[appBarIndex],
            endDrawerEnableOpenDragGesture: false,
            endDrawer: CustomDrawer(
              user: widget.user,
              buttons: drawerButtons(context,widget.user),
            ),
            body: BlocProvider.of<AppThemeCubit>(context).appBarIndex == 0
                ? DaysList(days: cards)
                : DaysList(
                    days: List.generate(
                        BlocProvider.of<AppThemeCubit>(context).days.length,
                        (index) => DayCard(
                            day: BlocProvider.of<AppThemeCubit>(context)
                                .days[index]))),
            floatingActionButton: FAB(
              function: showInterstitialAd,
                text: "Add a Day", icon: Icons.edit,  color:  BlocProvider.of<AppThemeCubit>(context).color,
            form: DayForm(user: widget.user,)),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar:  BottomNavigationView(items: [
              BottomNavItem(icon: Icons.stacked_bar_chart_sharp , text: 'OverView', isActive:true, press:() async {
               await showInterstitialAd();
                if (widget.user.days!.isEmpty) {
                  showToast("you Have No Days Added");
                  return;
                }
                goTo(context, ChartScreen(days: widget.user.days!), add: true);
              }),
              BottomNavItem(icon: Icons.person , text: 'Profile', isActive:true, press:(){
                goTo(context, EditUserScreen(user: widget.user), add: true);

              })
            ], color:  BlocProvider.of<AppThemeCubit>(context).color,),
          ),
        );
      },
    );
  }
}


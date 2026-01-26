import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloC/app_theme_bloc/app_theme_cubit.dart';

import '../components/day_form.dart';
import '../const/functions.dart';
import '../const/vars.dart';
import '../database/database_intialzing.dart';
import '../models/day.dart';
import '../models/highlight.dart';
import '../models/user.dart';
import 'days_screen.dart';

class FullDayScreen extends StatelessWidget {
  final Day day;
  FullDayScreen({Key? key, required this.day}) : super(key: key);
  final int index = 0;
  final bool extended = false;
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(BlocProvider.of<AppThemeCubit>(context).wallpaper),
        )),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              day.date!,
              style: const TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  String email = day.userEmail!;
                  showAlert(
                      context,
                      const Text(
                        "You Sure to Delete the Day?",
                        textAlign: TextAlign.center,
                      ), () async {
                    showLoading(context, true);
                    await SqlDataBase.deleteADay(day);
                    UserClass user = await SqlDataBase.user(email);
                    if (BlocProvider.of<AppThemeCubit>(context)
                        .appBarIndex ==
                        1) {
                      BlocProvider.of<AppThemeCubit>(context)
                          .switchBars();
                    }
                    showLoading(context, false);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    goTo(context, DaysScreen(user: user));
                  });
                },
                icon: const Icon(
                  Icons.delete,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 15,)
            ],
            centerTitle: true,
          ),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      day.name!,
                      style: const TextStyle(fontSize: 35, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Text("${day.mood!.title} Day!",
                      style:
                          const TextStyle(fontSize: 18.0, color: Colors.white)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(image: AssetImage(day.mood!.emoji),height: 55,),
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: PageView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: 2,
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 30),
                              child: index == 0
                                  ? GridView.count(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.85,
                                      crossAxisSpacing: 7,
                                      mainAxisSpacing: 4,
                                      children: List.generate(
                                        day.highlights!.length,
                                        (index) => HighLightShow(
                                            highlight: day.highlights![index]),
                                      ))
                                  : day!.details!.trim()!.isNotEmpty
                                      ? Container(
                                          margin: const EdgeInsets.only(top: 7),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: SingleChildScrollView(
                                              child: Text(
                                                day.details!,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                            ),
                                          ))
                                      : const SizedBox(),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Indicator(
                                  length: 2,
                                  index: index,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton:
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom != 0.0 ? 0 : 120,
            child: Column(
                children: [
            Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Edit Day',    style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          SizedBox(
            height: 80,
            width: 80,
            child: FloatingActionButton(
                elevation: 10,
                backgroundColor: BlocProvider.of<AppThemeCubit>(context).color.withOpacity(opacity),
            onPressed: () async {
              UserClass user  = await SqlDataBase.user(day!.userEmail!) ;
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DayForm(user: user, day:day);
                  });
            },
            child: Icon(Icons.edit_note_rounded, size: 35, color: Colors.white),
            // elevation: 5.0,
          ),
        ),
      ],
    ),
    ),
        ));
  }
}

class Indicator extends StatelessWidget {
  final int length;
  final int index;
  const Indicator({Key? key, required this.length, required this.index})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            length,
            (index) => Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: this.index == index
                        ? BlocProvider.of<AppThemeCubit>(context)
                            .color
                            .withOpacity(0.7)
                        : Colors.grey[100],
                  ),
                )),
      ),
    );
  }
}

class HighLightShow extends StatelessWidget {
  final Highlight highlight;
  const HighLightShow({Key? key, required this.highlight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return highlight.image == ''
        ? Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
                color: BlocProvider.of<AppThemeCubit>(context)
                    .color
                    .withOpacity(0.5),
                borderRadius: const BorderRadius.all(Radius.circular(50))),
            child: Center(
                child: SingleChildScrollView(
              child: Text(
                highlight.title!,
                style: const TextStyle(color: Colors.white, fontSize: 17),
              ),
            )))
        : TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              goTo(
                  context,
                  Image(
                    image: Image.memory(showImage(highlight.image!)).image,
                  ),
                  add: true);
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50),
                  ),
                  image: DecorationImage(
                      image: Image.memory(
                        showImage(highlight.image!),
                      ).image,
                      fit: BoxFit.fill)),
              child: Center(
                  child: SingleChildScrollView(
                child: Text(
                  highlight.title!,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              )),
            ),
          );
  }
}


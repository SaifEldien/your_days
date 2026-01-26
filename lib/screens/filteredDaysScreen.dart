import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloC/app_theme_bloc/app_theme_cubit.dart';
import '../components/widgets.dart';
import '../models/day.dart';
import '../const/vars.dart';
import '../models/mood.dart';

class FilteredDaysScreen extends StatefulWidget {
  const FilteredDaysScreen({Key? key, required this.days}) : super(key: key);
  final List<Day> days;
  @override
  State<FilteredDaysScreen> createState() => _FilteredDaysScreenState();
}

class _FilteredDaysScreenState extends State<FilteredDaysScreen> {
  int moodId = 13;
  int date = 1;
  List<DropdownMenuItem<dynamic>> items = dropDownItems;

  @override
  void initState() {
    if (items.length==12) {
      items.add(
        DropdownMenuItem(
          value: Mood(13, Colors.transparent, "All", ""),
          child: Container(child: const Center(child: Text("All",style: TextStyle(color: Colors.white),))),
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Day> filteredDays=widget.days;
    if (moodId!=13) {
       filteredDays = filteredDays.where((element) => element.mood!.id==moodId).toList();
    }
    if (date!=1) {
      filteredDays = filteredDays.where((element) =>
      DateTime.parse(element.date!).month==DateTime.now().month&&
          DateTime.parse(element.date!).year==DateTime.now().year

      ).toList();
    }
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill, image:AssetImage(BlocProvider.of<AppThemeCubit>(context).wallpaper),
          )),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text("Filter Days",style: TextStyle(color: Colors.white),),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: items
                            .where((element) => element.value.id == moodId)
                            .first
                            .value
                            .color,
                        border: Border.all(width: 1, color: Colors.white),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50))),
                    margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton(
                        underline: const SizedBox(),
                        value: items
                            .where((element) => element.value.id == moodId)
                            .first
                            .value,
                        items: items,
                        onChanged: (value) {
                          moodId = value.id;
                          setState(() {});
                        }),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.white),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(50))),
                    margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton(
                      underline: const SizedBox(),
                        value: dropDownItemsDates.where((element) => element.value == date).first.value,
                        items: dropDownItemsDates,
                        onChanged: (value) {
                          date = value;
                          setState(() {});
                        }),
                  )

                ],
              ),
              Expanded(
                  child: DaysList(
                days: List.generate(
                  filteredDays.length,
                  (index) => DayCard(day: filteredDays[index]),
                ),
              )),
            ],
          )),
    );
  }
}

List<DropdownMenuItem> dropDownItems = List.generate(
    moods.length,
    (i) => DropdownMenuItem(
          value: moods[i],
          child: Container(
              color: moods[i].color,
              child:
                  Row(
                    children: [
                      Text("${moods[i].title} "),
                       Image(image: AssetImage(moods[i].emoji),height: 55,),
                    ],
                  )),
        ));
List<DropdownMenuItem> dropDownItemsDates = [
  const DropdownMenuItem(
      value: 0,
      child: Text("This Month",style: TextStyle(color: Colors.white),)
  ),
  const DropdownMenuItem(
      value: 1,
      child: Center(child: Text("All",style: TextStyle(color: Colors.white),))
  ),
];



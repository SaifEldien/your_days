import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pie_chart/pie_chart.dart';
import '../bloC/app_theme_bloc/app_theme_cubit.dart';
import '../components/widgets.dart';
import '../const/functions.dart';

import '../models/day.dart';

class ChartScreen extends StatefulWidget {
  final List<Day> days;
  const ChartScreen({Key? key, required this.days}) : super(key: key);
  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  int date = 1;
   List<Day> days = [];
  final TextEditingController fDate = TextEditingController();
  final TextEditingController lDate = TextEditingController();
  @override
  void initState() {
    days.addAll(widget.days);
    fDate.text = widget.days.last.date!;
    lDate.text = widget.days.first.date!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*if (date != 1) {
      days = days
          .where((element) =>
              DateTime.parse(element.date!).month == DateTime.now().month &&
              DateTime.parse(element.date!).year == DateTime.now().year)
          .toList();
    }*/
    List<Color> colors = [];
    Map<String, double> dataMap = {};
    for (int i = 0; i < days.length; i++) {
      dataMap[days[i].mood!.title] = numberOfOccurence(days, days[i].mood!.id);
      if (!colors.contains(days[i].mood!.color.withOpacity(0.8))) {
        colors.add(days[i].mood!.color.withOpacity(0.8));
      }
    }
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
            "Days Overview",
            style: TextStyle(color: Colors.white),
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
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(50))),
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(8.0),
                child: Row (
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children : [
                    CustomFormField (
                      readOnly: true,
                      icon: Icons.timer,
                      cont: fDate,
                      hintText: 'Start Date',
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2015, 8),
                            lastDate: DateTime.now());
                        fDate.text = formatDate(date!);
                       days =  days.where((element) => DateTime.parse(element.date!).isAfter(DateTime.parse(fDate.text))
                       ||element.date==fDate.text).toList();
                        for (int i = 0; i < days.length; i++) {
                           dataMap[days[i].mood!.title] = numberOfOccurence(days, days[i].mood!.id);
                          if (!colors.contains(days[i].mood!.color.withOpacity(0.8))) {
                            colors.add(days[i].mood!.color.withOpacity(0.8));
                          }
                        }
                       setState(() {});
                      },
                      width: MediaQuery.of(context).size.width*0.4,
                      valid: (){
                        if (DateTime.parse(fDate.text).isAfter(DateTime.parse(lDate.text))) {
                          return "Wrong Dates!";
                        }
                    },
                    ),
                   /* DropdownButton(
                        iconEnabledColor: Colors.white,
                        dropdownColor: Colors.transparent,
                        underline: const SizedBox(),
                        value: dropDownItemsDates.where((element) => element.value == date).first.value,
                        items: dropDownItemsDates,
                        onChanged: (value) {
                          date = value;
                          setState(() {});
                        }),*/
                    CustomFormField (
                      cont: lDate,
                      readOnly: true,
                      icon: Icons.timer_off,
                      hintText: 'End Date',
                      onTap:() async {
                        DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2015, 8),
                            lastDate: DateTime.now());
                        lDate.text = formatDate(date!);
                        days =  days.where((element) => DateTime.parse(element.date!).isBefore(DateTime.parse(lDate.text))||element.date==lDate.text).toList();
                        setState(() {});
                      },
                        width: MediaQuery.of(context).size.width*0.4
                        , valid: (){
                      if (DateTime.parse(fDate.text).isAfter(DateTime.parse(lDate.text))) {
                        return "Wrong Dates!";
                      }
                    },
                    ),

                  ]
                )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 70),
                  padding: const EdgeInsets.all(15.0),
                  child: PieChart(
                    centerText: "Your Days (${days.length})",
                    dataMap: dataMap,
                    chartType: ChartType.ring,
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValuesInPercentage: true,
                    ),
                    legendOptions: const LegendOptions(legendTextStyle: TextStyle(color: Colors.white)),
                    colorList: colors,
                    totalValue: double.parse(
                      days!.length.toString(),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

List<DropdownMenuItem> dropDownItemsDates = [
  const DropdownMenuItem(
      value: 0,
      child: Text(
        "This Month",
        style: TextStyle(color: Colors.white),
      )),
  const DropdownMenuItem(
      value: 1,
      child: Center(
          child: Text(
        "All",
        style: TextStyle(color: Colors.white),
      ))),
];

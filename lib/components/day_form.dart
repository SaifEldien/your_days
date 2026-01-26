import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloC/days_form_bloc/days_form_cubit.dart';
import '../bloC/days_form_bloc/days_form_states.dart';
import '../const/functions.dart';
import '../const/vars.dart';
import '../database/database_intialzing.dart';
import '../models/day.dart';
import '../models/highlight.dart';
import '../models/user.dart';
import '../screens/days_screen.dart';
import '../screens/show_day_screen.dart';
import 'widgets.dart';

class DayForm extends StatelessWidget {
  final UserClass user;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dayDateCont = TextEditingController(text: formatDate(DateTime.now()));
  final TextEditingController _dayNameCont = TextEditingController(text: getDayName(DateTime.now()));
  final TextEditingController _dayDesCont = TextEditingController();
  final List<TextEditingController> _highLightsControllers = List.generate(1000, (_) => TextEditingController());
  final Day? day;
  DayForm({super.key, required this.user, this.day}){
    if (day!=null) {
      _dayNameCont.text = day!.name!;
      _dayDateCont.text = day!.date!;
      _dayDesCont.text = day!.details!;
      List.generate(day!.highlights!.length, (i) => _highLightsControllers[i].text= day!.highlights![i]!.title!);
    }
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return BlocProvider(
        create: (BuildContext context) => DaysFormCubit(ChangeHighLights()),
        child: BlocBuilder<DaysFormCubit, DaysFormState>(
            builder: (context, state) {
              if (day!=null) {
                if (!BlocProvider.of<DaysFormCubit>(context).init) {
                  if (BlocProvider
                      .of<DaysFormCubit>(context)
                      .moodId == 0)
                    BlocProvider.of<DaysFormCubit>(context).changeMood(
                        day!.mood!.id);
                  List.generate(day!.highlights!.length, (i) =>
                      BlocProvider.of<DaysFormCubit>(context).pickImage(
                          day!.highlights![i]!.image!, i));
                for (int i = 0; i < day!.highlights!.length; i++)
                  BlocProvider.of<DaysFormCubit>(context).increment();
                BlocProvider.of<DaysFormCubit>(context).switchInit(true);    }          }

              Color moodColor = moods[BlocProvider.of<DaysFormCubit>(context).moodId].color;
              return AlertDialog(
                backgroundColor: Colors.grey[200],
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                content: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text("How is your day?") ,
                              const Spacer(),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Icon(Icons.highlight_remove_outlined,
                                      color: Colors.red, size: 30))
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            children: [
                              MoodsList(moodId: day==null ? null : day!.mood!.id,),
                              Column(
                                children: [
                                  CustomFormField(
                                    cont: _dayNameCont,
                                    valid: (String val) {
                                      if (val.length > 40) return "Too Long Text";
                                    },
                                    icon: Icons.today,
                                    hintText: "Day's Name",
                                    width: MediaQuery.of(context).size.width-240,
                                  ),
                                  CustomFormField(
                                    readOnly: true,
                                    onTap:day!=null ? (){} : () async {
                                      DateTime? date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2015, 8),
                                          lastDate: DateTime.now());
                                      _dayDateCont.text = formatDate(date!);
                                      _dayNameCont.text = getDayName(
                                          DateTime.parse(_dayDateCont.text));
                                    },
                                    cont: _dayDateCont,
                                    valid: (val) {
                                      if (day==null) {
                                      for (int i = 0; i < user.days!.length; i++) {
                                        if (user.days![i].date ==
                                            _dayDateCont.text.trim()) {
                                          return "existing Day!";
                                        }
                                      }}
                                    },
                                    icon: Icons.calendar_today_sharp,

                                    hintText: 'Date',
                                    width: MediaQuery.of(context).size.width-240,
                                  ),
                                ],
                              ),

                            ],
                          ),
                          CustomFormField(
                            cont: _dayDesCont,
                            valid: (String val) {
                              if (val.length > 65536) return "Too Long Text";
                            },
                            icon: Icons.edit_note_rounded,
                            canBeEmpty: true,
                            hintText: "Describe your Day ..",
                            width: width * 0.75,
                          ),
                          HighlightList(
                            controllers: _highLightsControllers,
                          ),
                          Button(text: 'Done', onPress: () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            } else if (BlocProvider.of<DaysFormCubit>(context)
                                .moodId ==
                                100) {
                              showToast("Select your mood");
                              return;
                            }
                            showLoading(context, true);
                            int moodId =
                                BlocProvider.of<DaysFormCubit>(context).moodId;
                            String name = _dayNameCont.text.trim();
                            String date = _dayDateCont.text == ''
                                ? formatDate(DateTime.now())
                                : _dayDateCont.text.trim();
                            String details = _dayDesCont.text.trim();
                            String userEmail = user.email!;
                            Day dayObj = Day(
                                moods[moodId],
                                name,
                                date,
                                details,
                                userEmail,
                                List.generate(highLightsNumber(_highLightsControllers), (i) => Highlight(
                                      '$i|$date|$userEmail',
                                      date,
                                      _highLightsControllers[i].text.trim(),
                                      BlocProvider.of<DaysFormCubit>(context)
                                          .images[i],
                                    ),),
                              DateTime.now().toString(),
                              'available'
                            );
                            if (day!=null) {
                              await SqlDataBase.updateADay(dayObj);
                              UserClass user = await SqlDataBase.user(userEmail);
                              showLoading(context, false);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              goTo(context, DaysScreen(user: user));
                              goTo(context, FullDayScreen(day: dayObj),add: true);
                              return;
                            }

                            await SqlDataBase.addADay(dayObj);
                            user.days = await SqlDataBase.usersDays(userEmail);
                            showLoading(context, false);
                            goTo(
                                context,
                                DaysScreen(
                                  user: user,
                                ));
                          }, icon: Icon(Icons.add,size: 0,), color: moodColor,
                          ),

                        ],
                      ),
                    )

                ),

              );
            }
        ));
  }
}

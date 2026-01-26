import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../bloC/days_form_bloc/days_form_cubit.dart';
import '../bloC/days_form_bloc/days_form_states.dart';
import '../const/functions.dart';
import '../const/vars.dart';
import '../models/day.dart';
import '../models/mood.dart';
import '../screens/show_day_screen.dart';

class DayCard extends StatelessWidget {
  final Day day;
  const DayCard({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: day.mood?.color.withOpacity(0.4),
        elevation: 50,
        child: InkWell(
          onTap: (){
            goTo(context, FullDayScreen(day: day), add: true);
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 8, right: 15),
                child: Column(children: [
                  Text(
                    DateTime.parse(day!.date!).day.toString(),
                    style: const TextStyle(fontSize: 35),
                  ),
                  Text(
                    getMonthName(
                      DateTime.parse(day!.date!),
                    ),
                    style: const TextStyle(fontSize: 20),
                  )
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            day.name!,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const Spacer(),
                          Image(image: AssetImage(day.mood!.emoji),height: 55,),

                        ],
                      ),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),

                          child: Column(
                            children: List.generate(  day.highlights!.length, (i) =>Container(
                              width: double.infinity,
                              child: Text(
                                day.highlights![i].title!,
                                style: const TextStyle(fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                            )
                  ),
                        ),
                )
            ],
          ),
        ),
      )]))));
  }
}

class DaysList extends StatelessWidget {
  final List<DayCard> days;
  const DaysList({Key? key, required this.days}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return days[index];
      },
      itemCount: days.length,
    );
  }
}

class MoodCard extends StatelessWidget {
  final Mood mood;
  const MoodCard({super.key, required this.mood});
  @override
  Widget build(BuildContext context) {
    return Container(
        //width: 70,
        decoration: BoxDecoration(
          color: mood.color,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        margin: const EdgeInsets.only(right: 0, top: 5),
        padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10, right: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage(mood.emoji),height: 60,),
            const SizedBox(height: 7,),
            Text(
              mood.title,
              style: TextStyle(color: Colors.black, fontSize: 15),
            )
          ],
        ));
  }
}

class MoodsList extends StatelessWidget {
  final int? moodId;
  PageController _pageController = PageController();
  MoodsList({
    Key? key,
    this.moodId,
  }) : super(key: key){
    if (moodId!=null) {
      _pageController = PageController(initialPage: moodId!);
    }
  }
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5, bottom: 5, right: 5),
          height: 120,
          width: 100,
          child: BlocBuilder<DaysFormCubit, DaysFormState>(
              builder: (context, state) {
            return PageView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                controller: _pageController,
                itemBuilder: (context, i) => i<moods.length ? MoodCard(
                      mood: moods[i],
                    ) : SizedBox(),
                //itemCount: moods.length+1,
                onPageChanged: (i) {
                  if (i==moods.length) {
                    BlocProvider.of<DaysFormCubit>(context)
                        .changeMood(0);
                    _pageController.animateToPage(0, duration: Duration(milliseconds: 10), curve: Curves.fastOutSlowIn,);
                      return;
                  }
                  BlocProvider.of<DaysFormCubit>(context)
                      .changeMood(moods[i].id);
                });
          }),
        ),
      ],
    );
  }
}

class HighlightList extends StatefulWidget {
  final List<TextEditingController> controllers;
  HighlightList({super.key, required this.controllers}){
  //  number = highLightsNumber(controllers);
  }

  @override
  State<HighlightList> createState() => _HighlightListState();
}

class _HighlightListState extends State<HighlightList> {
  final ScrollController _controller = ScrollController();

  void _scrollDown() async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 700),
        curve: Curves.fastOutSlowIn,
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int number = BlocProvider.of<DaysFormCubit>(context).numberOfHighlights;
        return Column(
          children: [
            AnimatedContainer(
              margin: const EdgeInsets.only(top: 1),
              height: number.toDouble()*80,
              width: width,
              constraints: const BoxConstraints(maxHeight: 90*2 ),
              duration: const Duration(milliseconds: 300),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                controller: _controller,
                itemBuilder: (BuildContext context, int i) {
                  return Row(
                    children: [
                      CustomFormField(
                        cont: widget.controllers[i],
                        valid: (String val) {
                          if (val.length > 300) return "Too Long Text";
                        },
                        width: width - 210,
                        icon: Icons.task_alt_rounded,
                        hintText: "${i + 1}.  highlight",
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      BlocBuilder<DaysFormCubit, DaysFormState>(
                          builder: (context, state) {
                        return Row(
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () async {
                               BlocProvider.of<DaysFormCubit>(context).pickImage(await pickImage(context: context), i);
                              },
                              child: BlocProvider.of<DaysFormCubit>(context).images[i] == "" ? Icon(Icons.photo_camera, size: 35,
                                color: moods[BlocProvider.of<DaysFormCubit>(
                                                      context)
                                                  .moodId]
                                          .color,
                                    )
                                  :  Image.memory(showImage(BlocProvider.of<DaysFormCubit>(
                                                      context)
                                                  .images[i]), width: 35,
                                        height: 35,),
                            ),
                            TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () async {
                                  BlocProvider.of<DaysFormCubit>(context).images.removeAt(i);
                                  widget.controllers.removeAt(i);
                                  BlocProvider
                                      .of<DaysFormCubit>(
                                      context).decrement();

                                                              },
                                child: Icon(
                                  Icons.delete,
                                  size: 35,
                                  color: moods[BlocProvider.of<DaysFormCubit>(
                                              context)
                                          .moodId]
                                      .color,
                                )),
                          ],
                        );
                      }),
                    ],
                  );
                },
                itemCount: BlocProvider.of<DaysFormCubit>(context).numberOfHighlights,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Button(
                  text: 'Add Highlight',
                  onPress: () async {
                    BlocProvider
                        .of<DaysFormCubit>(
                        context).increment();
                    _scrollDown();
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 0,
                  ),
                  color:
                      moods[BlocProvider.of<DaysFormCubit>(context).moodId].color,
                )
              ],
            ),
          ],
        );


  }
}

class CustomFormField extends StatelessWidget {
  final TextEditingController cont;
  final String hintText;
  final IconData? icon;
  final bool? center;
  final double width;
  final TextInputType? type;
  final Function? onTap;
  final Function valid;
  final bool? readOnly;
  final bool? canBeEmpty;
  final bool? obscureText;
  const CustomFormField(
      {super.key,
      required this.cont,
      required this.hintText,
      this.icon,
      this.center,
      required this.width,
      this.type,
      this.onTap,
      this.readOnly,
      this.canBeEmpty,
      required this.valid, this.obscureText});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 140),
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.grey[100]!.withOpacity(0.8), borderRadius: BorderRadius.circular(29.5)),
        child: Scrollbar(
          child: TextFormField(
            style: const TextStyle(fontSize: 13.5),
            readOnly: readOnly == null ? false : readOnly!,
            textAlign: center == true ? TextAlign.center : TextAlign.start,
            minLines: 1,
            maxLines: obscureText==true ? 1 : 5,
            obscureText: obscureText??false,
            keyboardType: type ?? TextInputType.text,
            onTap: () {
              onTap != null ? onTap!() : null;
            },
            validator: (val) {
              if ((val!.isEmpty || val.replaceAll(' ', '').isEmpty) &&
                  canBeEmpty != true) return "Empty";
              return valid(val);
              return null;
            },
            controller: cont,
            decoration: InputDecoration(
                hintStyle: const TextStyle(color: Colors.deepOrange),
                labelStyle: TextStyle(color: mainColor),
                alignLabelWithHint: true,
                border: InputBorder.none,
                hintText: hintText,
                labelText: hintText,
                icon: icon == null
                    ? null
                    : Icon(
                        icon,
                        size: 25,
                      )),
          ),
        ),
      ),
    );
  }
}

//sief.gmail.com


class Button extends StatelessWidget {
  final String text;
  final Function onPress;
  final Color? color;
  final Widget? icon;
  const Button(
      {Key? key,
      required this.text,
      required this.onPress,
      this.icon,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(50))),
          child: Text(
            '$text ',
            style: const TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700),
          )),
      onPressed: () async => onPress(),
    );
  }
}

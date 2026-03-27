import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_days/core/components/fab.dart';


import '../../fearutes/data/logic/bloC/app_theme_bloc/app_theme_cubit.dart';
import '../../fearutes/data/logic/bloC/days_bloc/days_cubit.dart';
import '../../fearutes/data/logic/bloC/days_form_bloc/days_form_cubit.dart';
import '../../fearutes/data/logic/bloC/days_form_bloc/days_form_states.dart';
import '../../fearutes/data/models/day.dart';
import '../../fearutes/data/models/highlight.dart';
import '../../fearutes/data/models/user.dart';
import '../const/functions.dart';
import '../const/vars.dart';
import 'widgets.dart';

class DayFormScreen extends StatefulWidget {
  final UserClass user;
  final Day? day;

  const DayFormScreen({super.key, this.day, required this.user});

  @override
  State<DayFormScreen> createState() => _DayFormScreenState();
}

class _DayFormScreenState extends State<DayFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dayDateCont;
  late TextEditingController _dayNameCont;
  late TextEditingController _dayDesCont;
  late List<TextEditingController> _highLightsControllers;

  @override
  void initState() {
    super.initState();

    _dayDateCont = TextEditingController(
      text: widget.day?.date ?? formatDate(DateTime.now()),
    );
    _dayNameCont = TextEditingController(
      text: widget.day?.name ?? getDayName(DateTime.now()),
    );
    _dayDesCont = TextEditingController(text: widget.day?.details ?? "");

    _highLightsControllers = List.generate(
      100,
      (i) => TextEditingController(
        text: (widget.day != null && i < widget.day!.highlights!.length)
            ? widget.day!.highlights![i].title
            : "",
      ),
    );
  }

  @override
  void dispose() {
    _dayDateCont.dispose();
    _dayNameCont.dispose();
    _dayDesCont.dispose();
    for (var c in _highLightsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppThemeCubit>();
    final DaysFormCubit cubit = DaysFormCubit(ChangeHighLights());

    return BlocProvider(
      create: (context) {
        if (widget.day != null) {
          cubit.changeMood(widget.day!.mood!.id);
          cubit.deletedHighLights = widget.day?.deletedHighlights ?? [];
          for (int i = 0; i < widget.day!.highlights!.length; i++) {
            cubit.pickImage(widget.day!.highlights![i].image!, i);
            cubit.pickStatus(widget.day!.highlights![i].status!, i);
            cubit.increment();
          }
          cubit.switchInit(true);
        }
        return cubit;
      },
      child: BlocBuilder<DaysFormCubit, DaysFormState>(
        builder: (context, state) {
          final formCubit = context.read<DaysFormCubit>();
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    theme.wallpaper,
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.5),
                  ),
                ),

                SafeArea(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildCustomAppBar(context),
                        Expanded(
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children: [
                              _buildMoodAndHeader(formCubit),
                              const SizedBox(height: 30),

                              HighlightList(
                                controllers: _highLightsControllers,
                                day: widget.day,
                              ),
                              const Divider(
                                color: Colors.white10,
                                thickness: 1,
                              ),
                              const SizedBox(height: 10),

                              DescriptionField(
                                controller: _dayDesCont,
                                userName: widget.user.name!,
                              ),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: CustomFAB(
              text: widget.day == null ? "Add Day" : "Edit Day",
              icon: Icons.check,
              color: moods[cubit.moodId == 100 ? 1 : cubit.moodId].color,
              function: () async {
                if (!_formKey.currentState!.validate()) return;
                showAlert(
                  context,
                  widget.day == null
                      ? "Are you sure to Day?"
                      : "Are you sure to edit Day?",
                  () => _submitData(context, cubit),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          const Text(
            "Day",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildMoodAndHeader(DaysFormCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: 250, child: MoodsList(moodId: widget.day?.mood!.id)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              CustomFormField(
                icon: Icons.calendar_today,
                cont: _dayNameCont,
                hintText: "Title of the day",
                valid: (val) {
                  return null;
                },
              ),
              const SizedBox(height: 10),
              CustomFormField(
                cont: _dayDateCont,
                icon: Icons.alarm,
                hintText: "Date",
                readOnly: true,
                onTap: widget.day != null ? null : () => _pickDate(context),
                valid: (val) {
                  if (widget.day == null) {
                    bool isDuplicate = (widget.user.days).any(
                      (e) =>
                          e.date!.substring(0, 10) ==
                          _dayDateCont.text.substring(0, 10),
                    );

                    if (isDuplicate) {
                      return "You already added this day!";
                    }
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.blueAccent),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dayDateCont.text = formatDate(picked);
      _dayNameCont.text = getDayName(picked);
    }
  }

  void _submitData(BuildContext context, DaysFormCubit cubit) async {
    if (cubit.moodId == 100) {
      showToast("Pick your mood first!");
      return;
    }

    showLoading(context, true);
     List<Highlight> finalHighlights = [];
      for (int i = 0; i < highLightsNumber(_highLightsControllers); i++) {
        String uniqueId;
        if (widget.day != null && i < widget.day!.highlights!.length) {
          uniqueId = widget.day!.highlights![i].id!;
        } else {
          uniqueId = "${DateTime.now().millisecondsSinceEpoch}_$i|${_dayDateCont.text.trim()}|${widget.user.email}";
        }
        finalHighlights.add(Highlight(
          uniqueId,
          _dayDateCont.text.trim(),
          _highLightsControllers[i].text.trim(),
          cubit.images[i],
          cubit.status[i],
        ));
      }

      final dayObj = Day(
        moods[cubit.moodId],
        _dayNameCont.text.trim(),
        _dayDateCont.text.trim(),
        _dayDesCont.text.trim(),
        widget.user.email!,
        finalHighlights,
        DateTime.now().toString(),
        'available',
        deletedHighlights: cubit.deletedHighLights,
      );

    if (widget.day != null) {
      await context.read<DaysCubit>().updateDay(dayObj);
    } else {
      await context.read<DaysCubit>().addDay(dayObj);
    }
    showLoading(context, false);
    Navigator.pop(context);
  }
}

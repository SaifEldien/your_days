import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_days/core/components/smart_image.dart';

import '../../fearutes/data/logic/bloC/days_form_bloc/days_form_cubit.dart';
import '../../fearutes/data/models/day.dart';
import '../../fearutes/data/models/highlight.dart';
import '../../fearutes/data/models/mood.dart';
import '../../fearutes/ui/screens/show_day_screen.dart';
import '../const/functions.dart';
import '../const/vars.dart';


class DayCard extends StatelessWidget {
  final Day day;
  const DayCard({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(day.date ?? '') ?? DateTime.now();
    final color = day.mood?.color ?? Colors.blue;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: .3), color.withValues(alpha: .05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              FocusScope.of(context).unfocus();
              goTo(context, FullDayScreen(dayDate: day.date!), add: true);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Date Column ---
                  _buildDateSection(date, color),

                  const SizedBox(width: 16),

                  // --- Vertical Divider ---
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.white.withValues(alpha: .2),
                  ),

                  const SizedBox(width: 16),

                  // --- Content Section ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                day.name ?? '',
                                style: const TextStyle(
                                  fontSize: 22, // Size adjusted for hierarchy
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildHighlightsList(day.highlights),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(left: 20),
                    child: Image.asset(day.mood!.emoji, height: 50),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection(DateTime date, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          date.day.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: color.withValues(alpha: .9),
          ),
        ),
        Text(
          getMonthName(date).toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsList(List<Highlight>? highlights) {
    if (highlights == null || highlights.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: highlights
          .map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.bolt, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      h.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: .6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class DaysList extends StatelessWidget {
  final List<Day> days;
  const DaysList({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 100),
      physics: const BouncingScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (context, index) => DayCard(day: days[index]),
    );
  }
}

class MoodsList extends StatefulWidget {
  final int? moodId;
  const MoodsList({super.key, this.moodId});

  @override
  State<MoodsList> createState() => _MoodsListState();
}

class _MoodsListState extends State<MoodsList> {
  late PageController _pageController;
  double _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _currentPage = (widget.moodId ?? 1).toDouble();
    _pageController = PageController(
      initialPage: _currentPage.toInt(),
      viewportFraction: 0.45,
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 140,
      child: ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: [0.0, 0.2, 0.8, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          controller: _pageController,
          itemCount: moods.length,
          onPageChanged: (index) {
            HapticFeedback.mediumImpact();
            context.read<DaysFormCubit>().changeMood(moods[index].id);
          },
          itemBuilder: (context, index) {
            final double relativePosition = index - _currentPage;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(1, 2, 0.0000)
                // ignore: deprecated_member_use
                ..translate(0.0, relativePosition, 0.0)
                // ignore: deprecated_member_use
                ..scale(1 - (relativePosition.abs() * 0.25))
                ..rotateX(relativePosition * 0.6),
              alignment: Alignment.center,
              child: Opacity(
                opacity: (1 - (relativePosition.abs() * 0.5)).clamp(0.0, 1.0),
                child: _MoodCard(
                  mood: moods[index],
                  isSelected: relativePosition.abs() < 0.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final Mood mood;
  final bool isSelected;

  const _MoodCard({required this.mood, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      decoration: BoxDecoration(
        color: mood.color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: mood.color.withValues(alpha: .5),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
        border: Border.all(
          color: isSelected
              ? Colors.white.withValues(alpha: .5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'mood_${mood.id}',
            child: Image.asset(mood.emoji, height: 50),
          ),
          const SizedBox(height: 8),
          Text(
            mood.title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class HighlightList extends StatefulWidget {
  final List<TextEditingController> controllers;
  final Day? day;
  const HighlightList({
    super.key,
    required this.controllers,
    required this.day,
  });

  @override
  State<HighlightList> createState() => _HighlightListState();
}

class _HighlightListState extends State<HighlightList> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DaysFormCubit>();
    final moodColor = moods[cubit.moodId == 100 ? 1 : cubit.moodId].color;
    final int count = cubit.numberOfHighlights;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: moodColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                "TODAY'S HIGHLIGHTS",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Column(
                children: [_buildAddButton(context, cubit, moodColor, count)],
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          constraints: BoxConstraints(
            maxHeight: count < 5 ? count * 85 : 320, // Grows with content
          ),
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: count,
            itemBuilder: (context, i) =>
                _buildHighlightCard(context, i, cubit, moodColor, widget.day),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildHighlightCard(
    BuildContext context,
    int i,
    DaysFormCubit cubit,
    Color moodColor,
    final Day? day,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              String path = await pickImage(context: context) ?? "";
              cubit.pickImage(path, i);
            },
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: moodColor.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: cubit.images[i] == ""
                  ? Icon(Icons.add_a_photo_rounded, color: moodColor, size: 20)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: SmartImageWidget(
                        isSquare: true,
                        imagePath: cubit.images[i],
                        size: 55,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: widget.controllers[i],
              validator: (val) => (val == null || val.isEmpty)
                  ? "Mention A Special Moment"
                  : null,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "What was special?...",
                hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              if (day != null) {
                if ( i < day.highlights!.length) {
                  final highlightToDelete = day.highlights![i];
                  cubit.deletedHighLights.add(
                    Highlight(
                      highlightToDelete.id,
                      day.date,
                      highlightToDelete.title,
                      highlightToDelete.image,
                      "deleted",
                    ),
                  );
                  day.highlights!.removeAt(i);
                }

              }
              cubit.images.removeAt(i);
              widget.controllers.removeAt(i);
              cubit.decrement();
            },
            icon: const Icon(
              Icons.remove_circle_outline_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    DaysFormCubit cubit,
    Color moodColor,
    int count,
  ) {
    return InkWell(
      onTap: () {
        if (cubit.numberOfHighlights == 100) {
          showToast("Maximum Number Of high lights");
          return;
        }
        cubit.increment();
        _scrollToBottom();
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: moodColor.withValues(alpha: .3)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: moodColor, size: 25),
            const SizedBox(width: 8),
            Text(
              "Add Highlight  \n"
              "($count/100)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: moodColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFormField extends StatefulWidget {
  final TextEditingController cont;
  final String hintText;
  final IconData? icon;
  final bool? center;
  final double? width;
  final TextInputType? type;
  final VoidCallback? onTap;
  final String? Function(String?) valid;
  final bool readOnly;
  final bool canBeEmpty;
  final bool isPassword;

  const CustomFormField({
    super.key,
    required this.cont,
    required this.hintText,
    this.icon,
    this.center,
    this.width,
    this.type,
    this.onTap,
    this.readOnly = false,
    this.canBeEmpty = false,
    required this.valid,
    this.isPassword = false,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.isPassword;
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 2.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fieldColor = isDark
        ? Colors.black.withValues(alpha: .3)
        : Colors.white.withValues(alpha: .2);
    final Color borderColor = Colors.white.withValues(alpha: .15);
    final Color focusColor = Theme.of(
      context,
    ).primaryColor.withValues(alpha: .5);

    return SizedBox(
      width: widget.width ?? double.infinity,
      child: TextFormField(
        maxLines: null,
        controller: widget.cont,
        readOnly: widget.readOnly,
        obscureText: _isObscure,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: widget.type,
        onTap: widget.onTap,
        textAlign: widget.center == true ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        validator: (val) {
          if (!widget.canBeEmpty && (val == null || val.trim().isEmpty)) {
            return "Field required";
          }
          return widget.valid(val);
        },
        decoration: InputDecoration(
          isDense: true,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: fieldColor,
          labelText: widget.hintText,

          prefixIconConstraints: const BoxConstraints(
            minWidth: 45,
            minHeight: 0,
          ),

          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: .7),
            fontSize: 15,
          ),
          floatingLabelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),

          hintText: "Enter ${widget.hintText}",
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: .3),
            fontSize: 13,
          ),
          prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: Colors.white.withValues(alpha: .7),
                  size: 22,
                )
              : null,

          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                )
              : null,

          contentPadding: const EdgeInsets.fromLTRB(16, 26, 16, 12),
          border: _buildBorder(borderColor),
          enabledBorder: _buildBorder(borderColor),
          focusedBorder: _buildBorder(focusColor, width: 1.5),
          errorBorder: _buildBorder(Colors.redAccent.withValues(alpha: .5)),
          errorStyle: const TextStyle(height: 0.8, color: Colors.redAccent),
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final Function onPress;
  final Color? color;
  final Widget? icon;
  const AppButton({
    super.key,
    required this.text,
    required this.onPress,
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
        ),
        child: Text(
          '$text ',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      onPressed: () async => onPress(),
    );
  }
}

// ignore: must_be_immutable
class DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  String? hintText;
  final double height;
  final String userName;
  DescriptionField({
    super.key,
    required this.userName,
    required this.controller,
    this.height = 200,
  }) {
    hintText =
        hintText ?? "How was your day,$userName? Write your heart out...";
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: .1),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          TextFormField(
            controller: controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white, fontSize: 15),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(
              Icons.edit_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: .1),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_days/core/components/fab.dart';
import 'package:my_days/core/components/smart_image.dart';

import '../../../core/components/day_form.dart';
import '../../../core/const/functions.dart';
import '../../data/logic/bloC/app_theme_bloc/app_theme_cubit.dart';
import '../../data/logic/bloC/days_bloc/days_cubit.dart';
import '../../data/logic/bloC/days_bloc/days_states.dart';
import '../../data/logic/bloC/user_bloc/user_cubit.dart';
import '../../data/logic/bloC/user_bloc/user_states.dart';
import '../../data/models/day.dart';
import '../../data/models/highlight.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FullDayScreen extends StatefulWidget {
  final String dayDate;
  const FullDayScreen({super.key, required this.dayDate});

  @override
  State<FullDayScreen> createState() => _FullDayScreenState();
}

class _FullDayScreenState extends State<FullDayScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DaysCubit, DaysState>(
      builder: (context, state) {
        if (state is! DaysLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final dayIndex = state.days.indexWhere((e) => e.date == widget.dayDate);
        final Day? day = dayIndex == -1 ? null : state.days[dayIndex];
        if (day == null) {
          return const Scaffold(body: Center(child: Text('Day not found')));
        }
        final themeCubit = context.read<AppThemeCubit>();
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(themeCubit.wallpaper),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(context, day, themeCubit),
            body: Column(
              children: [
                _buildHeader(day),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => _currentPage.value = index,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildHighlightsGrid(day),
                      _buildDetailedNotes(day),
                    ],
                  ),
                ),
                _buildBottomNavigation(),
              ],
            ),
            floatingActionButton: CustomFAB(
              text: "Edit Day",
              icon: Icons.edit_note_rounded,
              color: themeCubit.color,
              form: DayFormScreen(
                user: (context.read<UserCubit>().state as UserSuccess).user,
                day: day,
              ),
            ),
          ),
        );
      },
    );
  }

  // --- UI Components (Modular Approach) ---

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    Day day,
    AppThemeCubit theme,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        day.date!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.delete_sweep_rounded,
            size: 28,
            color: Colors.white,
          ),
          onPressed: () => _handleDelete(context, day, theme),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildHeader(Day day) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day.name ?? '',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: day.mood!.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Text(
                  "${day.mood!.title} ",
                  style: const TextStyle(color: Colors.white),
                ),
                Image.asset(day.mood!.emoji, height: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsGrid(Day day) {
    return MasonryGridView.count(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: day.highlights!.length,
      itemBuilder: (context, index) {
        return HighLightShow(highlight: day.highlights![index]);
      },
    );
  }

  Widget _buildDetailedNotes(Day day) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha:.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha:.1)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Text(
          (day.details == null || day.details!.isEmpty)
              ? 'You Did Not Write Your Hearout , Click The Button And Write Now!'
              : day.details!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: ValueListenableBuilder<int>(
        valueListenable: _currentPage,
        builder: (context, value, _) => Indicator(length: 2, index: value),
      ),
    );
  }

  void _handleDelete(BuildContext context, Day day, AppThemeCubit theme) {
    showAlert(context, "Are you sure you want to delete this day?", () async {
      showLoading(context, true);
      await context.read<DaysCubit>().deleteDay(day);
      if (theme.appBarIndex == 1) theme.switchBars();
      showLoading(context, false);
      Navigator.pop(context);
    });
  }
}

class Indicator extends StatelessWidget {
  final int length;
  final int index;
  const Indicator({super.key, required this.length, required this.index});
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
                  ? BlocProvider.of<AppThemeCubit>(
                      context,
                    ).color.withValues(alpha:.7)
                  : Colors.grey[100],
            ),
          ),
        ),
      ),
    );
  }
}

class HighLightShow extends StatelessWidget {
  final Highlight highlight;

  const HighLightShow({super.key, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final themeColor = context.read<AppThemeCubit>().color;
    final hasImage = highlight.image != null && highlight.image!.isNotEmpty;

    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha:.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: hasImage
                  ? SmartImageWidget(
                      imagePath: highlight.image!,
                      isSquare: true,
                      size: double.infinity,
                    )
                  : Container(color: themeColor.withValues(alpha:.2)),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: hasImage ? 180 : 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: !hasImage
                      ? null
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha:.7),
                            Colors.black.withValues(alpha:.9),
                          ],
                        ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: hasImage ? 50 : 230,
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(8),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              highlight.title ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 1000,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'SFPro',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.3,
                                letterSpacing: 0.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha:.4,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

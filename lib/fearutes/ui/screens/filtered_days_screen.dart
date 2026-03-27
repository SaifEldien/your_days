import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/components/widgets.dart';
import '../../../core/const/vars.dart';
import '../../data/logic/bloC/app_theme_bloc/app_theme_cubit.dart';
import '../../data/models/day.dart';
import '../../data/models/mood.dart';

class FilteredDaysScreen extends StatefulWidget {
  const FilteredDaysScreen({super.key, required this.days});
  final List<Day> days;

  @override
  State<FilteredDaysScreen> createState() => _FilteredDaysScreenState();
}

class _FilteredDaysScreenState extends State<FilteredDaysScreen> {
  int moodId = 13;
  int dateFilter = 1;
  late List<DropdownMenuItem<Mood>> moodItems;

  @override
  void initState() {
    super.initState();
    _prepareMoodItems();
  }

  void _prepareMoodItems() {
    moodItems = moods
        .map(
          (m) => DropdownMenuItem(value: m, child: _buildMoodDropdownItem(m)),
        )
        .toList();

    moodItems.add(
      DropdownMenuItem(
        value: Mood(13, Colors.white24, "All Moods", ""),
        child: const Text("All Moods", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMoodDropdownItem(Mood mood) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 6, backgroundColor: mood.color),
        const SizedBox(width: 10),
        Text(mood.title, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  List<Day> _getFilteredDays() {
    List<Day> results = widget.days;

    // فلتر المود
    if (moodId != 13) {
      results = results.where((d) => d.mood!.id == moodId).toList();
    }

    // فلتر التاريخ
    if (dateFilter == 0) {
      final now = DateTime.now();
      results = results.where((d) {
        final date = DateTime.tryParse(d.date ?? '');
        return date != null && date.month == now.month && date.year == now.year;
      }).toList();
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppThemeCubit>();
    final filteredDays = _getFilteredDays();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Filter Journals",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(theme.wallpaper, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha:.3)),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildFilterBar(),
                const SizedBox(height: 10),
                Expanded(
                  child: filteredDays.isEmpty
                      ? _buildEmptyState()
                      : DaysList(days: filteredDays),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha:.1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Mood Dropdown
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Mood>(
                  dropdownColor: Colors.grey[900],
                  value: moodItems
                      .firstWhere((item) => item.value!.id == moodId)
                      .value,
                  items: moodItems,
                  onChanged: (val) => setState(() => moodId = val!.id),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            const VerticalDivider(
              color: Colors.white24,
              indent: 10,
              endIndent: 10,
            ),
            // Date Dropdown
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  dropdownColor: Colors.grey[900],
                  value: dateFilter,
                  items: const [
                    DropdownMenuItem(
                      value: 1,
                      child: Text(
                        "All Time",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 0,
                      child: Text(
                        "This Month",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => dateFilter = val!),
                  icon: const Icon(
                    Icons.calendar_month,
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 80,
            color: Colors.white.withValues(alpha:.2),
          ),
          const SizedBox(height: 16),
          const Text(
            "No days match your filters",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

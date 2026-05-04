import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/const/functions.dart';
import '../../../../../core/const/vars.dart';
import '../../../../../core/database/database_intialzing.dart';
import '../../../models/day.dart';
import '../user_bloc/user_cubit.dart';
import '../user_bloc/user_states.dart';
import 'days_states.dart';

class DaysCubit extends Cubit<DaysState> {
  final UserCubit userCubit;

  DaysCubit({required this.userCubit}) : super(DaysInitial());
  Future<void> fetchDays() async {
    emit(DaysLoading());
    try {
      final userState = userCubit.state;
      if (userState is! UserSuccess) {
        emit(DaysError("User not authenticated"));
        return;
      }
      List<Day> allDays = await SqlDataBase.usersDays(userState.user.email!);
      final availableDays = allDays
          .where((e) => e.status == "available")
          .toList()
        ..sort((a, b) => b.date!.compareTo(a.date!));

      final deletedDays = allDays
          .where((e) => e.status == "deleted")
          .toList();
      userState.user.days = availableDays;
      userState.user.deletedDays = deletedDays;
      emit(DaysLoaded(
          days: availableDays,
          deletedDays: deletedDays
      ));
      debugPrint("✅ Fetched ${availableDays.length} active and ${deletedDays.length} deleted days.");
    } catch (e) {
      debugPrint("❌ Fetch Error: $e");
      emit(DaysError("Couldn't fetch days: $e"));
    }
  }

  Future<void> deleteDay(Day day) async {
    try {
      if (state is DaysLoaded) {
        final currentDays = List<Day>.from((state as DaysLoaded).days);
        final deletedDays = List<Day>.from((state as DaysLoaded).deletedDays);
        day.status = "deleted";
        day.highlights = [];
        await  SqlDataBase.updateADay(day);
        currentDays.removeWhere((d) => d.date == day.date);
        if (!deletedDays.any((d) => d.date == day.date)) {
          deletedDays.add(day);
        }
        final userState = userCubit.state;
        if (userState is UserSuccess) {
          userState.user.days = currentDays;
          userState.user.deletedDays = deletedDays;
        }
        emit(DaysLoaded(days: currentDays, deletedDays: deletedDays));
        debugPrint("✅ Day ${day.date} moved to deleted status locally.");
      }
    } catch (e) {
      debugPrint("❌ Delete failed: $e");
      emit(DaysError("Delete failed: $e"));
    }
  }

  Future<void> updateDay(Day day) async {
    try {
      await SqlDataBase.updateADay(day);
      if (state is DaysLoaded) {
        final List<Day> currentDays = List<Day>.from((state as DaysLoaded).days);
        final List<Day> deletedDays = List<Day>.from((state as DaysLoaded).deletedDays);
        int index = currentDays.indexWhere(
                (d) => d.date?.trim() == day.date?.trim()
        );
        if (index != -1) {
          currentDays[index] = day;
          debugPrint("✅ Day updated at index $index");
        } else {
          debugPrint("⚠️ Day not found in current list, check date format!");
        }
        final userState = userCubit.state;
        if (userState is UserSuccess) {
          userState.user.days = currentDays;
        }
        emit(DaysLoaded(days: currentDays, deletedDays: deletedDays));
      }
    } catch (e) {
      debugPrint("❌ Update Error: $e");
      emit(DaysError("Update failed: $e"));
    }
  }

  Future<void> addDay(Day day) async {
    try {
      SqlDataBase.addADay(day);
      if (state is DaysLoaded) {
        final currentDays = (state as DaysLoaded).days;
        currentDays.add(day);
        currentDays.sort((a, b) => b.date!.compareTo(a.date!));
        (userCubit.state as UserSuccess).user.days = currentDays;
        emit(
          DaysLoaded(
            days: currentDays,
            deletedDays: (userCubit.state as UserSuccess).user.deletedDays!,
          ),
        );
      }
    } catch (e) {
      emit(DaysError("Add Day failed: $e"));
    }
  }

  Future<void> fillMissingDays() async {
    List<Day> days = (state as DaysLoaded).days;
    String email = days.first.userEmail!;
    if (days.isEmpty) return;
    try {
      DateTime firstDate = DateTime.parse(days.last.date!.substring(0, 10));
      int numberOfDays = DateTime.now().difference(firstDate).inDays;
      List<Day> missingDays = [];
      for (int i = 1; i <= numberOfDays; i++) {
        String currentDate = firstDate
            .add(Duration(days: i))
            .toString()
            .substring(0, 10);
        bool exists = days.any((e) => e.date!.substring(0, 10) == currentDate);
        if (!exists) {
          missingDays.add(
            Day(
              moods[1],
              getDayName(DateTime.parse(currentDate)),
              currentDate,
              "",
              email,
              [],
              DateTime.now().toString(),
              "available",
            ),
          );
        }
      }

      if (missingDays.isNotEmpty) {
        await SqlDataBase.addMultipleDays(missingDays);
        await fetchDays();
      }
    } catch (e) {
      emit(DaysError(e.toString()));
    }
  }
}

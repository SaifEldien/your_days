import '../../../models/day.dart';

abstract class DaysState {}

class DaysInitial extends DaysState {}

class DaysLoading extends DaysState {}

class DaysLoaded extends DaysState {
  final List<Day> days;
  final List<Day> deletedDays;
  DaysLoaded({required this.days, required this.deletedDays});
}

class DaysError extends DaysState {
  final String message;
  DaysError(this.message);
}

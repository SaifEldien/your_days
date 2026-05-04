import 'package:bloc/bloc.dart';

import '../../../models/highlight.dart';
import 'days_form_states.dart';

class DaysFormCubit extends Cubit<DaysFormState> {
  DaysFormCubit(super.initialState);
  bool init = false;
  int moodId = 1;
  int numberOfHighlights = 0;
  final List<String> images = List.generate(100, (_) => "");
  final List<String> status = List.generate(100, (_) => "available");
  List<Highlight> deletedHighLights = [];
  void pickImage(String image, int index) {
    images[index] = image;
    emit(ChooseImage());
  }

  void pickStatus(String stat, int index) {
    status[index] = stat;
    emit(ChangeHighLights());
  }

  void increment() {
    numberOfHighlights++;
    emit(ChangeHighLights());
  }

  void decrement() {
    numberOfHighlights--;
    emit(ChangeHighLights());
  }

  void changeMood(int newId) {
    moodId = newId;
    emit(ChangeMood());
  }

  void switchInit(bool newInit) {
    init = newInit;
  }
}

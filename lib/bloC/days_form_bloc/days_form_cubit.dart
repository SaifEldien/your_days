import 'package:bloc/bloc.dart';

import 'days_form_states.dart';

class DaysFormCubit extends Cubit<DaysFormState> {
  DaysFormCubit(super.initialState);
  bool init = false;
  int moodId = 0;
  int numberOfHighlights = 0;
  final List<String> images = List.generate(1000, (_) => "");

  void pickImage(String image,int index) {
    images[index]=image;
    emit(ChooseImage());
  }

  void increment (){
   numberOfHighlights++;
   emit(ChangeHighLights());
}
  void decrement (){
    numberOfHighlights--;
    emit(ChangeHighLights());
  }
  void changeMood(int newId) {
    moodId = newId ;
    emit(ChangeMood());
  }
  void switchInit (newInit){
    init = newInit;
  }





}
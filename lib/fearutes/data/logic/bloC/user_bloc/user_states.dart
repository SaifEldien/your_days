
import '../../../models/user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserFirstTime extends UserState {}

class UserUnauthenticated extends UserState {}

class UserSuccess extends UserState {
  final UserClass user;
  UserSuccess(this.user);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

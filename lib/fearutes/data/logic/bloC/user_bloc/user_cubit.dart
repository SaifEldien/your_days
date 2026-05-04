import 'package:bloc/bloc.dart' show Cubit;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_days/core/database/database_intialzing.dart';

import '../../../../../core/Server/firebase_quiries.dart';
import '../../../../../core/const/functions.dart';
import '../../../models/user.dart';
import 'user_states.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());
  Future<void> loadUser(String email) async {
    emit(UserLoading());
    try {
      UserClass user = await SqlDataBase.user(email);
      emit(UserSuccess(user));
    } catch (e) {
      emit(UserError("Failed to load user: $e"));
    }
  }

  Future<void> checkAuthStatus() async {
    emit(UserLoading());
    bool isFirstTime = bool.tryParse(await getPref('firstTime') ?? '') ?? true;
    if (isFirstTime) {
      emit(UserFirstTime());
      return;
    }

    String? email = await getPref("userEmail");
    if (email == null) {
      emit(UserUnauthenticated());
      return;
    }

    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      UserClass user = await SqlDataBase.user(email);
      emit(UserSuccess(user));
    } else {
      emit(UserUnauthenticated());
    }
  }

  Future<void> updateUser(UserClass newUser) async {
    await SqlDataBase.updateUser(newUser);
    emit(UserSuccess(newUser));
  }

  Future<void> login(String email, String password) async {
    emit(UserLoading());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      UserClass? user = await FireBaseQueries.retrieveUser(email);
      if (user == null) {
        user = UserClass.defaultUser(email);
        FireBaseQueries.addUser(user);
      }
      await SqlDataBase.addToUsers(user);
      setPref('userEmail', email);
      emit(UserSuccess(user));
    } catch (e) {
      showToast(e.toString(), long: true, isError: true);
      emit(UserError(e.toString()));
    }
  }

  Future<void> loginWithGoogle() async {
    debugPrint("🟡 Starting Google Sign-In...");
    emit(UserLoading());

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      final FirebaseAuth auth = FirebaseAuth.instance;
      await googleSignIn.initialize();
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await auth.signInWithCredential(
        credential,
      );
      if (userCredential.user == null) {
        emit(UserError("Firebase authentication failed"));
      } else {
        String email = userCredential.user!.email!;
        UserClass? user = await FireBaseQueries.retrieveUser(email);
        if (user == null) {
          user = UserClass.defaultUser(email);
          FireBaseQueries.addUser(user);
        }
        SqlDataBase.addToUsers(user);
        setPref("userEmail", user.email);
        debugPrint("✅ User Authorized: ${user.name}");
        emit(UserSuccess(user));
      }
    } catch (e) {
      debugPrint("🚨 Sign-In Error: $e");
      emit(UserError("Google Sign-In Error: ${e.toString()}"));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(UserLoading());
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      setPref('userEmail', email);
      UserClass user = UserClass.defaultUser(email);
      SqlDataBase.addToUsers(user);
      FireBaseQueries.addUser(user);
      emit(UserSuccess(user));
    } catch (e) {
      showToast(firebaseErrors(e.toString()), long: true, isError: true);
      emit(UserError(firebaseErrors(e.toString())));
    }
  }
}

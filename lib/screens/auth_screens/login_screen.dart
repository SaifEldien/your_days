// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:my_days/screens/auth_screens/signup_screen.dart';


import '../../Server/firebaseQuiries.dart';
import '../../components/widgets.dart';
import '../../const/functions.dart';
import '../../const/vars.dart';
import '../../database/database_intialzing.dart';
import '../../models/user.dart';
import '../add_user_info_screen.dart';
import '../days_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';



class LoginScreen  extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<LoginScreen> {
  @override
  void initState() {
    // TODO: implement initState
    setPref('firstTime', 'false');
    super.initState();
  }
  final _contEmail = TextEditingController();
  final _contPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(mainWallpaper), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 80),
            child: const Text(
              "Welcome\nBack",
              style: TextStyle(color: Colors.white, fontSize: 33),
            ),
          ),
          Center(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                      right: 35,
                      left: 35,
                      top: MediaQuery.of(context).size.height * 0.2),
                  child: Column(
                      children: [
                        CustomFormField(cont: _contEmail, hintText: 'Email', width: MediaQuery.of(context).size.width*0.8, valid: (val){
                    if (val!.isEmpty) return "Please Enter an Email";
                    else if (!isValidEmail(val.toString().trim())) {
                      return "Please Enter A valid Email";
                    }}),
                        CustomFormField(cont:  _contPassword, hintText:  'Password',
                          obscureText: true,
                          width: MediaQuery.of(context).size.width*0.8, valid:  (val){
                            if (val!.isEmpty) return "Please Enter Password";
                            else if (val.length < 8) {
                              return "password must be at least 8 digits";
                            }
                          }
                          ,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width*0.8-100,
                          decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                          child: TextButton(
                            onPressed: () async {
                              if(!_formKey.currentState!.validate()) return;
                              showLoading(context, true);
                              bool userHasInfo = false;
                              try {
                                await FirebaseAuth.instance.signInWithEmailAndPassword
                                  (email: _contEmail.text.toLowerCase().trim(), password: _contPassword.text);
                                userHasInfo= await FireBaseQueries.userExist(_contEmail.text.toLowerCase().trim()) ;
                              }
                              on FirebaseAuthException catch (e) {
                                showLoading(context, false);
                                showToast(firebaseErrors(e.toString()));
                                return ;
                              }
                              if (!userHasInfo) {
                                showLoading(context, false);
                                goTo(context, AddUserInfoScreen(userEmail: _contEmail.text.toLowerCase().trim()) );
                                return;
                              }
                              else {
                                await SqlDataBase.addToUsers(await FireBaseQueries.retrieve(_contEmail.text.toLowerCase().trim()));
                                UserClass user = await SqlDataBase.user(_contEmail.text.toLowerCase().trim());
                                await setPref('userEmail', _contEmail.text.toLowerCase().trim());
                                showLoading(context, false);
                                goTo(context, DaysScreen(user: user));
                              }
                            },
                            child: SizedBox(
                              width: 250,
                              child: const Text(
                                'Login',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 25),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 60,
                            child: TextButton(
                              child: Image.asset('assets/images/googleLogo.png',
                            ),
                              onPressed: ()async {
                                if (!await checkConnection()) return;
                                  bool userHasInfo = true;
                                  GoogleSignInAccount? googleUser;
                                  try {
                                    showLoading(context, true);
                                    showLoading(context, true);
                                    googleUser = await _googleSignIn.signIn();
                                    final GoogleSignInAuthentication googleSignInAuthentication =
                                    await  googleUser!.authentication;

                                    final AuthCredential credential = GoogleAuthProvider.credential(
                                      accessToken: googleSignInAuthentication.accessToken,
                                      idToken: googleSignInAuthentication.idToken,
                                    );

                                    await  FirebaseAuth.instance.signInWithCredential(credential);
                                    userHasInfo= await FireBaseQueries.userExist(googleUser!.email) ;
                                  }
                                  catch (e) {
                                    showToast(firebaseErrors(e.toString()));
                                    showLoading(context, false);
                                    showLoading(context, false);
                                    return ;
                                  }
                                  if (!userHasInfo) {
                                    goTo(context, AddUserInfoScreen(userEmail:googleUser!.email) );
                                    return;
                                  }
                                  else {
                                    await SqlDataBase.addToUsers(await FireBaseQueries.retrieve(googleUser!.email));
                                    UserClass user = await SqlDataBase.user(googleUser!.email);
                                    await setPref('userEmail', googleUser!.email);
                                    showLoading(context, false);
                                    showLoading(context, false);
                                    goTo(context, DaysScreen(user: user));
                                  }

                              }
                            ),
                          ),
                        ),

                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        if (!isValidEmail(_contEmail.text)||_contEmail.text.trim().isEmpty) {
                          showToast("Please Enter A valid Email");
                          return ;
                        }
                        else{
                          if (!await checkConnection()) return;

                          // ignore: use_build_context_synchronously
                          await showAlert(context, Text("send Reset link to your ${_contEmail.text}?"), () async {
                            showLoading(context, true);
                            showLoading(context, true);
                            try {
                              await FirebaseAuth.instance.sendPasswordResetEmail(email:_contEmail.text.trim().toLowerCase());}
                            catch (e) {
                              showToast(firebaseErrors(e.toString()));
                              showLoading(context, false);
                              showLoading(context, false);
                              return;
                            }
                            showToast("Reset Password Link Has been sent!");
                            showLoading(context, false);
                            showLoading(context, false);
                            return;
                          });

                        }
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 15,color: Colors.white),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          goTo(context, SignUpScreen());
                        },
                        child: const Text('New User? Create Account',style: TextStyle(color: Colors.white),)
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}


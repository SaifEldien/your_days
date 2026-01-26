import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../../Server/firebaseQuiries.dart';
import '../../components/widgets.dart';
import '../../const/functions.dart';
import '../../const/vars.dart';
import '../add_user_info_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  final _contEmail = TextEditingController();
  final _contVerfiy = TextEditingController();
  final _contPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
              "Create\nAccount",
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
                    children: <Widget>[
                      CustomFormField(
                          cont: _contEmail,
                          hintText: "Email",
                          width: MediaQuery.of(context).size.width * 0.8,
                          valid: (val) {
                            if (val!.trim().isEmpty) {
                              return "Please Enter an Email";}
                              else if (!isValidEmail(val.toString().trim())) {
                              return "Please Enter A valid Email";
                            }
                          }),
                      CustomFormField(
                        cont: _contPassword,
                        hintText: "Password",
                        width: MediaQuery.of(context).size.width * 0.8,
                        valid: (val) {
                          if (val!.isEmpty) {
                            return "Please Enter the password";
                          } else if (val.length < 8) {
                            return "password must be at least 8 digits";
                          }
                        },
                        obscureText: true,
                      ),
                      CustomFormField(
                        cont: _contVerfiy,
                        hintText: "Password Again",
                        width: MediaQuery.of(context).size.width * 0.8,
                        valid: (val) {
                          if (val!.isEmpty) {
                            return "Please Renter the password";
                          } else if (val != _contPassword.text) {
                            return "UnMatched Passwords!";
                          }
                        },
                        obscureText: true,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (!await checkConnection()) return;

                            showLoading(context, true);
                            FirebaseAuth user = FirebaseAuth.instance;
                            try {
                              await user.createUserWithEmailAndPassword(
                                  email: _contEmail.text.toLowerCase().trim(),
                                  password: _contPassword.text);
                              showLoading(context, false);
                              goTo(
                                  context,
                                  AddUserInfoScreen(
                                      userEmail: _contEmail.text
                                          .toLowerCase()
                                          .trim()));

                            } catch (e) {
                              showLoading(context, false);
                              showToast(firebaseErrors(e.toString()));
                              print(e.toString());
                            }

                          },
                          child: const Text(
                            'SignUp',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                          onPressed: () {
                            goTo(context, LoginScreen());
                          },
                          child: const Text(
                            'Login instead?',
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

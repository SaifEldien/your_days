// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_days/Server/firebaseQuiries.dart';
import 'package:my_days/screens/auth_screens/login_screen.dart';


import '../bloC/app_theme_bloc/app_theme_cubit.dart';
import '../components/widgets.dart';
import '../const/functions.dart';
import '../database/database_intialzing.dart';
import '../models/user.dart';
import 'days_screen.dart';

class EditUserScreen extends StatefulWidget {
  final UserClass user;
  const EditUserScreen({super.key, required this.user});
  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _contName = TextEditingController();
  final _contEmail = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String image = '';
  @override
  void initState() {
    _contName.text = widget.user.name!;
    _contEmail.text = widget.user.email!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return   Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        fit: BoxFit.fill,
        image: AssetImage(BlocProvider.of<AppThemeCubit>(context).wallpaper),
    )),
    child: Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    title: const Text(
    "Your info",
    style: TextStyle(color: Colors.white),
    ),
    leading: IconButton(
    onPressed: () {
    Navigator.pop(context);
    },
    icon: const Icon(
    Icons.arrow_back_ios,
    color: Colors.white,
    ),
    ),
    centerTitle: true,
    ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(bottom: 90),
            padding: const EdgeInsets.all(40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () async {
                      image = await pickImage(context: context);
                      print(image);
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: CircleAvatar(
                        radius: 120,
                        backgroundImage: Image.memory(showImage(
                                image == '' ? widget.user.image! : image))
                            .image,
                      ),
                    ),
                  ),
                  CustomFormField(
                      icon: Icons.person,
                      hintText: "name",
                      width: width * 0.85,
                      cont: _contName,
                      valid: (v) {
                        if (v.length>20) return "Too Long Text";
                      }),
                  CustomFormField(
                      readOnly: true,
                      icon: Icons.person,
                      hintText: "email",
                      width: width * 0.85,
                      cont: _contEmail,
                      valid: (v) {}),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: width * 0.68,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            UserClass user = UserClass(
                                widget.user.email,
                                _contName.text,
                                image == '' ? widget.user.image : image,
                                widget.user.registerDate,
                                widget.user.days);
                            showAlert(context,
                                const Text("you sure of the information? "),
                                () async {
                              showLoading(context, true);
                              await SqlDataBase.updateUser(user);
                              showLoading(context, false);
                              goTo(context, DaysScreen(user: user));
                            });
                          },
                          child: const Text("Submit"),
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (!await checkConnection()) return;
                          showAlert(context, const Text("send Reset link to your Email?"),
                              () async {
                                showLoading(context, true);
                                await FirebaseAuth.instance.sendPasswordResetEmail(email:_contEmail.text.trim().toLowerCase());
                                showToast("Reset Password Link Has been sent!");
                                showLoading(context, false);
                                return;
                              });

                        },
                        child: const Text("Rest Password"),
                      ),
                      Container(
                        height: height * 0.042,
                        color: Colors.red,
                        child: MaterialButton(
                          onPressed: () async {
                            await showAlert(context,const Text("This will delete your account\n and All your Info.\nAre you Sure?"), ()async {
                              showLoading(context, true);
                              showLoading(context, true);
                              await FireBaseQueries.deleteDataUploaded(widget.user, isUpload:false);
                              showLoading(context, false);
                              showLoading(context, false);
                              Navigator.pop(context);
                              goTo(context, LoginScreen());
                            });

                          },
                          child: const Text(
                            "Delete Account",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

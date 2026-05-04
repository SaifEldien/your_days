import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_days/core/components/widgets.dart';

import '../../../core/Server/firebase_quiries.dart';
import '../../../core/components/smart_image.dart';
import '../../../core/const/functions.dart';
import '../../../core/const/vars.dart';
import '../../data/logic/bloC/user_bloc/user_cubit.dart';
import '../../data/models/user.dart';

class AddUserInfoScreen extends StatefulWidget {
  final String userEmail;
  const AddUserInfoScreen({super.key, required this.userEmail});

  @override
  State<AddUserInfoScreen> createState() => _AddUserInfoScreenState();
}

class _AddUserInfoScreenState extends State<AddUserInfoScreen> {
  String image = '';

  final _contName = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(mainWallpaper),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Add your Info"),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Center(
                    child: TextButton(
                      onPressed: () async {
                        image = await pickImage(context: context) ?? "defualt";
                        setState(() {});
                      },
                      child: SmartImageWidget(imagePath: image),
                    ),
                  ),
                ),
                CustomFormField(
                  cont: _contName,
                  hintText: 'name',
                  width: MediaQuery.of(context).size.width * 0.8,
                  valid: (val) {
                    if (val!.isEmpty) return "Please Enter Your Name";
                    return null;
                  },
                ),

                Container(
                  margin: const EdgeInsets.only(top: 30),
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                    color: mainColor.withValues(alpha:.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        if (image == '') {
                          showToast("please select a picture");
                          return;
                        }

                        showLoading(context, true);
                        UserClass user = UserClass(
                          widget.userEmail,
                          _contName.text,
                          image,
                          formatDate(DateTime.now()),
                          [],
                        );
                        await FireBaseQueries.addUser(user);
                        context.read<UserCubit>().updateUser(user);
                        await setPref('userEmail', widget.userEmail);
                        showLoading(context, false);
                      }
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_days/components/widgets.dart';


import '../Server/firebaseQuiries.dart';
import '../const/functions.dart';
import '../const/vars.dart';
import '../database/database_intialzing.dart';
import '../models/user.dart';
import 'days_screen.dart';

class AddUserInfoScreen extends StatefulWidget {
final String userEmail;
const AddUserInfoScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<AddUserInfoScreen> createState() => _AddUserInfoScreenState();
}

class _AddUserInfoScreenState extends State<AddUserInfoScreen> {
String image='';

final _contName = TextEditingController();
final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(mainWallpaper), fit: BoxFit.cover),
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
                        image = await pickImage(context: context);
                        setState(() {
                        });
                      },
                      child: image==''? const CircleAvatar(
                        radius: 150,
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.add_a_photo,size: 120,color: Colors.white,),
                      ) : CircleAvatar(
                        backgroundImage: Image(image: Image.memory(showImage(image)).image,fit:BoxFit.cover,).image,
                        radius: 150,
                      )


                    ),
                  ),
                ),
                CustomFormField(cont: _contName,
                    hintText: 'name', width: MediaQuery.of(context).size.width*0.8
                    , valid: (val){
                    if (val!.isEmpty) return "Please Enter Your Name";
                  },),

                Container(
                  margin: const EdgeInsets.only(top: 30),
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        if (image=='') {
                          showToast("please select a picture");
                          return;
                        }

                        showLoading(context, true);
                        UserClass user = UserClass(widget.userEmail,_contName.text,image, formatDate(DateTime.now()),[]);
                        await FireBaseQueries.addUser(user);
                        await SqlDataBase.addToUsers(user);
                        await setPref('userEmail', widget.userEmail);
                        showLoading(context, false);
                        goTo(context, DaysScreen(user: user));
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

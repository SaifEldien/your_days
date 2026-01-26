import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloC/app_theme_bloc/app_theme_cubit.dart';
import '../const/functions.dart';
import '../models/user.dart';

class CustomDrawer extends StatelessWidget {
  final UserClass user;
  final List<DrawerBtn> buttons;
  const CustomDrawer({super.key, required this.user, required this.buttons});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.1,
      ),
      child: Drawer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border.all(),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(100),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: BlocProvider.of<AppThemeCubit>(context).color.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(40),
                    bottomLeft: Radius.circular(40),
                  ),
                ),
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.35,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.041,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          goTo(
                              context,
                              Image(
                                image:
                                Image.memory(showImage(user.image!)).image,
                              ),
                              add: true);
                        },
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.height * 0.12,
                          backgroundImage: Image(
                            image: Image.memory(showImage(user.image!)).image,
                            fit: BoxFit.cover,
                          ).image,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Text(
                        user.name!,
                        style:
                        const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: buttons,
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    '©S. V 3.21.',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerBtn extends StatelessWidget {
  final icon, text, function;
  const DrawerBtn(this.icon, this.text, this.function, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Tooltip(
        message: text,
        child: TextButton(
            style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5)),
            onPressed: () async {
              function();
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      icon,
                      size: 35,
                        color: BlocProvider.of<AppThemeCubit>(context).color == Color(0xff000000)? Colors.white : BlocProvider.of<AppThemeCubit>(context).color


                    ),
                  ),
                  Center(
                    child: Text(
                      '  $text',
                      style:  TextStyle(
                        fontSize: 19,
                        color:BlocProvider.of<AppThemeCubit>(context).color == Color(0xff000000)? Colors.white : BlocProvider.of<AppThemeCubit>(context).color


                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}


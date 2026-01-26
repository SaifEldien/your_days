import 'package:flutter/material.dart';

import '../const/vars.dart';

class FAB extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget form;
  final Color color;
  final Function? function;
  const FAB(
      {Key? key,
      required this.text,
      required this.icon,
      required this.color,
      required this.form, this.function})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).viewInsets.bottom != 0.0 ? 0 : 120,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          SizedBox(
            height: 80,
            width: 80,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              elevation: 10,
              backgroundColor: color.withOpacity(opacity),
              onPressed: () async {
                if (function!=null) await function!();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return form;
                    });
              },
              child: Icon(icon, size: 35, color: Colors.white),
              // elevation: 5.0,
            ),
          ),
        ],
      ),
    );
  }
}

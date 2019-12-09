import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mpaisa_app/bloc/LoginBloc.dart';
import 'package:mpaisa_app/pref/PrefsSingleton.dart';
import 'package:mpaisa_app/ui/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/BlocBase.dart';

void main() async {

  PrefsSingleton.prefs = await SharedPreferences.getInstance();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MaterialApp(
      title: "ePaisa",
      home: BlocProvider(
        child: LoginPage(),
        bloc: LoginBloc(),
      ),
    ));
  });
}

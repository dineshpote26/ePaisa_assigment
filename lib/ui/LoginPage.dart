import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mpaisa_app/bloc/BlocBase.dart';
import 'package:mpaisa_app/bloc/HomeBloc.dart';
import 'package:mpaisa_app/bloc/LoginBloc.dart';
import 'package:mpaisa_app/ui/HomePage.dart';
import 'package:mpaisa_app/util/AppConstant.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  LoginBloc loginBloc;

  StreamSubscription<String> _loginStatusSubscription;

  @override
  void initState() {
    super.initState();
    loginBloc = BlocProvider.of<LoginBloc>(context);
    _loginStatusSubscription = loginBloc.loginStatus.listen((status) {
      handleSubscription(status);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  color: Colors.blue,
                  width: double.infinity,
                  height: double.infinity / 2,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: IconButton(
                      icon: Icon(
                        FontAwesomeIcons.facebook,
                        color: Colors.white,
                      ),
                      iconSize: 80,
                      onPressed: () {
                        loginBloc.initiateFacebookLogin();
                      },
                    ),
                  ),
                ),
              )),
          Expanded(
            flex: 1,
            child: Container(
              height: double.infinity / 2,
              color: Colors.deepOrange,
              alignment: Alignment.bottomCenter,
              child: FutureBuilder<bool>(
                future: loginBloc.isActive(),
                builder: (_, snapshot) {
                  if (snapshot.hasData && snapshot.data) {
                    return IconButton(
                      icon: Icon(
                        Icons.fingerprint,
                        color: Colors.white,
                      ),
                      iconSize: 80,
                      onPressed: (){
                        loginBloc.touchIdAuth();
                      },
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  //navigate to home screen
  changeTheHomePage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
            BlocProvider(child: HomePage(), bloc: HomeBloc())));
  }

  //handle various error msg
  void handleSubscription(String status) {
    if (AppConstant.FAILURE.contains(status)) {
      showMessage(AppConstant.ERROR_FAILURE);
    } else if (AppConstant.LOGGEDIN.contains(status)) {
      changeTheHomePage(context);
    } else if (AppConstant.CACLEBYUSER.contains(status)) {
      showMessage(AppConstant.ERROR_CANCLE);
    }
  }

  //toast for msg
  void showMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

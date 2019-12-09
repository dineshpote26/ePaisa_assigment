import 'dart:async';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mpaisa_app/bloc/BlocBase.dart';
import 'package:mpaisa_app/pref/PrefsSingleton.dart';
import 'package:mpaisa_app/repository/LoginFBRepo.dart';
import 'package:mpaisa_app/util/AppConstant.dart';

import '../Result.dart';

class LoginBloc extends BlocBase {

  final LocalAuthentication _auth = LocalAuthentication();

  var facebookLogin = FacebookLogin();

  StreamController<bool> _FBstreamController = StreamController<bool>.broadcast();
  Stream<bool> get isFBSucess => _FBstreamController.stream;

  StreamController<String> _loginStatuscontroller = StreamController<String>.broadcast();
  Stream<String> get loginStatus => _loginStatuscontroller.stream;

  final _loginFBRepo = LoginFBRepository();

  // check if device  capable of biometrics
  Future<bool> isActive() async {
    bool canCheckBiometrics = await _auth.canCheckBiometrics;

    if (!canCheckBiometrics) {
      return false;
    }

    List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();

    return availableBiometrics.contains(BiometricType.fingerprint);
  }

  //check authentication here
  Future<bool> auth() async {
    try {
      return await _auth.authenticateWithBiometrics(
        localizedReason: 'Scan Your fingerprint to authenticate',
        useErrorDialogs: true,
        stickyAuth: false,
      );
    } catch (e) {
      print("error" + e.toString());
      return false;
    }
  }

  //facebook login
  void initiateFacebookLogin() async {
    facebookLogin = FacebookLogin();
    var facebookLoginResult =
    await facebookLogin.logInWithReadPermissions(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        _loginStatuscontroller.add(AppConstant.FAILURE);
        break;
      case FacebookLoginStatus.cancelledByUser:
        _loginStatuscontroller.add(AppConstant.CACLEBYUSER);
        print("CancelledByUser");
        break;
      case FacebookLoginStatus.loggedIn:
        _loginStatuscontroller.add(AppConstant.LOGGEDIN);
        print("LoggedIn");
        //final result = await facebookLogin.logInWithReadPermissions(['email']);
        //final token = facebookLoginResult.accessToken.token;
        //Result profileResult = await _loginFBRepo.getFBprofileInfo(token);
        PrefsSingleton.prefs.setInt(AppConstant.LOGINTYPE, 1);
        PrefsSingleton.prefs.setBool(AppConstant.SUCESS, true);
        //PrefsSingleton.setFBResultData(profileResult);
        //changeTheHomePage(context);
        break;
    }
  }
  //touch id auth
  void touchIdAuth() async {
    bool success = await auth();
    if (success) {
      //redirect to home for example.
      PrefsSingleton.prefs.setBool(AppConstant.SUCESS, true);
      PrefsSingleton.prefs.setInt(AppConstant.LOGINTYPE, 2);
      _loginStatuscontroller.add(AppConstant.LOGGEDIN);
      print('fingerprint auth !!!!');
    } else {
      _loginStatuscontroller.add(AppConstant.FAILURE);
      print('fingerprint auth failed !!!!');
    }
  }

  @override
  void dispose() {
    _FBstreamController.close();
    _loginStatuscontroller.close();
  }
}

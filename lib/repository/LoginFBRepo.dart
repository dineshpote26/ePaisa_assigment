import 'package:flutter/material.dart';
import 'package:mpaisa_app/Result.dart';
import 'package:mpaisa_app/network/LoginProvider.dart';

class LoginFBRepository {

  final loginFbProvider = LoginProvider();

  Future<Result> getFBprofileInfo(var token) async {
    Result result;

    try {
      result = await loginFbProvider.getFacebookProfile(token);
    } catch (e) {
      debugPrint(e.toString());
    }

    return result;
  }
}

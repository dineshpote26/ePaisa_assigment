import 'package:flutter/material.dart';
import 'package:mpaisa_app/Result.dart';
import 'package:mpaisa_app/network/BaseApi.dart';

class LoginProvider extends BaseApi {
  Future<Result> getFacebookProfile(var token) async {
    Result result;
    try {
      var url =
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}';
      final graphResponse = await getHttp(url);
      return Result.fromJson(graphResponse);
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }
}

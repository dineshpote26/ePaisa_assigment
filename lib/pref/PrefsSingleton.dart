import 'package:mpaisa_app/Result.dart';
import 'package:mpaisa_app/util/AppConstant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsSingleton {
  static final PrefsSingleton _singleton = PrefsSingleton._internal();

  static SharedPreferences prefs;

  factory PrefsSingleton() {
    return _singleton;
  }

  PrefsSingleton._internal();

  static void setFBResultData(Result result) {
    prefs.setString(AppConstant.NAME, result.name);
    prefs.setString(AppConstant.FNAME, result.first_name);
    prefs.setString(AppConstant.LNAME, result.last_name);
    prefs.setString(AppConstant.EMAIL, result.email);
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class BaseApi{

  static const int TIMEOUT_SECONDS = 30;

  Future<dynamic> getHttp(String url) async {
    final response = await http.get(url).timeout(
        const Duration(seconds: TIMEOUT_SECONDS),
        onTimeout: _onTimeout);

    final String res = response.body;
    final int statusCode = response.statusCode;

    if (res == null || statusCode != 200)
      throw new Exception(
          "Error fetching data from server statusCode: $statusCode");

    final responseJson = json.decode(res);

    return responseJson;
  }

  Future<http.Response> _onTimeout() {
    throw new SocketException("Timeout during request");
  }

}
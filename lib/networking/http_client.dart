import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:your_key/networking/network_check.dart';

enum RequestType { GET, POST }

class RequestTypeNotFoundException implements Exception {
  String cause;
  RequestTypeNotFoundException(this.cause);
}

class Nothing {
  Nothing._();
}

class HttpClient {

  HttpClient._privateConstructor();

  static final HttpClient _instance = HttpClient._privateConstructor();

  factory HttpClient() {
    return _instance;
  }

  final _httpClient = http.Client();
  final NetworkCheck _networkCheck = NetworkCheck();

  Future<dynamic> request(RequestType requestType, String domain, String methodPath, Map<String, String> headers,  {dynamic parameter = Nothing}) async {

    bool isInternet = await _networkCheck.check();
    if (isInternet != null && isInternet) {
      switch (requestType) {
        case RequestType.GET:
          var uri = Uri.https(domain, methodPath, parameter);
          return _httpClient.get(uri, headers: headers);
        case RequestType.POST:
          var uri = Uri.https(domain, methodPath);
          return _httpClient.post(uri,
              headers: headers, body: json.encode(parameter));
        default:
          return throw RequestTypeNotFoundException(
              "The HTTP request mentioned is not found");
      }
    } else {
      return throw RequestTypeNotFoundException("network_connection_failed");
    }
  }
}
import 'package:connectivity/connectivity.dart';

class NetworkCheck {

  NetworkCheck._privateConstructor();

  static final NetworkCheck _instance = NetworkCheck._privateConstructor();

  factory NetworkCheck() {
    return _instance;
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  dynamic checkInternet(Function func) {
    check().then((value) {
      if (value != null && value) {
        func(true);
      }
      else{
        func(false);
      }
    });
  }
}
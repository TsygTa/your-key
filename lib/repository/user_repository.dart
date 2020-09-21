import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_key/model/auth_response.dart';
import 'package:your_key/networking/network_service.dart';

class UserRepository {
  final NetworkService _networkService;

  UserRepository._privateConstructor(this._networkService) : assert(_networkService != null) ;

  static final UserRepository _instance = UserRepository._privateConstructor(NetworkService());

  factory UserRepository() {
    return _instance;
  }

  static final String _loginKey = "LOGIN_KEY";
  static final String _passwordKey = "PASSWORD_KEY";

  final _secureStorage = FlutterSecureStorage();

// Authentication methods

  Future<AuthResponse> authenticate(String login, String password) async {
    AuthResponse authResponse = await _networkService.authRequest(login, password);
    return authResponse;
  }

  Future<void> deleteAuthData() async {
    await _secureStorage.deleteAll();
    return;
  }

  Future<void> persistAuthData(String login, String password) async {

    await _secureStorage.write(key: _loginKey, value: login);
    await _secureStorage.write(key: _passwordKey, value: password);
    return;
  }

  Future<String> getLogin() async {
    String login = await _secureStorage.read(key: _loginKey);
    return login;
  }

  Future<String> getPassword() async {
    String password = await _secureStorage.read(key: _passwordKey);
    return password;
  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
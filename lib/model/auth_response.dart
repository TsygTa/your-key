import 'dart:convert';

import 'package:your_key/model/user.dart';

class AuthResponse {
  final bool status;
  final User user;
  final String error;

  AuthResponse(this.status, {this.user, this.error});

  factory AuthResponse.fromRawJson(String str) => (
      AuthResponse.fromJson(json.decode(str)));

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
      json["status"] as bool,
      user: (json["status"] as bool) ? User.fromJson(json["data"]) : null,
      error: json["error"] as String
  );
}
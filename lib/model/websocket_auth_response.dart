import 'dart:convert';

class WebSocketAuthResponse {
  final bool status;
  final String type;
  final String message;

  WebSocketAuthResponse(this.status, {this.type, this.message});

  factory WebSocketAuthResponse.fromRawJson(String str) => (
      WebSocketAuthResponse.fromJson(json.decode(str)));

  factory WebSocketAuthResponse.fromJson(Map<String, dynamic> json) => WebSocketAuthResponse(
      json["success"] as bool,
      type: json["type"] as String,
      message: json["message"] as String
  );

  bool get isSuccess => (type == 'new_client' && status);
}
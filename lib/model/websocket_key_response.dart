import 'dart:convert';

class WebSocketKeyResponse {
  final bool status;
  final String webSocketKey;
  final String error;

  WebSocketKeyResponse(this.status, {this.webSocketKey, this.error});

  factory WebSocketKeyResponse.fromRawJson(String str) => (
      WebSocketKeyResponse.fromJson(json.decode(str)));

  factory WebSocketKeyResponse.fromJson(Map<String, dynamic> json) => WebSocketKeyResponse(
      json["status"] as bool,
      webSocketKey: (json["status"] as bool) ? json["data"]["webSocketKey"] : null,
      error: json["error"] as String
  );
}
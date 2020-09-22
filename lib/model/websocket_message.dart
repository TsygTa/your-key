import 'dart:convert';

import 'package:your_key/model/device_state.dart';

enum WSMessageType { auth, ping, packet }

class WebSocketMessage {

  final String type;
  final bool success;
  final String data;
  final DeviceState deviceState;

  WebSocketMessage(this.type, {this.success, this.data, this.deviceState});

  factory WebSocketMessage.fromRawJson(String str) => (
      WebSocketMessage.fromJson(json.decode(str)));

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) => WebSocketMessage(
      json['type'] as String,
      success: json['type'] == 'result' ? json['success'] as bool : null,
      data: json['type'] == 'ping' ? json['data'] as String : null,
      deviceState: json['type'] == 'device_packet' ? DeviceState.fromJson(json['data']) : null
  );

  WSMessageType get messageType {
    if(type == 'result') return WSMessageType.auth;
    if(type == 'ping') return WSMessageType.ping;
    if(type == 'device_packet') return WSMessageType.packet;
  }
  bool get isConnected => success;

  String get getData => data ?? '';
}
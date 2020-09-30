import 'dart:convert';

enum WSState {connected, sendCommandError, commandIsSent, commandIsDone}

class WebSocketRCVMessage {

  final String type;
  final bool status;
  final String data;
  final String error;
  final int deviceId;
  final int commandId;
  final String sendTime;

  WebSocketRCVMessage(this.type, {this.status, this.data, this.error, this.deviceId, this.commandId, this.sendTime});

  factory WebSocketRCVMessage.fromRawJson(String str) => (
      WebSocketRCVMessage.fromJson(json.decode(str)));

  factory WebSocketRCVMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketRCVMessage(
      json['type'] as String,
      status: json['status'] as bool,
      data: json['data'] as String,
      error: json['error'] as String,
      deviceId: json['device_id'] as int,
      commandId: json['command_id'] as int,
      sendTime: json['response_time'] as String
    );
  }

  WSState get messageType {
    if(type == 'ws_response' && data == "Authorisation successful" && status) return WSState.connected;
    if(type == 'ws_response' && data == "Error send command" && !status) return WSState.sendCommandError;
    if(type == 'ws_response' && status && commandId != null) return WSState.commandIsSent;
    if(type == 'device_answer' && status && commandId != null) return WSState.commandIsDone;
  }

  String get getError => error ?? '';
}
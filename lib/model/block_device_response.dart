import 'dart:convert';

class BlockDeviceResponse {
  final bool status;
  final String error;

  BlockDeviceResponse(this.status, {this.error});

  factory BlockDeviceResponse.fromRawJson(String str) => (
      BlockDeviceResponse.fromJson(json.decode(str)));

  factory BlockDeviceResponse.fromJson(Map<String, dynamic> json) {
    return BlockDeviceResponse(
        json["status"] as bool,
        error: json["error"] as String
    );
  }
}
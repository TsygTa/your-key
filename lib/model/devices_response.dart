import 'dart:convert';

import 'device.dart';

class DevicesResponse {
  final bool status;
  final String error;

  List<Device> devices = [];

  DevicesResponse(this.status, {this.error});

  factory DevicesResponse.fromRawJson(String str) => (
      DevicesResponse.fromJson(json.decode(str)));

  factory DevicesResponse.fromJson(Map<String, dynamic> json) {

    DevicesResponse response = DevicesResponse(
        json["status"] as bool,
        error: json["error"] as String
    );

    if (response.status) {

      var list = json["data"];

      for(var item in list) {
        response.devices.add(Device.fromJson(item));
      }
    }
    return response;
  }
}
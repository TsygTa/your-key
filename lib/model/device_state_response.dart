import 'dart:convert';

import 'device_state.dart';

class DeviceStateResponse {

  final List<DeviceState> deviceStates;

  DeviceStateResponse({this.deviceStates});

  factory DeviceStateResponse.fromRawJson(String str) => (
      DeviceStateResponse.fromJson(json.decode(str)));

  factory DeviceStateResponse.fromJson(List json) => DeviceStateResponse(
      deviceStates: _parseStates(json)
  );
}

List<DeviceState> _parseStates(List array) {
  if(array == null) {
    return null;
  } else {
    List<DeviceState> states = [];

    array.forEach((element) {
      states.add(DeviceState.fromJson(element));
    });
    return states;
  }
}
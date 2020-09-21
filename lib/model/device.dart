
import 'package:your_key/model/device_state.dart';

class Device {

  final int id;
  bool isFinanceBlock;

  String mark;
  String model;
  String stateNumber;
  String deviceType;

  DeviceState state;

  Device(this.id, {this.isFinanceBlock, this.mark, this.model, this.stateNumber, this.deviceType});

  factory Device.fromJson(Map<String, dynamic> json) => Device(
      int.parse(json["id"] as String),
      isFinanceBlock: (int.parse(json["finance_block"] as String) == 0 ? false : true),
      mark: json["marka"] as String,
      model: json["model"] as String,
      stateNumber: json["gosnum"] as String,
      deviceType: json["type_name"] as String
  );

  String getTitle() {
    return "$mark $model $stateNumber";
  }
}
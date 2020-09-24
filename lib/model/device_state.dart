import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

enum DeviceBlockState {
  blocked,
  unblocked,
  processing,
  not_available,
  failure
}

class DeviceState extends Equatable {

  final int deviceId;
  final int cnt;
  final int packetTime;
  final double latitude;
  final double longitude;
  final int csq;
  final double altitude;
  final int satellites;
  final bool isBlock;
  final int paramO1;

  DeviceState(this.cnt, this.deviceId, this.packetTime, {this.latitude, this.longitude, this.csq, this.altitude, this.satellites, this.isBlock, this.paramO1});

  factory DeviceState.fromJson(Map<String, dynamic> json) {

    DeviceState state = DeviceState(
        json["cnt"] as int,
        json["device_id"] as int,
        json["packet_time"] as int,
        latitude: json["lat"] is double ? json["lat"] : (json["lat"] as int).toDouble(),
        longitude: json["lng"] is double ? json["lng"] : (json["lng"] as int).toDouble(),
        csq: json["csq"] as int,
        satellites: json["sat"] as int,
        altitude: json["alt"] is double ? json["alt"] : (json["alt"] as int).toDouble(),
        paramO1: json["o1b"] as int,
        isBlock: (json["blocking"] as bool) != null ? (json["blocking"] as bool) : (json["o1b"] as int) == 1,
    );

    return state;
  }
  String get packetTimeString {
    return DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.fromMillisecondsSinceEpoch(packetTime * 1000));
  }

  @override
  // TODO: implement props
  List<Object> get props => [cnt, deviceId, packetTime];

  DeviceBlockState get deviceBlockState => isBlock != null ?
  (paramO1 == 1 ? DeviceBlockState.blocked
      : DeviceBlockState.unblocked)
      : DeviceBlockState.not_available;
}
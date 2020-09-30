import 'dart:io' show Cookie, Platform;
import 'package:device_info/device_info.dart';
import 'package:your_key/model/auth_response.dart';
import 'package:your_key/model/block_device_response.dart';
import 'package:your_key/model/device_state_response.dart';
import 'package:your_key/model/devices_response.dart';
import 'package:your_key/model/user.dart';
import 'package:your_key/model/websocket_auth_response.dart';
import 'package:your_key/model/websocket_key_response.dart';
import 'package:your_key/networking/http_client.dart';

class NetworkService {
  final _httpClient = HttpClient();

  NetworkService._privateConstructor();

  static final NetworkService _instance = NetworkService._privateConstructor();

  factory NetworkService() {
    return _instance;
  }

  static const String apiKGK = "api.kgk-global.com";
  static const String packApi = "packapi.kgk-global.com";
  static const String rcv2Api = "rcv2.kgk-global.com:18234";

  static const String authMethod = "/api2/mobile/authorize";
  static const String getOservablesMethod = "/api2/mobile/getdeviceslist";
  static const String blockEngineMethod = "/api2/mobile/cmdtoggleblockengine";
  static const String getWebSocketKeyMethod = "/api2/mobile/getwebsocketkey";
  static const String getWebSocketAuthMethod = "/auth";

  static const String getOservableStateMethod = "/get_state";

  Cookie _cookie;
  int _userId;
  String _webSocketKey;
  User user;

  /// Authentication request

  Future<AuthResponse> authRequest(String login, String password) async {

    String release = "Not defined";
    String os = "Not defined";

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      release = androidInfo.version.release;
      os = "Android";
    }

    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      release = iosInfo.systemVersion;
      os = "IOS";
    }

    Map<String, String> params = {
      "login": login,
      "password": password,
      "mob_platform": os,
      "mob_os_version": release
    };

    Map<String, String> headers = {"Content-Type": "application/json"};

    final response = await _httpClient.request(RequestType.GET, apiKGK, authMethod, headers, parameter: params);
    if (response.statusCode == 200) {
      this._cookie = Cookie.fromSetCookieValue(response.headers["set-cookie"]);

      AuthResponse authResponse = AuthResponse.fromRawJson(response.body);
      if(authResponse.user != null) {
        this._userId = authResponse.user.userId;
        this.user = User(authResponse.user.userId, login: login, password: password);
      }
      return authResponse;
    } else {
      throw Exception('failed_authenticate');
    }
  }

  /// Objects list request

  Future<DevicesResponse> getDevicesRequest() async {

    Map<String, String> params = {
      "all": "1"
    };

    Map<String, String> headers = {"Content-Type": "application/json"};
    headers.addAll({"Cookie": _cookie.toString()});

    final response = await _httpClient.request(RequestType.GET, apiKGK, getOservablesMethod, headers, parameter: params);
    if (response.statusCode == 200) {
      return DevicesResponse.fromRawJson(response.body);
    } else {
      throw Exception('failed_get_devices');
    }
  }

  Future<DeviceStateResponse> getObservableStateRequest(List<int> deviceIds) async {

    Map<String, String> params = {
      "device_id": deviceIds.map((e) => e.toString()).join(",")
    };

    Map<String, String> headers = {"Content-Type": "application/json"};

    final response = await _httpClient.request(RequestType.GET, packApi, getOservableStateMethod, headers, parameter: params);
    switch(response.statusCode) {
      case 200:
        return DeviceStateResponse.fromRawJson(response.body);
      default:
        throw Exception('failed_get_device_state');
    }
  }

  /// Block Request
  Future<BlockDeviceResponse> blockDeviceRequest(int deviceId) async {

    Map<String, String> params = {
      "device": deviceId.toString()
    };

    Map<String, String> headers = {"Content-Type": "application/json"};
    headers.addAll({"Cookie": _cookie.toString()});

    final response = await _httpClient.request(RequestType.GET, apiKGK, blockEngineMethod, headers, parameter: params);
    switch(response.statusCode) {
      case 200:
        return BlockDeviceResponse.fromRawJson(response.body);
      default:
        throw Exception('failed_block_device');
    }
  }

  /// WebSocket Key Request
  Future<WebSocketKeyResponse> getWebSocketKeyRequest() async {

    Map<String, String> params = {
      "ws2": "1"
    };

    Map<String, String> headers = {"Content-Type": "application/json"};
    headers.addAll({"Cookie": _cookie.toString()});

    final response = await _httpClient.request(RequestType.GET, apiKGK, getWebSocketKeyMethod, headers, parameter: params);
    if (response.statusCode == 200) {
      WebSocketKeyResponse keyResponse = WebSocketKeyResponse.fromRawJson(response.body);
      _webSocketKey = keyResponse.webSocketKey;
      return WebSocketKeyResponse.fromRawJson(response.body);
    } else {
      throw Exception('failed_websocket_key');
    }
  }

  /// WebSocket Auth Request
  Future<WebSocketAuthResponse> webSocketAuthRequest() async {

    Map<String, Object> params = {
      "type": "new_client",
      "data": {
        "user_id": _userId,
        "key": _webSocketKey
      }
    };

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "*/*",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
      "cache-control": "no-cache"
    };

    final response = await _httpClient.request(RequestType.POST, rcv2Api, getWebSocketAuthMethod, headers, parameter: params);
    if (response.statusCode == 200) {
      return WebSocketAuthResponse.fromRawJson(response.body);
    } else {
      throw Exception('failed_websocket_auth');
    }
  }
}
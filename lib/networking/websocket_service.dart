import 'dart:async';
import 'dart:convert';

import 'package:your_key/model/device_state.dart';
import 'package:your_key/model/websocket_auth_response.dart';
import 'package:your_key/model/websocket_key_response.dart';
import 'package:your_key/model/websocket_message.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'network_service.dart';

class WebSocketService {
  static const String webSocketAddress = "wss://rcv2.kgk-global.com:18234";
  static const int WSTimeOutSeconds = 30;
  NetworkService _networkService;
  StreamController<DeviceState> _streamController;

  WebSocketService._privateConstructor();

  static final WebSocketService _instance = WebSocketService._privateConstructor();

  factory WebSocketService(NetworkService networkService, StreamController<DeviceState> streamController) {
    _instance._networkService = networkService;
    _instance._streamController = streamController;
    return _instance;
  }


  WebSocketChannel _channel;
  StreamSubscription _webSocketSubscription;

  Future<void> connect() async {
    if (_channel == null) {
      _webSocketSubscription?.cancel();
      await _tryToConnect();
    } else {
      _reconnect();
    }
  }

  void close() {
    _webSocketSubscription?.cancel();
    _channel?.sink?.close();
    _channel = null;
  }

  Future<void> _reconnect() async {
    close();
    Future.delayed(Duration(seconds: WSTimeOutSeconds), () {
      _tryToConnect();
    });
  }

  Future<void> _tryToConnect() async {

    try {
      WebSocketKeyResponse keyResponse = await _networkService.getWebSocketKeyRequest();

      var webSocketKey = keyResponse.webSocketKey;
      if(webSocketKey != null) {
        WebSocketAuthResponse authResponse = await _networkService.webSocketAuthRequest();
        if(authResponse.isSuccess) {
          _channel = IOWebSocketChannel.connect(webSocketAddress);

          Map<String, dynamic> authMessage = {
            "type": "auth",
            "data": {
              "key": webSocketKey
            }
          };
          _channel.sink.add(json.encode(authMessage));
          _webSocketSubscription?.cancel();
          _webSocketSubscription = _channel.stream.listen(
                  (message) {
                if(message is String) {
                  _parseMessage(message);
                }
              },
              onDone: () {},
              onError: (error) {
                print("WS Error: $error");
                _reconnect();
              },
              cancelOnError: false);
        } else {
          print("WS AuthRequest Error: ${authResponse.message}");
          _reconnect();
        }
      } else {
        print("WS KeyRequest Error: ${keyResponse.error}");
        _reconnect();
      }
    } catch(error) {
      print("WS Error: $error");
      _reconnect();
    }
  }

  _parseMessage(String messageString) {

    WebSocketMessage message = WebSocketMessage.fromRawJson(messageString);
    switch(message.messageType) {

      case WSMessageType.auth:
        if(message.isConnected) {
          print("WS is connected");
        }
        break;
      case WSMessageType.ping:
        if(message.getData == 'ping') {
          Map<String, String> pong = {
            "type": "ping",
            "data": "pong"
          };
          _channel.sink.add(json.encode(pong));
          print("WS ping");
        }
        break;
      case WSMessageType.packet:
        DeviceState observableState = message.deviceState;
        print("WS deviceId: ${observableState.deviceId}");
        _streamController.add(observableState);
        break;
    }
  }
}
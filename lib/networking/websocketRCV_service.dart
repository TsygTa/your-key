import 'dart:async';
import 'dart:convert';

import 'package:your_key/model/user.dart';
import 'package:your_key/model/websocketRCV_message.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'network_service.dart';

class WebSocketRCVService {
  static const String webSocketAddress = "wss://rcv2.kgk-global.com:8088/ws";
  static const int WSTimeOutSeconds = 30;
  NetworkService _networkService;
  StreamController<WebSocketRCVMessage> _streamController;

  WebSocketRCVService._privateConstructor();

  static final WebSocketRCVService _instance = WebSocketRCVService._privateConstructor();

  factory WebSocketRCVService(NetworkService networkService, StreamController<WebSocketRCVMessage> streamController) {
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

    User user = _networkService.user;

    try {
      _channel = IOWebSocketChannel.connect(webSocketAddress);

      Map<String, dynamic> authMessage = {
        "type": "auth",
        "data": "${user.login}:${user.password}"
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
    } catch(error) {
      print("WS Error: $error");
      _reconnect();
    }
  }

  _parseMessage(String messageString) {

    WebSocketRCVMessage message = WebSocketRCVMessage.fromRawJson(messageString);
    switch(message.messageType) {
      case WSState.connected:
        print("WS is connected");
        _streamController.add(message);
        break;
      case WSState.sendCommandError:
        _streamController.add(message);
        break;
      case WSState.commandIsSent:
        _streamController.add(message);
        break;
      case WSState.commandIsDone:
        _streamController.add(message);
        break;
    }
  }

  void sendCommand(int deviceId) {
    Map<String, dynamic> command = {
      "type": "command",
      "device_id": deviceId,
      "data": "P23011"
    };
    _channel.sink.add(json.encode(command));
  }
}
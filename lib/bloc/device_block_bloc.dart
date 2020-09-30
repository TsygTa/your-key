import 'dart:async';

import "package:flutter/material.dart";
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/localizations/localizations.dart';
import 'package:your_key/model/device_state.dart';
import 'package:your_key/model/websocketRCV_message.dart';
import 'package:your_key/networking/http_client.dart';
import 'package:your_key/networking/websocketRCV_service.dart';
import 'package:your_key/ui/alert_window.dart';

import '../main.dart';

/// Events

//Login Events
abstract class BlockEvent extends Equatable {
  const BlockEvent();
}

class LockPressed extends BlockEvent {
  final int deviceId;

  const LockPressed(this.deviceId);

  @override
  List<Object> get props => [deviceId];

  @override
  String toString() =>
      'LockPressed { device: $deviceId }';
}

class WebSocketConnected extends BlockEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];

  @override
  String toString() => 'WebSocketConnected';
}

class CommandSent extends BlockEvent {
  final int deviceId;
  final int commandId;

  const CommandSent(this.deviceId, this.commandId);

  @override
  List<Object> get props => [deviceId, commandId];

  @override
  String toString() =>
      'CommandSent { device: $deviceId, command: $commandId }';
}

class CommandDone extends BlockEvent {
  final int deviceId;
  final int commandId;
  final String data;
  const CommandDone(this.deviceId, this.commandId, this.data);

  @override
  List<Object> get props => [deviceId, commandId, data];

  @override
  String toString() =>
      'CommandDone { device: $deviceId, command: $commandId, data: $data }';
}

class FailureLock extends BlockEvent {
  final String error;

  const FailureLock(this.error);

  @override
  List<Object> get props => [error];

  @override
  String toString() =>
      'Failure { error: $error}';
}


/// Engine Block Bloc

class DeviceBlockBloc extends Bloc<BlockEvent, DeviceBlockState> {

  static const int engineBlockTimeoutSeconds = 30;

  final WebSocketRCVService _webSocketRCVService;
  final BuildContext _context;

  StreamSubscription _webSocketServiceSubscription;
  bool isWaitForLock = false;
  int _deviceId;
  int _commandId;

  DeviceBlockBloc(this._context, this._webSocketRCVService) : super(DeviceBlockState.initial) {

    _webSocketServiceSubscription?.cancel();

    _webSocketServiceSubscription = webSocketStreamController.stream.listen((message) {
      switch(message.messageType) {
        case WSState.connected:
          add(WebSocketConnected());
          break;
        case WSState.commandIsSent:
          if(message.deviceId == _deviceId) {
            _commandId = message.commandId;
            add(CommandSent(message.deviceId, message.commandId));
          }
          break;
        case WSState.commandIsDone:
          if(isWaitForLock && message.deviceId == _deviceId && message.commandId == _commandId) {
            print('WS BlockEvent.doneBlock');
            add(CommandDone(message.deviceId, message.commandId, message.data));
          }
          break;
        case WSState.sendCommandError:
          add(FailureLock(message.error));
          break;
      }
    });
  }

  @override
  Stream<DeviceBlockState> mapEventToState(BlockEvent event) async* {

    if(event is LockPressed) {
      yield DeviceBlockState.processing;
      _deviceId = event.deviceId;
      try {
        _webSocketRCVService.connect();
      } catch(error) {
        _webSocketRCVService.close();
        if(error is RequestTypeNotFoundException) {
          AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('error'),
              AppLocalizations.of(_context).translate(error.cause)).show();
          yield DeviceBlockState.failure;
        } else {
          AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('error'),
              (error.toString() ?? "") + " " + AppLocalizations.of(_context).translate("command_not_sent")).show();
          yield DeviceBlockState.failure;
        }
      }
    }

    if(event is WebSocketConnected) {
      bool status = _sendWSCommand();
      if(!status) {
        _webSocketRCVService.close();
        yield DeviceBlockState.failure;
      }
      yield DeviceBlockState.processing;
    }

    if(event is CommandSent) {
      yield DeviceBlockState.processing;

      AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('block_device_title'),
          AppLocalizations.of(_context).translate('block_device_sent'), heightDivider: 6).show();
      Future.delayed(Duration(seconds: engineBlockTimeoutSeconds), () {
        print('Timeout1');
        if(isWaitForLock) {
          print('Timeout2 BlockEvent.doneBlock');
          add(CommandDone(event.deviceId, event.commandId, null));
          AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('error'),
              AppLocalizations.of(_context).translate("possibly_command_not_sent")).show();
        }
      });
    }

    if(event is CommandDone) {
        isWaitForLock = false;
        print('Bloc: DeviceBlockState.blocked');
        _webSocketRCVService.close();
        if(event.data == null) {
          AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('error'),
              AppLocalizations.of(_context).translate("possibly_command_not_sent")).show();
        } else {
          AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('block_device_title'),
              AppLocalizations.of(_context).translate("block_device_sent_done"),
          heightDivider: 6, isSpinner: false).show();
        }
        yield DeviceBlockState.blocked;
    }

    if(event is FailureLock) {
      _webSocketRCVService.close();
      isWaitForLock = false;
      AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('error'),
          AppLocalizations.of(_context).translate("command_not_sent") + ': ' +  AppLocalizations.of(_context).translate(event.error)).show();
      yield DeviceBlockState.blocked;
    }
  }

  @override
  close() async {
    _webSocketServiceSubscription?.cancel();
    _webSocketRCVService.close();
    super.close();
  }

  bool _sendWSCommand() {
    try {
      isWaitForLock = true;
      webSocketService.sendCommand(_deviceId);
      return true;
    } catch(error) {
      AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('error'),
          (error.toString() ?? "") + " " + AppLocalizations.of(_context).translate("command_not_sent")).show();
    }
    return false;
  }
}
import 'dart:async';

import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/localizations/localizations.dart';
import 'package:your_key/model/block_device_response.dart';
import 'package:your_key/model/device.dart';
import 'package:your_key/model/device_state.dart';
import 'package:your_key/networking/network_service.dart';
import 'package:your_key/ui/alert_window.dart';

import '../main.dart';

/// Events

enum BlockEvent {
  block,
  unblock,
  doneBlock,
  doneUnblock
}

/// Engine Block Bloc

class DeviceBlockBloc extends Bloc<BlockEvent, DeviceBlockState> {

  static const int engineBlockTimeoutSeconds = 30;

  final Device _device;
  final NetworkService _networkService;
  final BuildContext _context;

  StreamSubscription _webSocketServiceSubscription;
  bool isWaitForLock = false;

  DeviceBlockBloc(this._context, this._device, this._networkService) : super(_device.state.deviceBlockState) {

    _webSocketServiceSubscription?.cancel();

    _webSocketServiceSubscription = webSocketStreamController.stream.listen((event) {
      if(isWaitForLock && event.deviceId == _device.id && event.deviceBlockState == DeviceBlockState.blocked) {
        isWaitForLock = false;
        print('WS BlockEvent.doneBlock');
        add(BlockEvent.doneBlock);
      }
    });

  }

  @override
  Stream<DeviceBlockState> mapEventToState(BlockEvent event) async* {
    String message = "";
    switch (event) {
      case BlockEvent.block:
        yield DeviceBlockState.processing;
        message = AppLocalizations.of(_context).translate('block_device_sent');
        bool status = await  _sendCommand(message);
        if(status) {
          Future.delayed(Duration(seconds: engineBlockTimeoutSeconds), () {
            print('Timeout1');
            if(isWaitForLock) {
              print('Timeout2 BlockEvent.doneBlock');
              isWaitForLock = false;
              add(BlockEvent.doneBlock);
              AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('error'),
                  AppLocalizations.of(_context).translate("possibly_command_not_sent")).show();
            }
          });
        } else {
          yield DeviceBlockState.failure;
        }
        break;
      case BlockEvent.unblock:
        break;
      case BlockEvent.doneBlock:
        print('Bloc: DeviceBlockState.blocked');
        yield DeviceBlockState.blocked;
        break;
      case BlockEvent.doneUnblock:
        break;
    }
  }

  @override
  close() async {
    _webSocketServiceSubscription?.cancel();
    super.close();
  }


  Future<bool> _sendCommand(String message) async{
    try {
      isWaitForLock = true;
      BlockDeviceResponse response = await _networkService.blockDeviceRequest(_device.id);
      if(response != null && response.status != null && response.status == true) {
        AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('block_device_title'),
            message, heightDivider: 6).show();
        return true;
      } else {
        AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('error'),
            (response?.error ?? "") + " " + AppLocalizations.of(_context).translate("command_not_sent")).show();
      }
    } catch(error) {
      AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('error'),
          (error.toString() ?? "") + " " + AppLocalizations.of(_context).translate("command_not_sent")).show();
    }
    return false;
  }
}
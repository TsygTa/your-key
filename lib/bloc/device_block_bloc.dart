import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/localizations/localizations.dart';
import 'package:your_key/model/block_device_response.dart';
import 'package:your_key/model/device.dart';
import 'package:your_key/model/device_state.dart';
import 'package:your_key/networking/network_service.dart';
import 'package:your_key/ui/alert_window.dart';

import 'devices_bloc.dart';

/// Events

enum BlockEvent {
  block,
  unblock,
  doneBlock,
  doneUnblock
}

/// Engine Block Bloc

class DeviceBlockBloc extends Bloc<BlockEvent, DeviceBlockState> {

  static const int engineBlockTimeoutSeconds = 15;

  final Device _device;
  final NetworkService _networkService;
  final BuildContext _context;

  DeviceBlockBloc(this._context, this._device, this._networkService) : super(_device.state.deviceBlockState);

  @override
  Stream<DeviceBlockState> mapEventToState(BlockEvent event) async* {
    yield DeviceBlockState.processing;
    String message = "";
    switch (event) {
      case BlockEvent.block:
        message = AppLocalizations.of(_context).translate('block_device_sent');
        await  _sendCommand(message);
        await Future.delayed(Duration(seconds: engineBlockTimeoutSeconds), () {
          add(BlockEvent.doneBlock);
        });
        break;
      case BlockEvent.unblock:
        message = AppLocalizations.of(_context).translate('unblock_device_sent');
        await  _sendCommand(message);
        await Future.delayed(Duration(seconds: engineBlockTimeoutSeconds),() {
          add(BlockEvent.doneUnblock);
        });
        break;
      case BlockEvent.doneBlock:
        yield DeviceBlockState.blocked;
        break;
      case BlockEvent.doneUnblock:
        yield DeviceBlockState.unblocked;
        break;
    }
  }

  Future<void> _sendCommand(String message) async{
    try {
      BlockDeviceResponse response = await _networkService.blockDeviceRequest(_device.id);
      if(response != null && response.status != null && response.status == true) {
        List<Device> list = [];
        list.add(_device);
        for(int i = 0; i < 10; i++) {
          Future.delayed(Duration(seconds: 10), () {
            _context.bloc<DevicesBloc>().add(GetStates(list));
          });
        }
        AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('block_device_title'),
            message).show();
      } else {
        AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('error'),
            response?.error ?? "").show();
      }
    } catch(error) {
      AlertWindow(_context, AlertType.notification, AppLocalizations.of(_context).translate('error'),
          error.toString() ?? "").show();
    }
  }
}
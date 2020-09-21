import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/bloc/devices_bloc.dart';
import 'package:your_key/localizations/localizations.dart';
import 'package:your_key/model/device_state.dart';

import '../bloc/device_block_bloc.dart';
import '../networking/network_service.dart';
import 'alert_window.dart';
import 'loading_indicator.dart';
import 'main_menu.dart';

class MainPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).title),
      ),
      endDrawer: MainMenu(),
      body: BlocListener<DevicesBloc, DevicesState>(
        listener: (BuildContext context, DevicesState state) {
          if (state is Failure) {
            AlertWindow(context, AlertType.notification,
                AppLocalizations.of(context).translate('error'),
                AppLocalizations.of(context).translate('${state.error}'),
                heightDivider: 6).show();
          }
        },
        child: BlocBuilder<DevicesBloc, DevicesState>(
            builder: (context, devicesState) {
              if(devicesState is Loading) {
                return LoadingIndicator();
              }
              if (devicesState is DevicesInitialized) {
                return BlocProvider<DeviceBlockBloc>(
                  create: (context) => DeviceBlockBloc(context, devicesState.currentDevice, NetworkService()),
                  child: BlocBuilder<DeviceBlockBloc, DeviceBlockState>(
                  builder: (context, deviceBlockState) {
                    if(deviceBlockState == DeviceBlockState.processing) {
                      return Center(
                        child: IconButton(
                          iconSize: 100,
                          icon: devicesState.currentDevice.state.deviceBlockState == DeviceBlockState.blocked
                              ? Icon(Icons.lock_outline, color: Colors.black12,)
                              : Icon(Icons.lock_open, color: Colors.black12,),
                          onPressed: null,
                        ),
                      );
                    } else
                    return Center(
                        child: IconButton(
                          iconSize: 100,
                          icon: devicesState.currentDevice.state.deviceBlockState == DeviceBlockState.blocked
                          ? Icon(Icons.lock_outline, color: Colors.red,)
                          : Icon(Icons.lock_open, color: Colors.green,),
                          onPressed: () {
                            _blockDevice(context, devicesState.currentDevice.state.deviceBlockState);
                          },
                        ),
                      );
                    }
                  )
                );
              }
              return Center(child: Text(AppLocalizations.of(context).translate(
                  "get_devices_error_message")),);
            }
        ),
      ),
    );
  }

  void _blockDevice(BuildContext context, DeviceBlockState deviceBlockState) {
    String message = deviceBlockState == DeviceBlockState.unblocked
        ? AppLocalizations.of(context).translate('block_device')
        : AppLocalizations.of(context).translate('unblock_device');

    AlertWindow alertWindow = AlertWindow(context, AlertType.confirmation,
        AppLocalizations.of(context).translate('block_device_title'),
        message,
        okButtonTitle: AppLocalizations.of(context).translate('confirm'),
        onOkPressed: () {
          if (deviceBlockState == DeviceBlockState.unblocked) {
            context.bloc<DeviceBlockBloc>().add((BlockEvent.block));
          } else if (deviceBlockState == DeviceBlockState.blocked) {
            context.bloc<DeviceBlockBloc>().add((BlockEvent.unblock));
          }
        });

    alertWindow.show();
  }
}
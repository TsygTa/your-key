import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/bloc/devices_bloc.dart';
import 'package:your_key/localizations/localizations.dart';
import 'package:your_key/model/device.dart';
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
        // leading: null, //Container(),
        title: Center(
            child: Text(
          AppLocalizations.of(context).title,
          style: TextStyle(color: Colors.white),
        )),
      ),
      endDrawer: MainMenu(),
      body: BlocListener<DevicesBloc, DevicesState>(
        listener: (BuildContext context, DevicesState state) {
          if (state is Failure) {
            AlertWindow(
                    context,
                    AlertType.notification,
                    AppLocalizations.of(context).translate('error'),
                    AppLocalizations.of(context).translate('${state.error}'),
                    heightDivider: 6)
                .show();
          }
        },
        child: BlocBuilder<DevicesBloc, DevicesState>(
            builder: (context, devicesState) {
          if (devicesState is Loading) {
            return LoadingIndicator();
          }
          if (devicesState is DevicesInitialized) {
            return BlocProvider<DeviceBlockBloc>(
                create: (context) => DeviceBlockBloc(
                    context, devicesState.currentDevice, NetworkService()),
                child: BlocBuilder<DeviceBlockBloc, DeviceBlockState>(
                    builder: (context, deviceBlockState) {
                      if(deviceBlockState == DeviceBlockState.processing) {
                        return _buildButton(context, true, devicesState.currentDevice);
                      } else {
                        return _buildButton(context, false, devicesState.currentDevice);
                      }
                }));
          }
          return Center(
            child: Text(AppLocalizations.of(context)
                .translate("get_devices_error_message")),
          );
        }),
      ),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled, Device device) {
    print("_buildButton isDisabled: $isDisabled");
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        top: 20,
      ),
      child: RaisedButton(
        onPressed: isDisabled ? null : () {
          _blockDevice(context);
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        elevation: 6,
        color: Colors.purple[200],
        splashColor: Colors.amber,
        disabledColor: Colors.purple[50],
        child: Container(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                device.getTitle(),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                'нажмите чтобы открыть',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ), //devicesState.currentDevice.getTitle()
      ),
    );
  }

  void _blockDevice(BuildContext context) {

    context.bloc<DeviceBlockBloc>().add((BlockEvent.block));

    // String message = AppLocalizations.of(context).translate('block_device');
    // AlertWindow alertWindow = AlertWindow(context, AlertType.confirmation,
    //     AppLocalizations.of(context).translate('block_device_title'), message,
    //     okButtonTitle: AppLocalizations.of(context).translate('confirm'),
    //     onOkPressed: () {
    //       context.bloc<DeviceBlockBloc>().add((BlockEvent.block));
    // });
    // alertWindow.show();
  }
}

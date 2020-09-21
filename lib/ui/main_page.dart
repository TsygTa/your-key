import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/bloc/devices_bloc.dart';
import 'package:your_key/localizations/localizations.dart';
import 'package:your_key/model/device_state.dart';

import 'alert_window.dart';
import 'loading_indicator.dart';
import 'main_menu.dart';

class MainPage extends StatelessWidget {

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
                return Center(
                  child: IconButton(
                    iconSize: 100,
                    icon: devicesState.currentDevice.state.deviceBlockState == DeviceBlockState.blocked
                    ? Icon(Icons.lock_outline, color: Colors.red,)
                    : Icon(Icons.lock_open, color: Colors.green,),
                    onPressed: () {

                    },
                  ),
                );
              }
              return Center(child: Text(AppLocalizations.of(context).translate(
                  "get_devices_error_message")),);
            }
        ),
      ),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/model/device.dart';
import 'package:your_key/model/device_state_response.dart';
import 'package:your_key/networking/network_service.dart';
import 'package:equatable/equatable.dart';

// Observables Events

abstract class DevicesEvent extends Equatable {
  const DevicesEvent();
  @override
  List<Object> get props => [];
}

class Fetch extends DevicesEvent {}

class InitDevices extends DevicesEvent {
  const InitDevices();
  @override
  List<Object> get props => [];
}

class GetStates extends DevicesEvent {
  final List<Device> _devices;
  const GetStates(this._devices);
  @override
  List<Object> get props => [_devices];
}

// Observables States

abstract class DevicesState extends Equatable {

  const DevicesState();

  @override
  List<Object> get props => [];
}
class Loading extends DevicesState {
  Loading();
  @override
  String toString() => 'Loading';
}

class Loaded extends DevicesState {

  final List<Device> _devices;

  const Loaded(this._devices);

  @override
  List<Object> get props => [_devices];

  @override
  String toString() => 'Loaded { items: ${_devices.length} }';
}

class Failure extends DevicesState {
  final String error;

  const Failure(this.error);

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'Failure { Error: $error }';
}

class DevicesInitialized extends DevicesState {

  final Device currentDevice;
  final List<Device> devices;

  DevicesInitialized(this.currentDevice, this.devices);

  @override
  String toString() => 'ObservablesInitialized { observables: ${currentDevice.id} }';
}

class DevicesBloc extends Bloc<DevicesEvent, DevicesState> {

  final NetworkService _networkService;

  Device _currentDevice;
  List<Device> _devices = [];

  DevicesBloc(this._networkService)
      : assert(_networkService != null), super(Loading());

  @override
  Stream<DevicesState> mapEventToState(DevicesEvent event) async* {
    if (event is Fetch) {
      yield Loading();
      try {
        final response = await _networkService.getDevicesRequest();
        List<Device> list = await _getStates(response.devices);
        _devices.clear();
        _devices.addAll(list);
        add(InitDevices());
      } catch (error) {
        print(error);
        yield Failure("network_connection_failed");
      }
    }

    if (event is InitDevices) {
      yield Loading();
      _currentDevice = _devices[0];
      yield DevicesInitialized(_currentDevice, _devices);
    }

// Обновление стейтов только для наблюдаемых объектов
    if (event is GetStates) {
      try {
        List<Device> list = await _getStates(event._devices);

        list.forEach((element) {
          _devices.removeWhere((item) => item.id == element.id);
          _devices.add(element);
        });
        _currentDevice =
            _devices.singleWhere((element) => element.id ==
                _currentDevice.id,
                orElse: () => _devices[0]);
        yield DevicesInitialized(_currentDevice, _devices);
      } catch (error) {
        print(error);
      }
    }
  }

  Future<List<Device>> _getStates(List<Device> devices) async {
    if(devices == null) {
      devices = _devices;
    }
    List<int> observableIds = [];
    for (var i = 0; i < devices.length; i++) {
      if (i > 0 && i % 5 == 0 || i == devices.length - 1) {
        if (i == devices.length - 1) {
          observableIds.add(devices[i].id);
        }

        DeviceStateResponse stateResponse = await _networkService
            .getObservableStateRequest(observableIds);

        if (stateResponse.deviceStates != null) {
          stateResponse.deviceStates.forEach((state) {
            devices[devices
                .indexOf(
                devices.singleWhere((element) => element.id ==
                    state.deviceId))].state = state;
          });
        }
        observableIds.clear();
      }
      observableIds.add(devices[i].id);
    }
    List<Device> list = [];
    list.addAll(devices);
    return list;
  }
}
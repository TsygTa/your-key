import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/networking/http_client.dart';
import 'package:your_key/repository/user_repository.dart';

import 'auth_bloc.dart';

//Login Events
abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;
  final bool isRememberMe;

  const LoginButtonPressed( this.username, this.password, this.isRememberMe);

  @override
  List<Object> get props => [username, password, isRememberMe];

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}

class DemoButtonPressed extends LoginEvent {
  final String username = '123';
  final String password = '123';
  final bool isRememberMe = false;

  @override
  // TODO: implement props
  List<Object> get props => [username, password];
}

//Login States

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure(this.error);

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'LoginFailure { error: $error }';
}

//Login Bloc

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository _userRepository;
  final AuthenticationBloc _authenticationBloc;

  LoginBloc(this._userRepository, this._authenticationBloc)
      : assert(_userRepository != null), assert(_authenticationBloc != null), super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginInProgress();

      try {
        final response = await _userRepository.authenticate(event.username, event.password);

        if(response.status) {
          _authenticationBloc.add(AuthenticationLoggedIn(event.username, event.password, event.isRememberMe));
          yield LoginInitial();
        } else {
          yield LoginFailure(response.error.toString());
        }
      } catch (error) {
        if(error is RequestTypeNotFoundException) {
          yield LoginFailure(error.cause);
        } else {
          yield LoginFailure(error.toString() ?? "");
        }
      }
    }

    if (event is DemoButtonPressed) {
      yield LoginInProgress();

      try {
        final response = await _userRepository.authenticate(event.username, event.password);

        if(response.status) {
          _authenticationBloc.add(AuthenticationLoggedIn(event.username, event.password, false));
          yield LoginInitial();
        } else {
          yield LoginFailure(response.error.toString());
        }
      } catch (error) {
        if(error is RequestTypeNotFoundException) {
          yield LoginFailure(error.cause);
        } else {
          yield LoginFailure(error.toString() ?? "");
        }
      }
    }
  }
}
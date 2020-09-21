import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/repository/user_repository.dart';

// Authentication States
abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {}

class AuthenticationFailure extends AuthenticationState {
  final String error;
  const AuthenticationFailure({this.error});
  @override
  List<Object> get props => [error];
  @override
  String toString() => 'AuthenticationFailure { error: $error }';
}

class AuthenticationInProgress extends AuthenticationState {}

// Authentication Events
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationStarted extends AuthenticationEvent {}

class AuthenticationLoggedIn extends AuthenticationEvent {
  final String login;
  final String password;
  final bool isRememberMe;

  const AuthenticationLoggedIn(this.login, this.password, this.isRememberMe);

  @override
  List<Object> get props => [login, password];

  @override
  String toString() => 'AuthenticationLoggedIn { login: $login, password: $password }';
}

class AuthenticationLoggedOut extends AuthenticationEvent {}

// Authentication Bloc

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc(this._userRepository) : assert(_userRepository != null), super(AuthenticationInitial());

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {

    if (event is AuthenticationStarted) {
      final String login = await _userRepository.getLogin();
      final String password = await _userRepository.getPassword();

      if (login != null &&  password != null) {
        try {
          final response = await _userRepository.authenticate(login, password);

          if(response.status) {
            yield AuthenticationSuccess();
          } else {
            yield AuthenticationFailure();
          }
        } catch (error) {
          yield AuthenticationFailure(error: error.toString());
        }
      } else {
        yield AuthenticationFailure();
      }
    }

    if (event is AuthenticationLoggedIn) {
      if(event.isRememberMe) {
        yield AuthenticationInProgress();
        await _userRepository.persistAuthData(event.login, event.password);
      }
      yield AuthenticationSuccess();
    }

    if (event is AuthenticationLoggedOut) {
      yield AuthenticationInProgress();
      await _userRepository.deleteAuthData();
      await _userRepository.clearSharedPreferences();
      yield AuthenticationFailure();
    }
  }
}
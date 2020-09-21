import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main.dart';
import 'auth_bloc.dart';

class MenuItem {
  final String name;
  final IconData icon;
  final MainMenuEvent event;

  MenuItem(this.name, this.icon, this.event);
}

enum MainMenuEvent {mainpage, settings, profile, aboutApp, exit}

class MainMenuBloc extends Bloc<MainMenuEvent, List<MenuItem>> {

  final AuthenticationBloc _authenticationBloc;

  static final List<MenuItem> mainMenuItems = [
    MenuItem('settings', Icons.settings, MainMenuEvent.settings),
    MenuItem('profile', Icons.person, MainMenuEvent.profile),
    MenuItem('aboutApp', Icons.info_outline, MainMenuEvent.aboutApp),
    MenuItem('exit', Icons.exit_to_app, MainMenuEvent.exit)
  ];

  MainMenuBloc(this._authenticationBloc)
      : assert(_authenticationBloc != null), super(mainMenuItems);

  @override
  Stream<List<MenuItem>> mapEventToState(MainMenuEvent event) async* {
    switch (event) {
      case MainMenuEvent.mainpage:
        navigationService.navigateToAndRemoveAll('/');
        break;
      case MainMenuEvent.settings:
      // TODO: Handle this case.
        break;
      case MainMenuEvent.profile:
      // TODO: Handle this case.
        break;
      case MainMenuEvent.aboutApp:
      // TODO: Handle this case.
        break;
      case MainMenuEvent.exit:
        navigationService.pop();
        _authenticationBloc.add(AuthenticationLoggedOut());
        break;
    }
  }
}
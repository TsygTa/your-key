import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/repository/user_repository.dart';
import 'package:your_key/ui/loading_indicator.dart';
import 'package:your_key/ui/login_page.dart';
import 'package:your_key/ui/main_page.dart';
import 'package:your_key/ui/splash_page.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/devices_bloc.dart';
import 'bloc/simple_bloc_observer.dart';
import 'localizations/localizations.dart';
import 'model/device_state.dart';
import 'networking/network_service.dart';
import 'networking/websocket_service.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState.pushNamed(routeName);
  }

  Future<dynamic> navigateToAndRemoveAll(String routeName) {
    return navigatorKey.currentState.pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  void popUntil(String routeName) {
    return navigatorKey.currentState.popUntil(ModalRoute.withName(routeName));
  }
  void pop() {
    return navigatorKey.currentState.pop();
  }
}

final NavigationService navigationService =  NavigationService();
final StreamController<DeviceState> webSocketStreamController = StreamController<DeviceState>.broadcast();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<DevicesBloc>(
          create: (context) => DevicesBloc(NetworkService()),
        ),
        BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc(UserRepository())..add(AuthenticationStarted()),
        ),
      ],
      child: MyApp(UserRepository()),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp(this._userRepository, {Key key}) : super(key: key);
  final UserRepository _userRepository;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    switch(state) {
      case AppLifecycleState.resumed:
        context.bloc<DevicesBloc>().add(Fetch());
        WebSocketService(NetworkService(), webSocketStreamController).connect();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        WebSocketService(NetworkService(), webSocketStreamController).close();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).title,
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ru', ''),
      ],
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      navigatorKey: navigationService.navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => _buildHomePage(),
      },
    );
  }

  Widget _buildHomePage() {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationSuccess) {
          context.bloc<DevicesBloc>().add(Fetch());
          WebSocketService(NetworkService(), webSocketStreamController).connect();
          return MainPage();
        }
        if (state is AuthenticationFailure) {
          return LoginPage(userRepository: widget._userRepository);
        }
        if (state is AuthenticationInProgress) {
          return LoadingIndicator();
        }
        return SplashPage();
      },
    );
  }

}

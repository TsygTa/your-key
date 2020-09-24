import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/bloc/auth_bloc.dart';
import 'package:your_key/bloc/login_bloc.dart';
import 'package:your_key/localizations/localizations.dart';
import 'package:your_key/repository/user_repository.dart';

import 'alert_window.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).title)),
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
              userRepository, BlocProvider.of<AuthenticationBloc>(context));
        },
        child: LoginForm(),
      ),
    );
  }
}

// LoginForm
class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isRememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      if (_formKey.currentState.validate()) {
        BlocProvider.of<LoginBloc>(context).add(LoginButtonPressed(
            _usernameController.text, _passwordController.text, _isRememberMe));
      }
    }

    _onDemoButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(DemoButtonPressed());
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          AlertWindow(
                  context,
                  AlertType.notification,
                  AppLocalizations.of(context).translate('failed_authenticate'),
                  AppLocalizations.of(context).translate('${state.error}'),
                  heightDivider: 4)
              .show();
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context).translate('login')),
                      controller: _usernameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)
                              .translate('login_enter_message');
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .translate('password')),
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)
                              .translate('password_enter_message');
                        }
                        return null;
                      },
                    ),
                    CheckboxListTile(
                        activeColor: Theme.of(context).appBarTheme.color,
                        checkColor: Colors.white,
                        title: Text(AppLocalizations.of(context)
                            .translate('remember_me')),
                        value: _isRememberMe,
                        onChanged: (bool value) {
                          setState(() {
                            _isRememberMe = value;
                          });
                        }),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0)),
                              color: Theme.of(context).appBarTheme.color,
                              textColor: Theme.of(context).primaryColor,
                              onPressed: state is! LoginInProgress
                                  ? _onLoginButtonPressed
                                  : null,
                              child: Text(AppLocalizations.of(context)
                                  .translate('sign_in')),
                            ),
                            // RaisedButton(
                            //   shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(18.0)),
                            //   color: Theme.of(context).appBarTheme.color,
                            //   textColor: Theme.of(context).primaryColor,
                            //   onPressed: state is! LoginInProgress
                            //       ? _onDemoButtonPressed
                            //       : null,
                            //   child: Text(AppLocalizations.of(context)
                            //       .translate('demo')),
                            // ),
                          ]),
                    ),
                    Container(
                      child: state is LoginInProgress
                          ? CircularProgressIndicator()
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

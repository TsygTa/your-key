import 'dart:async';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Your Key',
// Errors
      'get_observables_error_message': 'Server is not available',
      'no_observables_message': 'No data to display',
      'failed_get_device_state': 'State parsing error',
      'failed_websocket_key': 'WebSocket key response error',
      'failed_websocket_auth': 'WebSocket Authentication error',
      'network_connection_failed': 'No internet connection',
      'failed_block_device': 'Lock command error',
      'loading': 'Loading...',
      'error': 'Error',
// Menu
      'menu': 'Menu',
      'observables': 'Observable objects',
      'settings': 'Settings',
      'profile': 'Profile',
      'aboutApp': 'about App',
      'exit': 'Exit',
// Networking
      'failed_authenticate': 'Authentication error',
//Authentication
      'login': 'Login',
      'password': 'Password',
      'remember_me': 'Remember Me',
      'sign_in': 'Sign In',
      'demo': 'Demo',
      'login_enter_message': 'Please enter login',
      'password_enter_message': 'Please enter password',
      'No user id': 'Wrong login or password',
// Info Panel
      'block_device_title': 'Change in blocking status',
      'block_engine': 'Confirm Lock',
      'unblock_engine': 'Confirm Unlock',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'block_device_sent':
          'Block command is sent. Wait for the command to complete.',
      'unblock_device_sent':
          'Unlock command is sent. Wait for the command to complete.',
    },
    'ru': {
      'title': 'Ваш Ключ',
// Errors
      'get_observables_error_message': 'Сервер не доступен',
      'no_observables_message': 'Нет данных для отображения',
      'failed_get_device_state': 'Ошибка разбора состояния',
      'failed_websocket_key': 'Ошибка запроса WebSocket key',
      'failed_websocket_auth': 'Ошибка авторизации WebSocket',
      'network_connection_failed': 'Нет соединения с интернетом',
      'failed_block_device': 'Ошибка команды блокировки',
      'loading': 'Загрузка...',
      'error': 'Ошибка',
// Menu
      'menu': 'Меню',
      'observables': 'Объекты наблюдения',
      'settings': 'Настройки',
      'profile': 'Профиль',
      'aboutApp': 'О приложении',
      'exit': 'Выход',
// Networking
      'failed_authenticate': 'Ошибка авторизации',
//Authentication
      'login': 'Логин',
      'password': 'Пароль',
      'remember_me': 'Запомнить меня',
      'sign_in': 'Вход',
      'demo': 'Демо',
      'login_enter_message': 'Введите логин',
      'password_enter_message': 'Введите пароль',
      'No user id': 'Неверный логин или пароль',
// Info Panel
      'block_device_title': 'Изменение статуса блокировки',
      'block_device': 'Подтвердите Блокировку',
      'unblock_device': 'Подтвердите Разблокировку',
      'confirm': 'Подтвердить',
      'cancel': 'Отменить',
      'block_device_sent':
          'Команда на блокировку отправлена. Дождитесь завершения выполнения команды.',
      'unblock_device_sent':
          'Команда на разблокировку отправлена. Дождитесь завершения выполнения команды.',
    },
  };

  String translate(String string) {
    if (_localizedValues[locale.languageCode][string] == null) {
      return string;
    } else {
      return _localizedValues[locale.languageCode][string];
    }
  }

  String translateWithColon(String string) {
    if (_localizedValues[locale.languageCode][string] == null) {
      return string + ': ';
    } else {
      return _localizedValues[locale.languageCode][string] + ': ';
    }
  }

  String get title {
    return _localizedValues[locale.languageCode]['title'];
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate old) => false;
}

import 'package:flutter/material.dart';

import '../localizations/localizations.dart';
import '../ui/splash_page.dart';

enum AlertType { confirmation, notification }

class AlertWindow {
  final BuildContext _context;
  final AlertType _type;
  final String _title;
  final String _message;
  final String okButtonTitle;
  final Function onOkPressed;
  final int intervalSeconds;
  final int heightDivider;
  final bool isSpinner;

  OverlayState _overlayState;
  OverlayEntry _overlayEntry;

  AlertWindow(this._context, this._type, this._title, this._message,
      {this.okButtonTitle = "OK",
      this.onOkPressed,
      this.intervalSeconds = 3,
      this.heightDivider = 4,
      this.isSpinner = true}) {
    _overlayState = Overlay.of(_context);
    _overlayEntry = OverlayEntry(builder: (_context) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            width: MediaQuery.of(_context).size.width / 7 * 6,
            height: MediaQuery.of(_context).size.height / heightDivider,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.redAccent),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _message,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  _type == AlertType.notification
                      ? (isSpinner ? Container(
                          child: Spinner(
                            duration: Duration(
                              milliseconds: 4000,
                            ),
                            icon: Icon(
                              Icons.vpn_key_rounded,
                              size: 50,
                              color: Colors.purpleAccent,
                            ),
                          ),
                        ) : Container())
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FlatButton(
                              onPressed: () {
                                onOkPressed();
                                _overlayEntry.remove();
                              },
                              child: Text(okButtonTitle,
                                  style: TextStyle(color: Colors.teal)),
                            ),
                            FlatButton(
                              onPressed: _onCancelPressed,
                              child: Text(
                                AppLocalizations.of(_context)
                                    .translate('cancel'),
                                style: TextStyle(
                                  color: Colors.teal,
                                ),
                              ),
                            )
                          ],
                        )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _onCancelPressed() {
    _overlayEntry.remove();
  }

  void show() async {
    _overlayState.insert(_overlayEntry);
    if (_type == AlertType.notification) {
      await Future.delayed(Duration(seconds: intervalSeconds));
      _overlayEntry.remove();
    }
  }
}

import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(
          Icons.vpn_key_rounded,
          size: 150,
          color: Colors.purpleAccent,
        ),
      ),
    );
  }
}

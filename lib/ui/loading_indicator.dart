import 'package:flutter/material.dart';
import 'package:your_key/ui/splash_page.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
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
    //CircularProgressIndicator(),
  );
}
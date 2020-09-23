import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  final double size;

  SplashPage({
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Spinner(
          duration: Duration(
            milliseconds: 4000,
          ),
          icon: Icon(
            Icons.vpn_key_rounded,
            size: size,
            color: Colors.purpleAccent,
          ),
        ),
      ),
    );
  }
}

class Spinner extends StatefulWidget {
  final Icon icon;
  final Duration duration;

  const Spinner({
    Key key,
    @required this.icon,
    this.duration = const Duration(milliseconds: 1800),
  }) : super(key: key);

  @override
  _SpinnerState createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Widget _child;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat();
    _child = widget.icon;

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: _child,
    );
  }
}

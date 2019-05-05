import 'package:flutter/material.dart';
import './ui/sign_in.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
          body: SignIn()
      ),
    );
  }
}
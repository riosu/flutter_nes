import 'package:flutter/material.dart';
import 'package:flutter_nes/pages/emulator.dart';
import 'package:flutter_nes/pages/stripe.dart';
import 'package:flutter_nes/pages/top.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // initialRoute: "/",
      initialRoute: "/emulator",
      routes: <String, WidgetBuilder> {
        "/": (context) => TopPageWidget(),
        "/stripe": (context) => StripePageWidget(),
        "/emulator": (context) => EmulatorPageWidget(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

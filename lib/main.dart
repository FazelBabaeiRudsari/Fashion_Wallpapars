import 'package:fashion_wallpapers/ui/dashboard.dart';
import 'package:fashion_wallpapers/ui/myapp.dart';
import 'package:flutter/material.dart';

String APP_ID = "ca-app-pub-5658699902837706~8685176551";
String BANNER_UNIT_TEST = "ca-app-pub-5658699902837706/5739449013";
String INTERESTIAL_UNIT_TEST = "ca-app-pub-5658699902837706/2053971983";
String REWARDED_UNIT_TEST = "ca-app-pub-5658699902837706/5731710159";
String NATIVE_ADVANCED_UNIT_TEST = "ca-app-pub-5658699902837706/1852174893";
const EVENTS_KEY = "fetch_events";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MaterialApp(
    home: Dashboard(),
    debugShowCheckedModeBanner: false,
    navigatorKey: navigatorKey,
    initialRoute: "/",
    builder: (BuildContext context, Widget child) {
      return Padding(
        child: child,
        padding: EdgeInsets.only(bottom: 60),
      );
    },
    theme: ThemeData(),
  ));
}

import 'package:flutter/material.dart';
import 'package:svizh_mobile/services/bluetooth-printer/esc_pos_print.dart';
import 'package:svizh_mobile/services/bluetooth-printer/flutter_blue_services.dart';
import 'package:svizh_mobile/services/bluetooth-printer/test.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          accentColor: Colors.teal,
          // errorColor: Colors.red,
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
            headline6: TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            button: TextStyle(color: Colors.white),
          ),
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
      home: FlutterBlueServiceTest(),
    );
  }
}

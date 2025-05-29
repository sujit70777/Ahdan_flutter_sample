// ignore_for_file: avoid_print

import 'package:Adhan_flutter_example/solution/test2.dart';
import 'package:flutter/material.dart';

void mainOld() {
  PrayTimes pt = PrayTimes('MWL');
  pt.adjust({'highLats': 'AngleBased'});
  Map<String, String> times = pt.getTimes(DateTime.now(), [
    60.1699,
    24.9384,
  ], 3);
  print('Sunrise: ${times['sunrise']}');
  print('Sunset: ${times['sunset']}');
  print('Midnight: ${times['midnight']}');
  print('Imsak: ${times['imsak']}');
  print('Fajr: ${times['fajr']}');
  print('Dhuhr: ${times['dhuhr']}');
  print('Asr: ${times['asr']}');
  print('Maghrib: ${times['maghrib']}');
  print('Isha: ${times['isha']}');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: Text('Prayer Times')),
        body: Center(child: Text('Prayer Times')),
      ),
    );
  }
}

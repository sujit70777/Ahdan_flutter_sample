import 'dart:convert';
import 'package:Adhan_flutter_example/solution/data.txt';
import 'package:Adhan_flutter_example/solution/gmt_utc.dart';
import 'package:Adhan_flutter_example/solution/test2.dart';
import 'package:Adhan_flutter_example/solution/timezone_calculator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: PrayerTimesDemo(),
    ),
  );
}

class PrayerTimesDemo extends StatefulWidget {
  @override
  _PrayerTimesDemoState createState() => _PrayerTimesDemoState();
}

class _PrayerTimesDemoState extends State<PrayerTimesDemo> {
  final TextEditingController _latController = TextEditingController(
    text: '24.9384',
  );
  final TextEditingController _lngController = TextEditingController(
    text: '87',
  );

  Map<String, String>? _prayerTimes;
  Map<String, String>? _prayerTimes2; // New prayer times
  final DateFormat _timeFormat = DateFormat.jm();
  DateTime _selectedDate = DateTime.now();

  int _method = 3; // Default method: Umm al-Qura
  final List<Map<String, dynamic>> _methods = [
    {'name': 'Muslim World League', 'value': 3, 'key': 'MWL'},
    {'name': 'Egyptian', 'value': 5, 'key': 'Egypt'},
    {'name': 'Karachi', 'value': 1, 'key': 'Karachi'},
    {'name': 'Umm al-Qura', 'value': 4, 'key': 'Makkah'},
    // {'name': 'Dubai', 'value': 12, 'key': 'Dubai'},
    // {'name': 'Moonsighting Committee', 'value': 8, 'key': 'ISNA'},
    {'name': 'North America (ISNA)', 'value': 2, 'key': 'ISNA'},
    // {'name': 'Kuwait', 'value': 9},
    // {'name': 'Qatar', 'value': 10,},
    // {'name': 'Singapore', 'value': 11, },
    {'name': 'Tehran', 'value': 7, 'key': 'Tehran'},
    // {'name': 'Turkey', 'value': 13},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times via Aladhan API')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLocationInput(),
            _buildMethodDropdown(),
            _buildDateSelection(),
            ElevatedButton(
              onPressed: _fetchPrayerTimes,
              child: const Text('Get Prayer Times'),
            ),
            if (_prayerTimes != null) _buildResults(),
            const SizedBox(height: 16),
            const Text(
              'This app uses the Aladhan.com API for prayer times.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _latController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _lngController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodDropdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<int>(
          value: _method,
          items:
              _methods.map((method) {
                return DropdownMenuItem<int>(
                  value: method['value'],
                  child: Text(method['name']),
                );
              }).toList(),
          onChanged: (value) {
            print(value);
            setState(() {
              _method = value!;
            });
          },
          decoration: const InputDecoration(labelText: 'Calculation Method'),
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Date: ${DateFormat.yMd().format(_selectedDate)}'),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      final double lat = double.parse(_latController.text);
      final double lng = double.parse(_lngController.text);

      final dateString = DateFormat('dd-MM-yyyy').format(_selectedDate);

      String key = _methods.firstWhere((m) => m['value'] == _method)['key'];

      PrayTimes pt = PrayTimes(key);

      // if (double.parse(_latController.text).abs() >= 60) {
      //   pt.adjust({'highLats': 'AngleBased'});
      //   // _params.highLatitudeRule = HighLatitudeRule.seventh_of_the_night;
      // } else if (double.parse(_latController.text).abs() >= 45) {
      //   // _params.highLatitudeRule = HighLatitudeRule.twilight_angle;
      // }
      pt.adjust({'highLats': 'AngleBased'});

      final double timezoneOffset = await getTimezoneOffset(lat, lng);

      print('timezoneOffset: $timezoneOffset');

      _prayerTimes2 = pt.getTimes(_selectedDate, [lat, lng], timezoneOffset);

      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/$dateString?latitude=$lat&longitude=$lng&method=$_method',
      );

      print(url.toString()); // Debugging line to check the URL

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final timings = Map<String, dynamic>.from(data['data']['timings']);
        setState(() {
          _prayerTimes = timings.map((k, v) => MapEntry(k, v.toString()));
        });
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  Future<double> getTimezoneOffset(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://timeapi.io/api/timezone/coordinate?latitude=$latitude&longitude=$longitude',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract seconds from currentUtcOffset and convert to hours
        final seconds = data['currentUtcOffset']['seconds'] ?? 0;
        return seconds / 3600.0; // Convert seconds to hours
      } else {
        throw Exception(
          'Failed to fetch timezone offset: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching timezone offset: $e');
    }
  }

  Widget _buildResults() {
    final keys = [
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Sunset',
      'Isha',
      'Imsak',
    ];
    final keys2 = [
      'fajr',
      'sunrise',
      'dhuhr',
      'asr',
      'maghrib',
      'sunset',
      'isha',
      'imsak',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Prayer times for ${DateFormat.yMMMMd().format(_selectedDate)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),
            Text("Fatch Time from API"),
            ...keys.map((key) => _buildTimeRow(key, _prayerTimes![key] ?? '')),

            const SizedBox(height: 8),
            Text("Get Time from Offline Calculator"),
            ...keys2.map(
              (key) => _buildTimeRow(key, _prayerTimes2![key] ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String name, String timeStr) {
    // Parse string like "04:10" to DateTime today
    final now = DateTime.now();
    final parts = timeStr.split(':');
    final parsedTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(name), Text(_timeFormat.format(parsedTime))],
      ),
    );
  }
}

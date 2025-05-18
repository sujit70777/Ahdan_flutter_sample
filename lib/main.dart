import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

void main() => runApp(
  MaterialApp(
    theme: ThemeData.dark(),
    debugShowCheckedModeBanner: false,
    home: PrayerTimesDemo(),
  ),
);

class PrayerTimesDemo extends StatefulWidget {
  @override
  _PrayerTimesDemoState createState() => _PrayerTimesDemoState();
}

class _PrayerTimesDemoState extends State<PrayerTimesDemo> {
  // Controllers for latitude and longitude input
  final TextEditingController _latController = TextEditingController(
    text: '60.1699',
  ); // Default: Helsinki, Finland
  final TextEditingController _lngController = TextEditingController(
    text: '24.9384',
  );

  // Variable to store calculated prayer times
  PrayerTimes? _prayerTimes;

  // Date format for displaying times
  final DateFormat _timeFormat = DateFormat.jm();

  // Selected date, defaulting to today
  DateTime _selectedDate = DateTime.now();

  // Calculation parameters, default to Muslim World League
  CalculationParameters _params =
      CalculationMethod.muslim_world_league.getParameters();

  // List of available calculation methods
  final List<CalculationMethod> _calculationMethods = [
    CalculationMethod.muslim_world_league,
    CalculationMethod.egyptian,
    CalculationMethod.karachi,
    CalculationMethod.umm_al_qura,
    CalculationMethod.dubai,
    CalculationMethod.moon_sighting_committee,
    CalculationMethod.north_america,
    CalculationMethod.kuwait,
    CalculationMethod.qatar,
    CalculationMethod.singapore,
    CalculationMethod.tehran,
    CalculationMethod.turkey,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLocationInput(),
            _buildCalculationSettings(),
            _buildDateSelection(),
            ElevatedButton(
              onPressed: _calculateTimes,
              child: const Text('Calculate Prayer Times'),
            ),
            if (_prayerTimes != null) _buildResults(),
            const SizedBox(height: 16),
            const Text(
              'This app uses the Adhan package to calculate prayer times.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Builds the location input card with latitude and longitude fields
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

  /// Builds the calculation settings card with method and madhab dropdowns
  Widget _buildCalculationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<CalculationMethod>(
              value: _params.method,
              items:
                  _calculationMethods.map((method) {
                    return DropdownMenuItem<CalculationMethod>(
                      value: method,
                      child: Text(method.name),
                    );
                  }).toList(),
              onChanged: (method) {
                setState(() {
                  _params = method!.getParameters();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Calculation Method',
              ),
            ),
            DropdownButtonFormField<Madhab>(
              value: _params.madhab,
              items:
                  Madhab.values.map((madhab) {
                    return DropdownMenuItem<Madhab>(
                      value: madhab,
                      child: Text(madhab == Madhab.shafi ? 'Shafi' : 'Hanafi'),
                    );
                  }).toList(),
              onChanged: (madhab) {
                setState(() {
                  _params.madhab = madhab!;
                });
              },
              decoration: const InputDecoration(labelText: 'Madhab'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the date selection row with a date picker button
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

  /// Shows the date picker and updates the selected date
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

  /// Builds the results card displaying calculated prayer times
  Widget _buildResults() {
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
            _buildTimeRow('Fajr', _prayerTimes!.fajr),
            _buildTimeRow('Sunrise', _prayerTimes!.sunrise),
            _buildTimeRow('Dhuhr', _prayerTimes!.dhuhr),
            _buildTimeRow('Asr', _prayerTimes!.asr),
            _buildTimeRow('Maghrib', _prayerTimes!.maghrib),
            _buildTimeRow('Isha', _prayerTimes!.isha),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a row for each prayer time
  Widget _buildTimeRow(String name, DateTime time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(name), Text(_timeFormat.format(time))],
      ),
    );
  }

  /// Calculates prayer times based on user input
  void _calculateTimes() {
    try {
      final double lat = double.parse(_latController.text);
      final double lng = double.parse(_lngController.text);
      final coordinates = Coordinates(lat, lng);

      // Adjust high latitude rules
      if (lat.abs() >= 60) {
        _params.highLatitudeRule = HighLatitudeRule.seventh_of_the_night;
      } else if (lat.abs() >= 45) {
        _params.highLatitudeRule = HighLatitudeRule.twilight_angle;
      }

      final dateComponents = DateComponents.from(_selectedDate);
      setState(() {
        _prayerTimes = PrayerTimes(coordinates, dateComponents, _params);
      });
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Invalid input: ${e.toString()}'),
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
}

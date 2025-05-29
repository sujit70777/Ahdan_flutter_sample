import 'dart:math' as math;

class LocationTimeCalculator {
  // Time zone data for major cities (offset in hours from UTC)
  static const Map<String, double> _timeZoneOffsets = {
    // Major time zones with their UTC offsets
    'UTC-12': -12.0, 'UTC-11': -11.0, 'UTC-10': -10.0, 'UTC-9': -9.0,
    'UTC-8': -8.0, 'UTC-7': -7.0, 'UTC-6': -6.0, 'UTC-5': -5.0,
    'UTC-4': -4.0, 'UTC-3': -3.0, 'UTC-2': -2.0, 'UTC-1': -1.0,
    'UTC+0': 0.0, 'UTC+1': 1.0, 'UTC+2': 2.0, 'UTC+3': 3.0,
    'UTC+4': 4.0, 'UTC+5': 5.0, 'UTC+6': 6.0, 'UTC+7': 7.0,
    'UTC+8': 8.0, 'UTC+9': 9.0, 'UTC+10': 10.0, 'UTC+11': 11.0, 'UTC+12': 12.0,
  };

  // Approximate time zone boundaries (longitude ranges)
  static const List<Map<String, dynamic>> _timeZoneBoundaries = [
    {'min': -180.0, 'max': -165.0, 'offset': -12.0}, // UTC-12
    {'min': -165.0, 'max': -150.0, 'offset': -11.0}, // UTC-11
    {'min': -150.0, 'max': -135.0, 'offset': -10.0}, // UTC-10
    {'min': -135.0, 'max': -120.0, 'offset': -9.0}, // UTC-9
    {'min': -120.0, 'max': -105.0, 'offset': -8.0}, // UTC-8
    {'min': -105.0, 'max': -90.0, 'offset': -7.0}, // UTC-7
    {'min': -90.0, 'max': -75.0, 'offset': -6.0}, // UTC-6
    {'min': -75.0, 'max': -60.0, 'offset': -5.0}, // UTC-5
    {'min': -60.0, 'max': -45.0, 'offset': -4.0}, // UTC-4
    {'min': -45.0, 'max': -30.0, 'offset': -3.0}, // UTC-3
    {'min': -30.0, 'max': -15.0, 'offset': -2.0}, // UTC-2
    {'min': -15.0, 'max': 0.0, 'offset': -1.0}, // UTC-1
    {'min': 0.0, 'max': 15.0, 'offset': 0.0}, // UTC+0
    {'min': 15.0, 'max': 30.0, 'offset': 1.0}, // UTC+1
    {'min': 30.0, 'max': 45.0, 'offset': 2.0}, // UTC+2
    {'min': 45.0, 'max': 60.0, 'offset': 3.0}, // UTC+3
    {'min': 60.0, 'max': 75.0, 'offset': 4.0}, // UTC+4
    {'min': 75.0, 'max': 90.0, 'offset': 5.0}, // UTC+5
    {'min': 90.0, 'max': 105.0, 'offset': 6.0}, // UTC+6
    {'min': 105.0, 'max': 120.0, 'offset': 7.0}, // UTC+7
    {'min': 120.0, 'max': 135.0, 'offset': 8.0}, // UTC+8
    {'min': 135.0, 'max': 150.0, 'offset': 9.0}, // UTC+9
    {'min': 150.0, 'max': 165.0, 'offset': 10.0}, // UTC+10
    {'min': 165.0, 'max': 180.0, 'offset': 11.0}, // UTC+11
  ];

  /// Calculate UTC offset based on longitude (rough approximation)
  static double _calculateUtcOffsetFromLongitude(double longitude) {
    // Ensure longitude is in valid range
    longitude = longitude % 360;
    if (longitude > 180) longitude -= 360;
    if (longitude < -180) longitude += 360;

    // Find the appropriate time zone
    for (var zone in _timeZoneBoundaries) {
      if (longitude >= zone['min'] && longitude < zone['max']) {
        return zone['offset'];
      }
    }

    // Fallback: calculate based on 15-degree zones
    return (longitude / 15).round().toDouble();
  }

  /// Check if a year is a leap year
  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Calculate day of year
  static int _dayOfYear(DateTime date) {
    int dayOfYear = date.day;
    List<int> daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    if (_isLeapYear(date.year)) {
      daysInMonth[1] = 29;
    }

    for (int i = 0; i < date.month - 1; i++) {
      dayOfYear += daysInMonth[i];
    }

    return dayOfYear;
  }

  /// Calculate solar time offset (equation of time approximation)
  static double _equationOfTime(int dayOfYear) {
    double b = 2 * math.pi * (dayOfYear - 81) / 365;
    return 9.87 * math.sin(2 * b) - 7.53 * math.cos(b) - 1.5 * math.sin(b);
  }

  /// Calculate solar noon for a given location and date
  static DateTime _calculateSolarNoon(double longitude, DateTime date) {
    int dayOfYear = _dayOfYear(date);
    double eot = _equationOfTime(dayOfYear);

    // Solar noon occurs when the sun is directly overhead
    // Longitude correction: 4 minutes per degree
    double longitudeCorrection = longitude * 4; // minutes
    double totalCorrection = eot + longitudeCorrection;

    // Solar noon in UTC is approximately 12:00 + corrections
    DateTime utcSolarNoon = DateTime.utc(
      date.year,
      date.month,
      date.day,
      12,
      totalCorrection.round(),
    );

    return utcSolarNoon;
  }
}

class TimeResult {
  final DateTime localTime;
  final DateTime utcTime;
  final DateTime gmtTime;
  final double utcOffset;
  final String timeZone;
  final DateTime solarNoon;
  final Map<String, dynamic> additionalInfo;

  TimeResult({
    required this.localTime,
    required this.utcTime,
    required this.gmtTime,
    required this.utcOffset,
    required this.timeZone,
    required this.solarNoon,
    required this.additionalInfo,
  });

  @override
  String toString() {
    return '''
Time Calculation Results:
------------------------
Local Time: ${localTime.toString()}
UTC Time: ${utcTime.toString()}
GMT Time: ${gmtTime.toString()}
UTC Offset: ${utcOffset >= 0 ? '+' : ''}${utcOffset.toStringAsFixed(1)} hours
Time Zone: $timeZone
Solar Noon (UTC): ${solarNoon.toString()}

Additional Information:
- Day of Year: ${additionalInfo['dayOfYear']}
- Is Leap Year: ${additionalInfo['isLeapYear']}
- Equation of Time: ${additionalInfo['equationOfTime'].toStringAsFixed(2)} minutes
''';
  }
}

/// Main function to calculate GMT and UTC values from coordinates and date
TimeResult calculateTimeFromLocation(
  double latitude,
  double longitude,
  DateTime inputDate,
) {
  // Validate inputs
  if (latitude < -90 || latitude > 90) {
    throw ArgumentError('Latitude must be between -90 and 90 degrees');
  }
  if (longitude < -180 || longitude > 180) {
    throw ArgumentError('Longitude must be between -180 and 180 degrees');
  }

  // Calculate UTC offset based on longitude
  double utcOffset = LocationTimeCalculator._calculateUtcOffsetFromLongitude(
    longitude,
  );

  // Determine time zone string
  String timeZone = 'UTC${utcOffset >= 0 ? '+' : ''}${utcOffset.toInt()}';

  // Convert input date to UTC if it's not already
  DateTime utcDate = inputDate.isUtc ? inputDate : inputDate.toUtc();

  // GMT is the same as UTC (GMT = UTC)
  DateTime gmtDate = utcDate;

  // Calculate local time
  Duration offsetDuration = Duration(
    hours: utcOffset.toInt(),
    minutes: ((utcOffset % 1) * 60).round(),
  );
  DateTime localDate = utcDate.add(offsetDuration);

  // Calculate solar noon
  DateTime solarNoon = LocationTimeCalculator._calculateSolarNoon(
    longitude,
    utcDate,
  );

  // Calculate additional information
  int dayOfYear = LocationTimeCalculator._dayOfYear(utcDate);
  bool isLeapYear = LocationTimeCalculator._isLeapYear(utcDate.year);
  double equationOfTime = LocationTimeCalculator._equationOfTime(dayOfYear);

  Map<String, dynamic> additionalInfo = {
    'dayOfYear': dayOfYear,
    'isLeapYear': isLeapYear,
    'equationOfTime': equationOfTime,
    'latitude': latitude,
    'longitude': longitude,
  };

  return TimeResult(
    localTime: localDate,
    utcTime: utcDate,
    gmtTime: gmtDate,
    utcOffset: utcOffset,
    timeZone: timeZone,
    solarNoon: solarNoon,
    additionalInfo: additionalInfo,
  );
}

// Example usage and testing function
void main() {
  print('=== GMT/UTC Calculator Demo ===\n');

  // Example 1: New York City
  print('Example 1: New York City');
  double lat1 = 40.7128;
  double lng1 = -74.0060;
  DateTime date1 = DateTime.now();

  try {
    TimeResult result1 = calculateTimeFromLocation(lat1, lng1, date1);
    print(result1);
  } catch (e) {
    print('Error: $e');
  }

  print('\n' + '=' * 50 + '\n');

  // Example 2: Tokyo, Japan
  print('Example 2: Tokyo, Japan');
  double lat2 = 35.6762;
  double lng2 = 139.6503;
  DateTime date2 = DateTime(2024, 6, 15, 14, 30);

  try {
    TimeResult result2 = calculateTimeFromLocation(lat2, lng2, date2);
    print(result2);
  } catch (e) {
    print('Error: $e');
  }

  print('\n' + '=' * 50 + '\n');

  // Example 3: London, UK
  print('Example 3: London, UK');
  double lat3 = 51.5074;
  double lng3 = -0.1278;
  DateTime date3 = DateTime.utc(2024, 12, 25, 12, 0);

  try {
    TimeResult result3 = calculateTimeFromLocation(lat3, lng3, date3);
    print(result3);
  } catch (e) {
    print('Error: $e');
  }
}

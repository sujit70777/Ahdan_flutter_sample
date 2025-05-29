// import 'dart:math' as math;

// import 'package:logger/logger.dart';

// // Time Names
// const Map<String, String> timeNames = {
//   'imsak': 'Imsak',
//   'fajr': 'Fajr',
//   'sunrise': 'Sunrise',
//   'dhuhr': 'Dhuhr',
//   'asr': 'Asr',
//   'sunset': 'Sunset',
//   'maghrib': 'Maghrib',
//   'isha': 'Isha',
//   'midnight': 'Midnight',
// };

// // Calculation Methods
// const Map<String, Map<String, dynamic>> methods = {
//   'MWL': {
//     'name': 'Muslim World League',
//     'params': {'fajr': 18, 'isha': 17},
//   },
//   'ISNA': {
//     'name': 'Islamic Society of North America (ISNA)',
//     'params': {'fajr': 15, 'isha': 15},
//   },
//   'Egypt': {
//     'name': 'Egyptian General Authority of Survey',
//     'params': {'fajr': 19.5, 'isha': 17.5},
//   },
//   'Makkah': {
//     'name': 'Umm Al-Qura University, Makkah',
//     'params': {'fajr': 18.5, 'isha': '90 min'},
//   },
//   'Karachi': {
//     'name': 'University of Islamic Sciences, Karachi',
//     'params': {'fajr': 18, 'isha': 18},
//   },
//   'Tehran': {
//     'name': 'Institute of Geophysics, University of Tehran',
//     'params': {'fajr': 17.7, 'isha': 14, 'maghrib': 4.5, 'midnight': 'Jafari'},
//   },
//   'Jafari': {
//     'name': 'Shia Ithna-Ashari, Leva Institute, Qum',
//     'params': {'fajr': 16, 'isha': 14, 'maghrib': 4, 'midnight': 'Jafari'},
//   },
// };

// // Default Parameters
// const Map<String, dynamic> defaultParams = {
//   'maghrib': '0 min',
//   'midnight': 'Standard',
// };

// class PrayTimes {
//   // Default Settings
//   String _calcMethod = 'MWL';

//   Map<String, dynamic> _setting = {
//     'imsak': '10 min',
//     'dhuhr': '0 min',
//     'asr': 'Standard',
//     'highLats': 'NightMiddle',
//   };

//   String _timeFormat = '24h';
//   List<String> _timeSuffixes = ['am', 'pm'];
//   String _invalidTime = '-----';
//   int _numIterations = 1;
//   Map<String, double> _offset = {};

//   // Local Variables
//   double _lat = 0;
//   double _lng = 0;
//   double _elv = 0;
//   double _timeZone = 0;
//   double _jDate = 0;

//   // Constructor
//   PrayTimes([String method = 'MWL']) {
//     // Set methods defaults
//     for (String methodKey in methods.keys) {
//       Map<String, dynamic> params = Map.from(methods[methodKey]!['params']);
//       for (String defKey in defaultParams.keys) {
//         if (!params.containsKey(defKey)) {
//           params[defKey] = defaultParams[defKey];
//         }
//       }
//       // Update the methods map (create a mutable copy)
//     }

//     // Initialize settings
//     _calcMethod = methods.containsKey(method) ? method : _calcMethod;
//     Map<String, dynamic> params = methods[_calcMethod]!['params'];
//     for (String id in params.keys) {
//       _setting[id] = params[id];
//     }

//     // Initialize time offsets
//     for (String timeName in timeNames.keys) {
//       _offset[timeName] = 0;
//     }
//   }

//   // Set calculation method
//   void setMethod(String method) {
//     if (methods.containsKey(method)) {
//       adjust(methods[method]!['params']);
//       _calcMethod = method;
//     }
//   }

//   // Set calculating parameters
//   void adjust(Map<String, dynamic> params) {
//     for (String id in params.keys) {
//       _setting[id] = params[id];
//     }
//   }

//   // Set time offsets
//   void tune(Map<String, double> timeOffsets) {
//     for (String i in timeOffsets.keys) {
//       _offset[i] = timeOffsets[i]!;
//     }
//   }

//   // Get current calculation method
//   String getMethod() => _calcMethod;

//   // Get current setting
//   Map<String, dynamic> getSetting() => Map.from(_setting);

//   // Get current time offsets
//   Map<String, double> getOffsets() => Map.from(_offset);

//   // Get default calc parameters
//   Map<String, Map<String, dynamic>> getDefaults() => methods;

//   // Return prayer times for a given date
//   Map<String, String> getTimes(
//     dynamic date,
//     List<double> coords, [
//     dynamic timezone,
//     dynamic dst,
//     String? format,
//   ]) {
//     _lat = coords[0];
//     _lng = coords[1];
//     _elv = coords.length > 2 ? coords[2] : 0;
//     _timeFormat = format ?? _timeFormat;

//     List<int> dateArray;
//     if (date is DateTime) {
//       dateArray = [date.year, date.month, date.day];
//     } else if (date is List<int>) {
//       dateArray = date;
//     } else {
//       throw ArgumentError('Date must be DateTime or List<int>');
//     }

//     if (timezone == null || timezone == 'auto') {
//       timezone = getTimeZone(dateArray);
//     }
//     if (dst == null || dst == 'auto') {
//       dst = getDst(dateArray);
//     }

//     _timeZone =
//         (timezone is String ? double.parse(timezone) : timezone.toDouble()) +
//         (dst == true || dst == 1 ? 1 : 0);
//     _jDate =
//         julian(dateArray[0], dateArray[1], dateArray[2]) - _lng / (15 * 24);

//     return computeTimes();
//   }

//   // Convert float time to the given format
//   String getFormattedTime(
//     double time, [
//     String? format,
//     List<String>? suffixes,
//   ]) {
//     if (time.isNaN) return _invalidTime;
//     if (format == 'Float') return time.toString();

//     suffixes ??= _timeSuffixes;
//     format ??= _timeFormat;
//     // Logger().i('Formatting time: $time with format: $format');

//     time = DMath.fixHour(time + 0.5 / 60); // add 0.5 minutes to round
//     int hours = time.floor();
//     int minutes = ((time - hours) * 60).floor();
//     String suffix = (format == '12h') ? suffixes[hours < 12 ? 0 : 1] : '';
//     String hour =
//         (format == '24h')
//             ? twoDigitsFormat(hours)
//             : ((hours + 12 - 1) % 12 + 1).toString();
//     return '$hour:${twoDigitsFormat(minutes)}${suffix.isNotEmpty ? ' $suffix' : ''}';
//   }

//   // Compute mid-day time
//   double midDay(double time) {
//     Map<String, double> sunPos = sunPosition(_jDate + time);
//     double eqt = sunPos['equation']!;
//     double noon = DMath.fixHour(12 - eqt);
//     return noon;
//   }

//   // Compute the time at which sun reaches a specific angle below horizon
//   double sunAngleTime(double angle, double time, [String direction = 'cw']) {
//     Map<String, double> sunPos = sunPosition(_jDate + time);
//     double decl = sunPos['declination']!;
//     double noon = midDay(time);
//     double t =
//         (1 / 15) *
//         DMath.arccos(
//           (-DMath.sin(angle) - DMath.sin(decl) * DMath.sin(_lat)) /
//               (DMath.cos(decl) * DMath.cos(_lat)),
//         );
//     return noon + (direction == 'ccw' ? -t : t);
//   }

//   // Compute asr time
//   double asrTime(double factor, double time) {
//     Map<String, double> sunPos = sunPosition(_jDate + time);
//     double decl = sunPos['declination']!;
//     double angle = -DMath.arccot(factor + DMath.tan((_lat - decl).abs()));
//     return sunAngleTime(angle, time);
//   }

//   // Compute declination angle of sun and equation of time
//   Map<String, double> sunPosition(double jd) {
//     double D = jd - 2451545.0;
//     double g = DMath.fixAngle(357.529 + 0.98560028 * D);
//     double q = DMath.fixAngle(280.459 + 0.98564736 * D);
//     double L = DMath.fixAngle(
//       q + 1.915 * DMath.sin(g) + 0.020 * DMath.sin(2 * g),
//     );

//     double e = 23.439 - 0.00000036 * D;
//     double RA = DMath.arctan2(DMath.cos(e) * DMath.sin(L), DMath.cos(L)) / 15;
//     double eqt = q / 15 - DMath.fixHour(RA);
//     double decl = DMath.arcsin(DMath.sin(e) * DMath.sin(L));

//     return {'declination': decl, 'equation': eqt};
//   }

//   // Convert Gregorian date to Julian day
//   double julian(int year, int month, int day) {
//     if (month <= 2) {
//       year -= 1;
//       month += 12;
//     }
//     int A = (year / 100).floor();
//     int B = 2 - A + (A / 4).floor();

//     double JD =
//         (365.25 * (year + 4716)).floor().toDouble() +
//         (30.6001 * (month + 1)).floor().toDouble() +
//         day +
//         B -
//         1524.5;
//     return JD;
//   }

//   // Compute prayer times at given julian date
//   Map<String, double> computePrayerTimes(Map<String, double> times) {
//     times = dayPortion(times);
//     Map<String, dynamic> params = _setting;

//     double imsak = sunAngleTime(
//       evalParam(params['imsak']),
//       times['imsak']!,
//       'ccw',
//     );
//     double fajr = sunAngleTime(
//       evalParam(params['fajr']),
//       times['fajr']!,
//       'ccw',
//     );
//     double sunrise = sunAngleTime(riseSetAngle(), times['sunrise']!, 'ccw');
//     double dhuhr = midDay(times['dhuhr']!);
//     double asr = asrTime(asrFactor(params['asr']), times['asr']!);
//     double sunset = sunAngleTime(riseSetAngle(), times['sunset']!);
//     double maghrib = sunAngleTime(
//       evalParam(params['maghrib']),
//       times['maghrib']!,
//     );
//     double isha = sunAngleTime(evalParam(params['isha']), times['isha']!);

//     return {
//       'imsak': imsak,
//       'fajr': fajr,
//       'sunrise': sunrise,
//       'dhuhr': dhuhr,
//       'asr': asr,
//       'sunset': sunset,
//       'maghrib': maghrib,
//       'isha': isha,
//     };
//   }

//   // Compute prayer times
//   Map<String, String> computeTimes() {
//     // Default times
//     Map<String, double> times = {
//       'imsak': 5,
//       'fajr': 5,
//       'sunrise': 6,
//       'dhuhr': 12,
//       'asr': 13,
//       'sunset': 18,
//       'maghrib': 18,
//       'isha': 18,
//     };

//     // Main iterations
//     for (int i = 1; i <= _numIterations; i++) {
//       times = computePrayerTimes(times);
//     }

//     times = adjustTimes(times);

//     // Add midnight time
//     times['midnight'] =
//         (_setting['midnight'] == 'Jafari')
//             ? times['sunset']! + timeDiff(times['sunset']!, times['fajr']!) / 2
//             : times['sunset']! +
//                 timeDiff(times['sunset']!, times['sunrise']!) / 2;

//     times = tuneTimes(times);
//     return modifyFormats(times);
//   }

//   // Adjust times
//   Map<String, double> adjustTimes(Map<String, double> times) {
//     Map<String, dynamic> params = _setting;

//     for (String i in times.keys) {
//       times[i] = times[i]! + _timeZone - _lng / 15;
//     }

//     if (params['highLats'] != 'None') {
//       times = adjustHighLats(times);
//     }

//     if (isMin(params['imsak'])) {
//       times['imsak'] = times['fajr']! - evalParam(params['imsak']) / 60;
//     }
//     if (isMin(params['maghrib'])) {
//       times['maghrib'] = times['sunset']! + evalParam(params['maghrib']) / 60;
//     }
//     if (isMin(params['isha'])) {
//       times['isha'] = times['maghrib']! + evalParam(params['isha']) / 60;
//     }
//     times['dhuhr'] = times['dhuhr']! + evalParam(params['dhuhr']) / 60;

//     return times;
//   }

//   // Get asr shadow factor
//   double asrFactor(dynamic asrParam) {
//     Map<String, int> factors = {'Standard': 1, 'Hanafi': 2};
//     return factors[asrParam]?.toDouble() ?? evalParam(asrParam);
//   }

//   // Return sun angle for sunset/sunrise
//   double riseSetAngle() {
//     double angle = 0.0347 * math.sqrt(_elv); // approximation
//     return 0.833 + angle;
//   }

//   // Apply offsets to the times
//   Map<String, double> tuneTimes(Map<String, double> times) {
//     for (String i in times.keys) {
//       times[i] = times[i]! + (_offset[i] ?? 0) / 60;
//     }
//     return times;
//   }

//   // Convert times to given time format
//   Map<String, String> modifyFormats(Map<String, double> times) {
//     Map<String, String> result = {};
//     for (String i in times.keys) {
//       // Logger(level: Level.trace).f('Formatting time for $i: ${times[i]}');
//       result[i] = getFormattedTime(times[i]!, _timeFormat);
//     }
//     return result;
//   }

//   // Adjust times for locations in higher latitudes
//   Map<String, double> adjustHighLats(Map<String, double> times) {
//     Map<String, dynamic> params = _setting;
//     double nightTime = timeDiff(times['sunset']!, times['sunrise']!);

//     times['imsak'] = adjustHLTime(
//       times['imsak']!,
//       times['sunrise']!,
//       evalParam(params['imsak']),
//       nightTime,
//       'ccw',
//     );
//     times['fajr'] = adjustHLTime(
//       times['fajr']!,
//       times['sunrise']!,
//       evalParam(params['fajr']),
//       nightTime,
//       'ccw',
//     );
//     times['isha'] = adjustHLTime(
//       times['isha']!,
//       times['sunset']!,
//       evalParam(params['isha']),
//       nightTime,
//     );
//     times['maghrib'] = adjustHLTime(
//       times['maghrib']!,
//       times['sunset']!,
//       evalParam(params['maghrib']),
//       nightTime,
//     );

//     return times;
//   }

//   // Adjust a time for higher latitudes
//   double adjustHLTime(
//     double time,
//     double base,
//     double angle,
//     double night, [
//     String direction = 'cw',
//   ]) {
//     double portion = nightPortion(angle, night);
//     double timeDiff =
//         (direction == 'ccw')
//             ? this.timeDiff(time, base)
//             : this.timeDiff(base, time);
//     if (time.isNaN || timeDiff > portion) {
//       time = base + (direction == 'ccw' ? -portion : portion);
//     }
//     return time;
//   }

//   // The night portion used for adjusting times in higher latitudes
//   double nightPortion(double angle, double night) {
//     String method = _setting['highLats'];
//     double portion = 1 / 2; // MidNight
//     if (method == 'AngleBased') {
//       portion = 1 / 60 * angle;
//     }
//     if (method == 'OneSeventh') {
//       portion = 1 / 7;
//     }
//     return portion * night;
//   }

//   // Convert hours to day portions
//   Map<String, double> dayPortion(Map<String, double> times) {
//     for (String i in times.keys) {
//       times[i] = times[i]! / 24;
//     }
//     return times;
//   }

//   // Get local time zone
//   double getTimeZone(List<int> date) {
//     int year = date[0];
//     double t1 = gmtOffset([year, 1, 1]);
//     double t2 = gmtOffset([year, 7, 1]);
//     return math.min(t1, t2);
//   }

//   // Get daylight saving for a given date
//   bool getDst(List<int> date) {
//     return gmtOffset(date) != getTimeZone(date);
//   }

//   // GMT offset for a given date
//   double gmtOffset(List<int> date) {
//     DateTime localDate = DateTime(date[0], date[1], date[2], 12, 0, 0);
//     DateTime utcDate = localDate.toUtc();
//     double hoursDiff =
//         (localDate.millisecondsSinceEpoch - utcDate.millisecondsSinceEpoch) /
//         (1000 * 60 * 60);
//     return hoursDiff;
//   }

//   // Convert given string into a number
//   double evalParam(dynamic str) {
//     if (str is num) return str.toDouble();
//     String strValue = str.toString();
//     RegExp regex = RegExp(r'[0-9.+-]+');
//     Match? match = regex.firstMatch(strValue);
//     return match != null ? double.parse(match.group(0)!) : 0.0;
//   }

//   // Detect if input contains 'min'
//   bool isMin(dynamic arg) {
//     return arg.toString().contains('min');
//   }

//   // Compute the difference between two times
//   double timeDiff(double time1, double time2) {
//     return DMath.fixHour(time2 - time1);
//   }

//   // Add a leading 0 if necessary
//   String twoDigitsFormat(int num) {
//     return num < 10 ? '0$num' : num.toString();
//   }
// }

// // Degree-Based Math Class
// class DMath {
//   static double dtr(double d) => (d * math.pi) / 180.0;
//   static double rtd(double r) => (r * 180.0) / math.pi;

//   static double sin(double d) => math.sin(dtr(d));
//   static double cos(double d) => math.cos(dtr(d));
//   static double tan(double d) => math.tan(dtr(d));

//   static double arcsin(double d) => rtd(math.asin(d));
//   static double arccos(double d) => rtd(math.acos(d));
//   static double arctan(double d) => rtd(math.atan(d));

//   static double arccot(double x) => rtd(math.atan(1 / x));
//   static double arctan2(double y, double x) => rtd(math.atan2(y, x));

//   static double fixAngle(double a) => fix(a, 360);
//   static double fixHour(double a) {
//     if (a == 25.305312850695834) {
//       Logger(level: Level.trace).d('Fixing $a ');
//     }
//     return fix(a, 24);
//   }

//   static double fix(double a, double b) {
//     if (b == 24 && a == 25.305312850695834) {
//       // Logger(level: Level.trace).d('Fixing $a with modulus $b');
//     }

//     if (a.isNaN || a.isInfinite || b.isNaN || b.isInfinite || b == 0) {
//       return double.nan;
//     }
//     a = a - b * (a / b).floor();
//     return (a < 0) ? a + b : a;
//   }
// }

// // // Usage Example:
// // void main() {
// //   PrayTimes pt = PrayTimes('ISNA');
// //   Map<String, String> times = pt.getTimes(DateTime.now(), [
// //     60.1699,
// //     24.9384,
// //   ], 3);
// //   print('Sunrise: ${times['sunrise']}');
// //   print('Fajr: ${times['fajr']}');
// //   print('Dhuhr: ${times['dhuhr']}');
// //   print('Asr: ${times['asr']}');
// //   print('Maghrib: ${times['maghrib']}');
// //   print('Isha: ${times['isha']}');
// // }

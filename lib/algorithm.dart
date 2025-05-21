import 'dart:math';

/// Calculates Islamic prayer times for a given location and date using the MWL method.
///
/// Parameters:
/// - [latitude]: Latitude in degrees (e.g., 60.1695 for Helsinki).
/// - [longitude]: Longitude in degrees (e.g., 24.9354 for Helsinki).
/// - [date]: Local date for which to calculate prayer times.
/// - [timeZoneOffset]: Time zone offset in hours (e.g., 3 for UTC+3).
/// - [isHanafi]: True for Hanafi Asr calculation (shadow = 2x), false for Shafi'i (1x).
/// - [fajrAngle]: MWL Fajr angle (default: 18°).
/// - [ishaAngle]: MWL Isha angle (default: 17°).
///
/// Returns a map of prayer names to their local DateTime values.
Map<String, DateTime> calculatePrayerTimes({
  required double latitude,
  required double longitude,
  required DateTime date,
  required double timeZoneOffset,
  bool isHanafi = true,
  double fajrAngle = 18.0,
  double ishaAngle = 17.0,
}) {
  // Helper functions
  double degreesToRadians(double degrees) => degrees * pi / 180;
  double radiansToDegrees(double radians) => radians * 180 / pi;

  // Calculate Julian Day for UTC midnight
  final localMidnight = DateTime(date.year, date.month, date.day, 0, 0, 0);
  final utcMidnight = localMidnight.subtract(
    Duration(hours: timeZoneOffset.toInt()),
  );
  double calculateJulianDay(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = (a / 4).floor();
    final c = 2 - a + b;
    final e = (365.25 * (year + 4716)).floor();
    final f = (30.6001 * (month + 1)).floor();
    return c + day + e + f - 1524.5;
  }

  final jd = calculateJulianDay(
    utcMidnight.year,
    utcMidnight.month,
    utcMidnight.day,
  );

  // Step 1: Calculate solar coordinates
  final t = jd - 2451545.0;
  final meanAnomaly = (357.5291 + 0.98560028 * t) % 360;
  final eclipticLongitude =
      (meanAnomaly +
          1.9148 * sin(degreesToRadians(meanAnomaly)) +
          0.0200 * sin(degreesToRadians(2 * meanAnomaly)) +
          282.634) %
      360;
  final obliquity = 23.439 - 0.00000036 * t;
  final declination = radiansToDegrees(
    asin(
      sin(degreesToRadians(obliquity)) *
          sin(degreesToRadians(eclipticLongitude)),
    ),
  );

  // Step 2: Calculate equation of time and solar noon
  final equationOfTime =
      0.0053 * sin(degreesToRadians(meanAnomaly)) -
      0.0069 * sin(degreesToRadians(2 * eclipticLongitude));
  final transitUtcHours = 12 - (longitude / 15) - equationOfTime;
  final transitUtc = utcMidnight.add(
    Duration(
      microseconds: ((transitUtcHours / 24) * 24 * 60 * 60 * 1000000).round(),
    ),
  );

  // Step 3: Calculate hour angles for prayer times
  double calculateHourAngle(double altitude) {
    final cosH =
        (sin(degreesToRadians(altitude)) -
            sin(degreesToRadians(latitude)) *
                sin(degreesToRadians(declination))) /
        (cos(degreesToRadians(latitude)) * cos(degreesToRadians(declination)));
    return cosH >= -1 && cosH <= 1 ? acos(cosH) : double.nan;
  }

  // Sunrise and sunset (h = 0°)
  final hSunrise = calculateHourAngle(0);
  final hSunset = hSunrise;

  // Fajr (h = -18°)
  final hFajr = calculateHourAngle(-fajrAngle);

  // Isha (h = -17°)
  final hIsha = calculateHourAngle(-ishaAngle);

  // Asr (Hanafi: shadow = 2x, Shafi'i: 1x)
  final shadowFactor = isHanafi ? 2.0 : 1.0;
  final asrAltitude = radiansToDegrees(
    atan(
      1 / (shadowFactor + tan(degreesToRadians(latitude - declination).abs())),
    ),
  );
  final hAsr = calculateHourAngle(asrAltitude);

  // Step 4: Convert hour angles to times in UTC
  DateTime timeFromHourAngle(double hRadians, bool isBeforeNoon) {
    final hDegrees = radiansToDegrees(hRadians);
    final offsetHours = isBeforeNoon ? -hDegrees / 15 : hDegrees / 15;
    final offsetMicroseconds = (offsetHours * 60 * 60 * 1000000).round();
    return transitUtc.add(Duration(microseconds: offsetMicroseconds));
  }

  final sunriseUtc = timeFromHourAngle(hSunrise, true);
  final sunsetUtc = timeFromHourAngle(hSunset, false);
  var fajrUtc = hFajr.isNaN ? null : timeFromHourAngle(hFajr, true);
  var ishaUtc = hIsha.isNaN ? null : timeFromHourAngle(hIsha, false);
  final asrUtc = timeFromHourAngle(hAsr, false);
  final dhuhrUtc = transitUtc.add(Duration(minutes: 2)); // 2 min after noon

  // Step 5: High latitude adjustment for Fajr and Isha
  if (fajrUtc == null || ishaUtc == null) {
    final nightDuration =
        sunriseUtc
            .add(Duration(days: 1))
            .difference(sunsetUtc)
            .inSeconds; // Approximate next sunrise
    final seventhNight = nightDuration / 7;
    fajrUtc ??= sunriseUtc.subtract(Duration(seconds: seventhNight.toInt()));
    ishaUtc ??= sunsetUtc.add(Duration(seconds: seventhNight.toInt()));
  }

  // Step 6: Convert to local time
  final localOffset = Duration(hours: timeZoneOffset.toInt());
  return {
    'Fajr': fajrUtc.add(localOffset),
    'Dhuhr': dhuhrUtc.add(localOffset),
    'Asr': asrUtc.add(localOffset),
    'Maghrib': sunsetUtc.add(localOffset),
    'Isha': ishaUtc.add(localOffset),
  };
}

// Example usage
void main() {
  final prayerTimes = calculatePrayerTimes(
    latitude: 60.1695,
    longitude: 24.9354,
    date: DateTime.utc(2025, 5, 18), // Use UTC date to align with JD
    timeZoneOffset: 3.0,
  );
  prayerTimes.forEach((prayer, timeUtc) {
    // Add offset to UTC time
    var timeZoneOffset = 3.0; // Example offset for UTC+3
    final totalMinutes =
        timeUtc.hour * 60 + timeUtc.minute + (timeZoneOffset.toInt() * 60);
    final localHour = (totalMinutes ~/ 60) % 24;
    final localMinute = totalMinutes % 60;
    print(
      '$prayer: ${localHour.toString().padLeft(2, '0')}:${localMinute.toString().padLeft(2, '0')}',
    );
  });
}

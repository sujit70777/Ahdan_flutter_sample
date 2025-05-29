// import 'dart:math' as math;

// // Timezone data structure
// class TimezoneInfo {
//   final String id;
//   final String name;
//   final double offsetHours;
//   final bool observesDST;
//   final List<List<double>>
//   boundaries; // List of [lat, lng] points defining the boundary
//   final double centerLat;
//   final double centerLng;

//   TimezoneInfo({
//     required this.id,
//     required this.name,
//     required this.offsetHours,
//     required this.observesDST,
//     required this.boundaries,
//     required this.centerLat,
//     required this.centerLng,
//   });
// }

// class TimezoneDatabase {
//   static final List<TimezoneInfo> _timezones = [
//     // North America
//     TimezoneInfo(
//       id: 'America/New_York',
//       name: 'Eastern Time',
//       offsetHours: -5.0,
//       observesDST: true,
//       centerLat: 40.7128,
//       centerLng: -74.0060,
//       boundaries: [
//         [50.0, -65.0],
//         [25.0, -65.0],
//         [25.0, -85.0],
//         [50.0, -85.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'America/Chicago',
//       name: 'Central Time',
//       offsetHours: -6.0,
//       observesDST: true,
//       centerLat: 41.8781,
//       centerLng: -87.6298,
//       boundaries: [
//         [50.0, -85.0],
//         [25.0, -85.0],
//         [25.0, -105.0],
//         [50.0, -105.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'America/Denver',
//       name: 'Mountain Time',
//       offsetHours: -7.0,
//       observesDST: true,
//       centerLat: 39.7392,
//       centerLng: -104.9903,
//       boundaries: [
//         [50.0, -105.0],
//         [25.0, -105.0],
//         [25.0, -125.0],
//         [50.0, -125.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'America/Los_Angeles',
//       name: 'Pacific Time',
//       offsetHours: -8.0,
//       observesDST: true,
//       centerLat: 34.0522,
//       centerLng: -118.2437,
//       boundaries: [
//         [50.0, -125.0],
//         [25.0, -125.0],
//         [25.0, -130.0],
//         [50.0, -130.0],
//       ],
//     ),

//     // Europe
//     TimezoneInfo(
//       id: 'Europe/London',
//       name: 'Greenwich Mean Time',
//       offsetHours: 0.0,
//       observesDST: true,
//       centerLat: 51.5074,
//       centerLng: -0.1278,
//       boundaries: [
//         [60.0, -8.0],
//         [49.0, -8.0],
//         [49.0, 2.0],
//         [60.0, 2.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'Europe/Paris',
//       name: 'Central European Time',
//       offsetHours: 1.0,
//       observesDST: true,
//       centerLat: 48.8566,
//       centerLng: 2.3522,
//       boundaries: [
//         [55.0, 2.0],
//         [35.0, 2.0],
//         [35.0, 15.0],
//         [55.0, 15.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'Europe/Berlin',
//       name: 'Central European Time',
//       offsetHours: 1.0,
//       observesDST: true,
//       centerLat: 52.5200,
//       centerLng: 13.4050,
//       boundaries: [
//         [55.0, 5.0],
//         [47.0, 5.0],
//         [47.0, 25.0],
//         [55.0, 25.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'Europe/Moscow',
//       name: 'Moscow Time',
//       offsetHours: 3.0,
//       observesDST: false,
//       centerLat: 55.7558,
//       centerLng: 37.6176,
//       boundaries: [
//         [70.0, 25.0],
//         [45.0, 25.0],
//         [45.0, 50.0],
//         [70.0, 50.0],
//       ],
//     ),

//     // Asia
//     TimezoneInfo(
//       id: 'Asia/Tokyo',
//       name: 'Japan Standard Time',
//       offsetHours: 9.0,
//       observesDST: false,
//       centerLat: 35.6762,
//       centerLng: 139.6503,
//       boundaries: [
//         [46.0, 129.0],
//         [24.0, 129.0],
//         [24.0, 146.0],
//         [46.0, 146.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'Asia/Shanghai',
//       name: 'China Standard Time',
//       offsetHours: 8.0,
//       observesDST: false,
//       centerLat: 31.2304,
//       centerLng: 121.4737,
//       boundaries: [
//         [54.0, 73.0],
//         [18.0, 73.0],
//         [18.0, 135.0],
//         [54.0, 135.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'Asia/Kolkata',
//       name: 'India Standard Time',
//       offsetHours: 5.5,
//       observesDST: false,
//       centerLat: 28.6139,
//       centerLng: 77.2090,
//       boundaries: [
//         [37.0, 68.0],
//         [6.0, 68.0],
//         [6.0, 97.0],
//         [37.0, 97.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'Asia/Dubai',
//       name: 'Gulf Standard Time',
//       offsetHours: 4.0,
//       observesDST: false,
//       centerLat: 25.2048,
//       centerLng: 55.2708,
//       boundaries: [
//         [32.0, 51.0],
//         [22.0, 51.0],
//         [22.0, 60.0],
//         [32.0, 60.0],
//       ],
//     ),

//     // Australia
//     TimezoneInfo(
//       id: 'Australia/Sydney',
//       name: 'Australian Eastern Time',
//       offsetHours: 10.0,
//       observesDST: true,
//       centerLat: -33.8688,
//       centerLng: 151.2093,
//       boundaries: [
//         [-28.0, 140.0],
//         [-44.0, 140.0],
//         [-44.0, 155.0],
//         [-28.0, 155.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'Australia/Melbourne',
//       name: 'Australian Eastern Time',
//       offsetHours: 10.0,
//       observesDST: true,
//       centerLat: -37.8136,
//       centerLng: 144.9631,
//       boundaries: [
//         [-34.0, 140.0],
//         [-39.0, 140.0],
//         [-39.0, 150.0],
//         [-34.0, 150.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'Australia/Perth',
//       name: 'Australian Western Time',
//       offsetHours: 8.0,
//       observesDST: false,
//       centerLat: -31.9505,
//       centerLng: 115.8605,
//       boundaries: [
//         [-13.0, 112.0],
//         [-35.0, 112.0],
//         [-35.0, 130.0],
//         [-13.0, 130.0],
//       ],
//     ),

//     // South America
//     TimezoneInfo(
//       id: 'America/Sao_Paulo',
//       name: 'Brasilia Time',
//       offsetHours: -3.0,
//       observesDST: true,
//       centerLat: -23.5505,
//       centerLng: -46.6333,
//       boundaries: [
//         [5.0, -75.0],
//         [-35.0, -75.0],
//         [-35.0, -34.0],
//         [5.0, -34.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'America/Argentina/Buenos_Aires',
//       name: 'Argentina Time',
//       offsetHours: -3.0,
//       observesDST: false,
//       centerLat: -34.6118,
//       centerLng: -58.3960,
//       boundaries: [
//         [-21.0, -74.0],
//         [-55.0, -74.0],
//         [-55.0, -53.0],
//         [-21.0, -53.0],
//       ],
//     ),

//     // Africa
//     TimezoneInfo(
//       id: 'Africa/Cairo',
//       name: 'Eastern European Time',
//       offsetHours: 2.0,
//       observesDST: false,
//       centerLat: 30.0444,
//       centerLng: 31.2357,
//       boundaries: [
//         [32.0, 25.0],
//         [22.0, 25.0],
//         [22.0, 37.0],
//         [32.0, 37.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'Africa/Johannesburg',
//       name: 'South Africa Standard Time',
//       offsetHours: 2.0,
//       observesDST: false,
//       centerLat: -26.2041,
//       centerLng: 28.0473,
//       boundaries: [
//         [-22.0, 16.0],
//         [-35.0, 16.0],
//         [-35.0, 33.0],
//         [-22.0, 33.0],
//       ],
//     ),

//     // Special cases and islands
//     TimezoneInfo(
//       id: 'Pacific/Honolulu',
//       name: 'Hawaii-Aleutian Time',
//       offsetHours: -10.0,
//       observesDST: false,
//       centerLat: 21.3099,
//       centerLng: -157.8581,
//       boundaries: [
//         [23.0, -162.0],
//         [18.0, -162.0],
//         [18.0, -154.0],
//         [23.0, -154.0],
//       ],
//     ),
//     TimezoneInfo(
//       id: 'Pacific/Auckland',
//       name: 'New Zealand Time',
//       offsetHours: 12.0,
//       observesDST: true,
//       centerLat: -36.8485,
//       centerLng: 174.7633,
//       boundaries: [
//         [-34.0, 166.0],
//         [-47.0, 166.0],
//         [-47.0, 179.0],
//         [-34.0, 179.0],
//       ],
//     ),
//   ];

//   /// Calculate the distance between two points using Haversine formula
//   static double _calculateDistance(
//     double lat1,
//     double lng1,
//     double lat2,
//     double lng2,
//   ) {
//     const double earthRadius = 6371.0; // Earth's radius in kilometers

//     double dLat = _degreesToRadians(lat2 - lat1);
//     double dLng = _degreesToRadians(lng2 - lng1);

//     double a =
//         math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(_degreesToRadians(lat1)) *
//             math.cos(_degreesToRadians(lat2)) *
//             math.sin(dLng / 2) *
//             math.sin(dLng / 2);

//     double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

//     return earthRadius * c;
//   }

//   static double _degreesToRadians(double degrees) {
//     return degrees * (math.pi / 180);
//   }

//   /// Check if a point is inside a polygon using ray casting algorithm
//   static bool _isPointInPolygon(
//     double lat,
//     double lng,
//     List<List<double>> polygon,
//   ) {
//     int intersectCount = 0;

//     for (int i = 0; i < polygon.length; i++) {
//       int j = (i + 1) % polygon.length;

//       double lat1 = polygon[i][0];
//       double lng1 = polygon[i][1];
//       double lat2 = polygon[j][0];
//       double lng2 = polygon[j][1];

//       if (((lat1 > lat) != (lat2 > lat)) &&
//           (lng < (lng2 - lng1) * (lat - lat1) / (lat2 - lat1) + lng1)) {
//         intersectCount++;
//       }
//     }

//     return intersectCount % 2 == 1;
//   }

//   /// Get timezone information for given latitude and longitude
//   static TimezoneInfo? getTimezoneByCoordinates(double lat, double lng) {
//     // Validate input
//     if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
//       throw ArgumentError(
//         'Invalid coordinates: lat must be between -90 and 90, lng must be between -180 and 180',
//       );
//     }

//     TimezoneInfo? bestMatch;
//     double minDistance = double.infinity;

//     // First, try to find exact boundary matches
//     for (TimezoneInfo timezone in _timezones) {
//       if (_isPointInPolygon(lat, lng, timezone.boundaries)) {
//         return timezone;
//       }
//     }

//     // If no exact match, find the closest timezone by distance to center
//     for (TimezoneInfo timezone in _timezones) {
//       double distance = _calculateDistance(
//         lat,
//         lng,
//         timezone.centerLat,
//         timezone.centerLng,
//       );

//       if (distance < minDistance) {
//         minDistance = distance;
//         bestMatch = timezone;
//       }
//     }

//     return bestMatch;
//   }

//   /// Get all available timezones
//   static List<TimezoneInfo> getAllTimezones() {
//     return List.unmodifiable(_timezones);
//   }

//   /// Get timezone by ID
//   static TimezoneInfo? getTimezoneById(String id) {
//     try {
//       return _timezones.firstWhere((tz) => tz.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   /// Calculate current UTC offset considering DST
//   static double getCurrentOffset(TimezoneInfo timezone, DateTime? dateTime) {
//     dateTime ??= DateTime.now();

//     if (!timezone.observesDST) {
//       return timezone.offsetHours;
//     }

//     // Simple DST calculation (this is a simplified version)
//     // In practice, you'd want more precise DST rules for each timezone
//     bool isDST = _isDSTActive(timezone, dateTime);
//     return timezone.offsetHours + (isDST ? 1.0 : 0.0);
//   }

//   /// Simplified DST calculation
//   static bool _isDSTActive(TimezoneInfo timezone, DateTime dateTime) {
//     int month = dateTime.month;
//     int day = dateTime.day;

//     // Northern hemisphere DST (March to November)
//     if (timezone.centerLat > 0) {
//       if (month > 3 && month < 11) return true;
//       if (month == 3 && day >= 14) return true;
//       if (month == 11 && day < 7) return true;
//     }
//     // Southern hemisphere DST (October to March)
//     else {
//       if (month > 10 || month < 3) return true;
//       if (month == 10 && day >= 7) return true;
//       if (month == 3 && day < 14) return true;
//     }

//     return false;
//   }

//   /// Convert time from one timezone to another
//   static DateTime convertTime(
//     DateTime sourceTime,
//     TimezoneInfo fromTimezone,
//     TimezoneInfo toTimezone,
//   ) {
//     double fromOffset = getCurrentOffset(fromTimezone, sourceTime);
//     double toOffset = getCurrentOffset(toTimezone, sourceTime);

//     // Convert to UTC first, then to target timezone
//     DateTime utcTime = sourceTime.subtract(
//       Duration(
//         hours: fromOffset.floor(),
//         minutes: ((fromOffset % 1) * 60).round(),
//       ),
//     );
//     DateTime targetTime = utcTime.add(
//       Duration(hours: toOffset.floor(), minutes: ((toOffset % 1) * 60).round()),
//     );

//     return targetTime;
//   }
// }

// // Example usage and testing
// void main() {
//   print('=== Timezone Database Test ===\n');

//   // Test coordinates
//   List<Map<String, dynamic>> testLocations = [
//     {'name': 'New York', 'lat': 40.7128, 'lng': -74.0060},
//     {'name': 'London', 'lat': 51.5074, 'lng': -0.1278},
//     {'name': 'Tokyo', 'lat': 35.6762, 'lng': 139.6503},
//     {'name': 'Sydney', 'lat': -33.8688, 'lng': 151.2093},
//     {'name': 'Dubai', 'lat': 25.2048, 'lng': 55.2708},
//     {'name': 'Los Angeles', 'lat': 34.0522, 'lng': -118.2437},
//     {'name': 'São Paulo', 'lat': -23.5505, 'lng': -46.6333},
//     {'name': 'Mumbai', 'lat': 19.0760, 'lng': 72.8777},
//   ];

//   // Test timezone lookup
//   for (Map<String, dynamic> location in testLocations) {
//     TimezoneInfo? timezone = TimezoneDatabase.getTimezoneByCoordinates(
//       location['lat'],
//       location['lng'],
//     );

//     if (timezone != null) {
//       double currentOffset = TimezoneDatabase.getCurrentOffset(
//         timezone,
//         DateTime.now(),
//       );
//       print('📍 ${location['name']}:');
//       print('   Timezone: ${timezone.name} (${timezone.id})');
//       print(
//         '   Base Offset: ${timezone.offsetHours > 0 ? '+' : ''}${timezone.offsetHours}h',
//       );
//       print(
//         '   Current Offset: ${currentOffset > 0 ? '+' : ''}${currentOffset}h',
//       );
//       print('   Observes DST: ${timezone.observesDST ? 'Yes' : 'No'}');
//       print('');
//     } else {
//       print('❌ No timezone found for ${location['name']}');
//     }
//   }

//   // Test time conversion
//   print('=== Time Conversion Test ===');
//   TimezoneInfo? nyTimezone = TimezoneDatabase.getTimezoneById(
//     'America/New_York',
//   );
//   TimezoneInfo? londonTimezone = TimezoneDatabase.getTimezoneById(
//     'Europe/London',
//   );

//   if (nyTimezone != null && londonTimezone != null) {
//     DateTime nyTime = DateTime(2024, 6, 15, 14, 30); // 2:30 PM in NY
//     DateTime londonTime = TimezoneDatabase.convertTime(
//       nyTime,
//       nyTimezone,
//       londonTimezone,
//     );

//     print('🕐 ${nyTime.toString()} in New York');
//     print('🕐 ${londonTime.toString()} in London');
//   }

//   // Test error handling
//   print('\n=== Error Handling Test ===');
//   try {
//     TimezoneDatabase.getTimezoneByCoordinates(91.0, 0.0); // Invalid latitude
//   } catch (e) {
//     print('✅ Caught invalid latitude error: $e');
//   }

//   print('\n=== Available Timezones ===');
//   List<TimezoneInfo> allTimezones = TimezoneDatabase.getAllTimezones();
//   print('Total timezones in database: ${allTimezones.length}');

//   for (TimezoneInfo tz in allTimezones.take(5)) {
//     print('• ${tz.name} (${tz.id}) - Offset: ${tz.offsetHours}h');
//   }
//   print('... and ${allTimezones.length - 5} more');
// }

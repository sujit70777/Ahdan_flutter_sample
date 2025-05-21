import ephem
from datetime import datetime, timedelta
import math

# Set up observer for Helsinki
observer = ephem.Observer()
observer.lat = '60.17'  # Latitude of Helsinki
observer.lon = '24.94'  # Longitude of Helsinki
observer.elevation = 0  # Sea level
observer.pressure = 0   # Disable atmospheric refraction
observer.horizon = '0'  # Standard horizon for sunrise/sunset

# Set date to May 19, 2025, 12:00 UTC to capture May 20 events
observer.date = '2025/05/19 12:00:00'

# Sun object
sun = ephem.Sun()

# Calculate sunset and sunrise (horizon = 0 degrees)
sunset_utc = observer.next_setting(sun).datetime()
observer.date = sunset_utc
sunrise_utc = observer.next_rising(sun).datetime()

# Calculate night duration in hours
night_duration = (sunrise_utc - sunset_utc).total_seconds() / 3600.0

# Find midpoint of the night (approximate time of minimum altitude)
midpoint_utc = sunset_utc + timedelta(hours=night_duration / 2)
observer.date = midpoint_utc
sun.compute(observer)
min_altitude = math.degrees(sun.alt)  # Convert radians to degrees

# Define prayer times
safety_margin = timedelta(minutes=2)  # 2-minute buffer

if min_altitude > -17:
    # Use "One-Seventh" method for persistent twilight
    segment = night_duration / 7
    isha_utc = sunset_utc + timedelta(hours=segment) + safety_margin
    fajr_utc = sunrise_utc - timedelta(hours=segment) + safety_margin
else:
    # Use standard method
    observer.horizon = '-17'  # For Isha
    isha_utc = observer.next_setting(sun, use_center=True).datetime() + safety_margin
    observer.horizon = '-18'  # For Fajr
    observer.date = sunrise_utc
    fajr_utc = observer.previous_rising(sun, start=sunrise_utc, use_center=True).datetime() + safety_margin

# Calculate solar noon for Dhuhr
observer.date = sunset_utc
solar_noon_utc = observer.next_transit(sun).datetime()
dhuhr_utc = solar_noon_utc + timedelta(minutes=5)  # 5 minutes after noon

# Calculate Asr (shadow ratio = 1)
sun.compute(solar_noon_utc)
declination = sun.dec
latitude = math.radians(60.17)
shadow_ratio = 1
phi = latitude
delta = declination
tan_phi_delta = math.tan(abs(phi - delta))
target = math.atan(1 / (shadow_ratio + tan_phi_delta))
sin_target = math.sin(target)
cos_H = (sin_target - math.sin(phi) * math.sin(delta)) / (math.cos(phi) * math.cos(delta))
H = math.acos(cos_H)
asr_utc = solar_noon_utc + timedelta(hours=H / 15)

# Maghrib is sunset
maghrib_utc = sunset_utc + safety_margin

# Convert to EEST (UTC+3)
local_offset = timedelta(hours=3)
fajr_local = fajr_utc + local_offset
sunrise_local = sunrise_utc + local_offset
dhuhr_local = dhuhr_utc + local_offset
asr_local = asr_utc + local_offset
maghrib_local = maghrib_utc + local_offset
isha_local = isha_utc + local_offset

# Format time in 12-hour format
def format_time(dt):
    return dt.strftime('%I:%M %p').lstrip('0')

# Display prayer times
print("Prayer Times for Helsinki, Finland on May 20, 2025 (EEST):")
print(f"Fajr: {format_time(fajr_local)}")
print(f"Sunrise: {format_time(sunrise_local)}")
print(f"Dhuhr: {format_time(dhuhr_local)}")
print(f"Asr: {format_time(asr_local)}")
print(f"Maghrib: {format_time(maghrib_local)}")
print(f"Isha: {format_time(isha_local)}")
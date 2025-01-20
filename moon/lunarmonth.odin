package moon

import "core:time"

// 2,551,442,976 ms = 29.53059 days = mean synodic month
LUNARMONTH := time.Millisecond * 2_551_442_976

calibrate_lunar_month :: proc() {
    jd := julian_date()
    t := (jd - 2451545.0) / 36525
    duration := 29.5305888531 + (0.00000021621 * t) - (3.64E-10 * t * t)
    duration *= f64(time.Second * time.SECONDS_PER_DAY)
    LUNARMONTH = time.Duration(duration)
}

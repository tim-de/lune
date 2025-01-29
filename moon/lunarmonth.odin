package moon

import "core:time"

// 2,551,442,976 ms = 29.53059 days = mean synodic month
LUNARMONTH := time.Millisecond * 2_551_442_976

calibrate_lunar_month :: proc() {
    LUNARMONTH = get_lunar_month()
}

get_lunar_month :: proc { lunar_month_of_time, current_lunar_month }

lunar_month_of_time :: proc(t: time.Time) -> time.Duration {
    jd := julian_date(t)
    t := (jd - 2451545.0) / 36525
    duration := 29.5305888531 + (0.00000021621 * t) - (3.64E-10 * t * t)
    duration *= f64(time.Second * time.SECONDS_PER_DAY)
    return time.Duration(duration)
}

current_lunar_month :: proc() -> time.Duration {
    return lunar_month_of_time(time.now())
}

package moon

import "core:time"

julian_date :: proc {
    julian_date_of_time,
    current_julian_date,
}

julian_date_of_time :: proc(t: time.Time) -> f64 {
    return (f64(t._nsec) / f64(time.Second * time.SECONDS_PER_DAY)) + 2440587.5
}

current_julian_date :: proc() -> f64 {
    return julian_date_of_time(time.now())
}

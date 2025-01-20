package main

import "core:fmt"
import "core:time"
import "core:os"

import "moon"

output_format :: "{{\"text\": \"%r\", \"tooltip\": \"%s +%dd %dh %dm\\n%s -%dd %dh %dm\"}}"

main :: proc() {
    if len(os.args) < 2 {
        os.exit(1)
    }
    cachefile := os.args[1]
    moon.calibrate_lunar_month()
    //fmt.println(get_duration_elements(moon.LUNARMONTH))
    last_new_moon, ok := moon.get_last_new_moon(cachefile)
    //fmt.println(last_new_moon)
    age := moon.find_moon_age(last_new_moon)
    frac := moon.find_month_fraction(age)
    phase, time_since_phase := moon.find_phase_info(frac)
    days, hours, minutes := get_duration_elements(time_since_phase)
    next_phase := moon.next_phase(phase)
    time_to_phase := moon.time_to_phase(time_since_phase)
    mdays, mhours, mminutes := get_duration_elements(time_to_phase)
    fmt.printfln(
        output_format,
        moon.get_icon(frac),
        moon.string_of_phase(phase), days, hours, minutes,
        moon.string_of_phase(next_phase), mdays, mhours, mminutes,
    )
}

get_duration_elements :: proc(duration: time.Duration) -> (i64, i64, i64) {
    duration := duration
    hours := duration / time.Hour
    duration -= hours * time.Hour
    days := hours / 24
    hours -= days * 24
    minutes := duration / time.Minute
    duration -= minutes * time.Minute
    if duration > 30 * time.Second {
        minutes += 1
    }
    return i64(days), i64(hours), i64(minutes)
}

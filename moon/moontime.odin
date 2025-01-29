package moon

import "core:time"
import "core:fmt"
import "core:math"

MajorPhase :: enum {
    NewMoon,
    FirstQuarter,
    FullMoon,
    LastQuarter,
}

Phase :: enum {
    NewMoon,
    WaxingCrescent,
    FirstQuarter,
    WaxingGibbous,
    FullMoon,
    WaningGibbous,
    LastQuarter,
    WaningCrescent,
}

Icons := []rune{
    '', '', '', '', '', '', '',
    '', '', '', '', '', '', '',
    '', '', '', '', '', '', '',
    '', '', '', '', '', '', '',
}

find_moon_age :: proc(last_full_moon: time.Time) -> time.Duration {
    return time.diff(last_full_moon, time.now())
}

find_month_fraction :: proc(age: time.Duration) -> f64 {
    return f64(age) / f64(LUNARMONTH)
}

get_phase :: proc(fraction: f64) -> Phase {
    switch {
    case fraction <= 0.02 || fraction >= 0.98:
        return .NewMoon
    case fraction <= 0.24:
        return .WaxingCrescent
    case fraction > 0.24 && fraction < 0.26:
        return .FirstQuarter
    case fraction <= 0.49:
        return .WaxingGibbous
    case fraction > 0.49 && fraction < 0.51:
        return .FullMoon
    case fraction <= 0.74:
        return .WaningGibbous
    case fraction > 0.74 && fraction < 0.76:
        return .LastQuarter
    case:
        return .WaningCrescent
    }
}

find_phase_info :: proc(fraction: f64) -> (MajorPhase, time.Duration) {
    phase := MajorPhase(i64(fraction * 4) % 4)
    scaled_frac := fraction * 4
    time_since_phase := time.Duration(f64(LUNARMONTH) * (scaled_frac - f64(phase)) / 4)
    return phase, time_since_phase
}

time_to_phase :: proc(time_since_phase: time.Duration) -> time.Duration {
    return (LUNARMONTH / 4) - time_since_phase
}

next_phase :: proc(phase: MajorPhase) -> MajorPhase {
    return MajorPhase((int(phase) + 1) % 4)
}

string_of_phase :: proc {
    string_of_major_phase,
    string_of_minor_phase,
}

string_of_major_phase :: proc(phase: MajorPhase) -> string {
    switch phase {
    case .NewMoon:
        return "New Moon"
    case .FirstQuarter:
        return "First Quarter"
    case .FullMoon:
        return "Full Moon"
    case .LastQuarter:
        return "Last Quarter"
    }
    panic("Invalid phase value")
}

string_of_minor_phase :: proc(phase: Phase) -> string {
    switch phase {
    case .NewMoon:
        return "New Moon"
    case .WaxingCrescent:
        return "Waxing Crescent"
    case .FirstQuarter:
        return "First Quarter"
    case .WaxingGibbous:
        return "Waxing Gibbous"
    case .FullMoon:
        return "Full Moon"
    case .WaningGibbous:
        return "Waning Gibbous"
    case .LastQuarter:
        return "Last Quarter"
    case .WaningCrescent:
        return "Waning Crescent"
    }
    panic("Invalid phase value")
}

get_icon :: proc(fraction: f64) -> rune {
    scaled_frac := fraction * 28
    scaled_frac = math.round(scaled_frac)
    return Icons[int(scaled_frac) % 28]
}

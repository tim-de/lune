package moon

import "base:runtime"

import "core:encoding/json"
import "core:encoding/endian"
import "core:time"
import "core:c"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

import "curl"

ApiUrlFmt :: "https://aa.usno.navy.mil/api/moon/phases/date?date=%04d-%02d-%02d&nump=4"
FiveWeeks :: time.Second * time.SECONDS_PER_WEEK * 5


get_last_new_moon :: proc(cachefile: string) -> (last_moon: time.Time, ok: bool) {
    ok = true
    data, err := os.read_entire_file_or_err(cachefile)
    defer delete(data)
    if err != nil {
        fmt.eprintln(os.error_string(err))
        ok = false
    }
    if len(data) != 8 {
        ok = false
    }
    now := time.now()
    if ok {
        raw_time: i64
        raw_time, ok = endian.get_i64(data[:], .Little)
        if ok {
            last_moon = time.Time{raw_time}
        }
    }
    if !ok || time.diff(last_moon, now) > FiveWeeks {
        target_time := time.time_add(now, - FiveWeeks)
        builder: strings.Builder
        strings.builder_init(&builder)
        defer strings.builder_destroy(&builder)
        fmt.sbprintf(&builder, ApiUrlFmt, time.year(target_time), time.month(target_time), time.day(target_time))
        maybe_moondata := request_moon_data(strings.to_string(builder))
        if raw_moondata, ok := maybe_moondata.?; ok {
            defer delete(raw_moondata.data)
            defer free(raw_moondata)
            fmt.eprintfln("%s", raw_moondata.data)
            if data, err := json.parse(raw_moondata.data[:], parse_integers = true); err == nil {
                if retrieved_moon, valid := find_new_moon(data); valid {
                    last_moon = retrieved_moon
                    return last_moon, write_moondata(cachefile, last_moon)
                }
            }
        }
        return last_moon, false
    } else {
        last_lunar_month := get_lunar_month(last_moon)
        if time.since(last_moon) > last_lunar_month {
            last_moon = time.time_add(last_moon, last_lunar_month)
        }
        return last_moon, true
    }
}

write_moondata :: proc(cachefile: string, moon_time: time.Time) -> bool {
    time_data: [8]u8
    if !endian.put_i64(time_data[:], .Little, moon_time._nsec) {
        fmt.eprintln("Failed to write time data to buffer")
        return false
    }
    if err := os.write_entire_file_or_err(cachefile, time_data[:]); err != nil {
        fmt.eprintln("Failed to write buffer to file:", os.error_string(err))
        return false
    }
    return true
}

find_new_moon :: proc(data: json.Value) -> (time.Time, bool) {
    if data, ok := data.(json.Object); ok {
        if phasedata, ok := data["phasedata"]; ok {
            if phasedata, ok := phasedata.(json.Array); ok {
                for item, ix in phasedata {
                    if obj, ok := item.(json.Object); ok {
                        if phasename, ok := obj["phase"]; ok {
                            if str_pname, ok := phasename.(json.String); ok && str_pname == "New Moon" {
                                // Kinda gave up on some of the checking here, because like
                                // if we've got this far without incident and this is where
                                // it fucks up then I sort of deserve that, y'know?
                                moonyear := obj["year"]
                                moonmonth := obj["month"]
                                moonday := obj["day"]
                                moontime := obj["time"]
                                builder: strings.Builder
                                strings.builder_init(&builder)
                                defer strings.builder_destroy(&builder)
                                fmt.sbprintf(&builder, "%04d-%02d-%02d %s:00.00", moonyear, moonmonth, moonday, moontime)
                                //fmt.printfln("%s", strings.to_string(builder))
                                moon_time, consumed := time.iso8601_to_time_utc(strings.to_string(builder))
                                if consumed != len(strings.to_string(builder)) {
                                    return moon_time, false
                                }
                                return moon_time, true
                            }
                        }
                    }
                }
            }
        }
    }
    return time.Time{0}, false
}

request_moon_data :: proc(url: string) -> Maybe(^MoonData) {
    handle := curl.easy_init()
    if handle == nil {
        return nil
    }
    defer curl.easy_cleanup(handle)

    if res := curl.easy_setopt(handle, curl.Option.Url, url);
        res != .OK {
        return nil
    }

    data := new(MoonData)
    data.alloc = context.allocator
    ok := true
    defer {
        if !ok {
            delete(data.data)
            free(data)
        }
    }

    if res := curl.easy_setopt(handle, curl.Option.WriteData, data);
        res != .OK {
        ok = false
        return nil
    }
    if res := curl.easy_setopt(handle, curl.Option.WriteFunc, moondata_writefunc);
        res != .OK {
        ok = false
        return nil
    }
    if res := curl.easy_perform(handle);
        res != .OK {
        ok = false
        return nil
    }
    return data
}

MoonData :: struct {
    alloc: runtime.Allocator,
    data: [dynamic]u8,
}

moondata_writefunc :: proc "c" (ptr: [^]u8, size, nmemb: c.size_t, userdata: ^MoonData) -> c.size_t {
    context = runtime.default_context()
    if userdata.data == nil {
        userdata.data = make([dynamic]u8, userdata.alloc)
    }
    n := append(&userdata.data, ..ptr[:nmemb])
    return c.size_t(n)
}

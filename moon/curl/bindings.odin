package curl

import "core:c"

CURL :: distinct i64

foreign import curl "system:curl"

@(link_prefix="curl_")
foreign curl {
    easy_init :: proc() -> ^CURL ---
    easy_setopt :: proc(handle: ^CURL, option: Option, #c_vararg param: ..any) -> Code ---
    easy_perform :: proc(handle: ^CURL) -> Code ---
    easy_cleanup :: proc(handle: ^CURL) ---
}

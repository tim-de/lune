package curl

import "core:c"

//WriteFunc :: proc "c" (ptr: ^u8, size: c.size_t, nmemb: c.size_t, userdata: ^any)

OpType :: enum {
    Long = 0,
    ObjPtr = 10000,
    FunPtr = 20000,
    Off_T = 30000,
    Blob = 40000,
}

Option :: enum {
    WriteData = int(OpType.ObjPtr) + 1,
    Url = int(OpType.ObjPtr) + 2,
    WriteFunc = int(OpType.FunPtr) + 11,
}

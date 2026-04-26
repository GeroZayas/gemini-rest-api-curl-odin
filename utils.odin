package main

import "core:fmt"
import "core:os"
import "core:strings"


load_gemini_api_key_env :: proc() -> string {
	val, found := os.lookup_env("GEMINI_API_KEY", context.allocator)
	if !found {
		panic("GEMINI KEY NOT FOUND")
	}
	return val
}

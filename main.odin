package main

import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"
import "vendor:curl"
import rl "vendor:raylib"

GEMINI_MODEL :: "gemini-3.1-flash-lite-preview"

make_request_to_gemini :: proc(the_input: string) -> string {

	GEMINI_API_KEY := load_gemini_api_key_env()

	json_data := fmt.ctprintf("{{\"contents\":[{{\"parts\":[{{\"text\":%q}}]}}]}}", the_input)

	api_key_header := fmt.ctprintf("x-goog-api-key: %s", GEMINI_API_KEY)

	headers := curl.slist_append(nil, cstring("Content-Type: application/json"))
	headers = curl.slist_append(headers, api_key_header)
	defer curl.slist_free_all(headers)


	// --- Init curl ---
	handle := curl.easy_init()
	if handle == nil do panic("curl INIT FAILED!")
	defer curl.easy_cleanup(handle)
	// -----------------

	url := fmt.tprintf(
		"https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent",
		GEMINI_MODEL,
	)

	curl.easy_setopt(handle, .URL, cstring(raw_data(url)))
	curl.easy_setopt(handle, .HTTPHEADER, headers)
	curl.easy_setopt(handle, .POST, 1)
	curl.easy_setopt(handle, .POSTFIELDS, json_data)

	response_buffer := strings.builder_make()
	defer strings.builder_destroy(&response_buffer)

	curl.easy_setopt(handle, .WRITEDATA, &response_buffer)
	curl.easy_setopt(handle, .WRITEFUNCTION, write_callback)

	err := curl.easy_perform(handle)
	if err != .E_OK {
		panic("curl FAILED!")
	}

	response_string := strings.to_string(response_buffer)

	return response_string

}

write_callback :: proc(ptr: rawptr, size, nmemb: uint, userdata: rawptr) -> uint {
	n := size * nmemb
	builder := cast(^strings.Builder)userdata
	chunk := strings.string_from_ptr(cast(^byte)ptr, int(n))
	strings.write_string(builder, chunk)
	return uint(n)
}


main :: proc() {

	context.logger = log.create_console_logger()

	the_input := get_input_stdin_from_user()

	fmt.println(typeid_of(type_of(the_input)))

	response := make_request_to_gemini(the_input)

	fmt.println(response)

}


get_input_stdin_from_user :: proc() -> string {
	fmt.println("PROMPT >>> ")

	prompt_buffer: [1024]u8

	n, r_err := os.read(os.stdin, prompt_buffer[:])

	if r_err != os.ERROR_NONE {
		panic("Error leyendo el the_input")
	}

	input := string(prompt_buffer[:n])
	input = strings.trim_space(input)

	// clonamos aquí para poder tener la var de string como tal
	// y que viva en memoria y poder devolverla, porque
	// el buffer se libera al salir de este proc
	cloned_input, err := strings.clone(input)
	if err != nil {
		panic("Error clonando el input")
	}

	return cloned_input
}

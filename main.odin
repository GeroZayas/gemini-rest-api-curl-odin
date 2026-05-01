
/*
v3.0

This new version has ...

*/

package main

import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"
import "core:time"
import "vendor:curl"
import rl "vendor:raylib"

GEMINI_MODEL :: "gemini-3.1-flash-lite-preview"

Part :: struct {
	text: string,
}

Content :: struct {
	parts: []Part,
}

Candidate :: struct {
	content: Content,
}

GeminiResponse :: struct {
	candidates: []Candidate,
}

gr :: GeminiResponse


WINDOW_WIDTH :: 1000
WINDOW_HEIGHT :: 700

main :: proc() {

	context.logger = log.create_console_logger()


	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Gemini Rest API")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	screen := 1
	circle: int = 1

	// INPUT PROMPT Vars
	prompt_buffer: [1024]u8
	user_promtp := ""
	prompt_edit_mode := true

	// MAIN LOOP
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()

		switch screen {
		case 1:
			white_background(&prompt_buffer, &user_promtp, &prompt_edit_mode)
		case 2:
			blue_background()
		case 3:
			green_background()
		case:
			screen = 1
		}

		if rl.GuiButton({WINDOW_WIDTH - 40 - 60, WINDOW_HEIGHT - 40 - 40, 60, 40}, "Next") {
			screen += 1
			circle = 1
		}

		if screen != 1 {
			if rl.GuiButton({40, WINDOW_HEIGHT - 40 - 40, 60, 40}, "Previous") {
				screen -= 1
				circle = 1
			}
		}

	}
}


white_background :: proc(prompt_buf: ^[1024]u8, user_prompt: ^string, p_edit_mode: ^bool) {
	TITLE_TEXT :: "Gemini Rest API"
	TITLE_TEXT_SIZE :: 30
	rl.ClearBackground(rl.RAYWHITE)
	title_text_width := rl.MeasureText(TITLE_TEXT, TITLE_TEXT_SIZE)

	// log.info(title_text_width)
	rl.DrawText(TITLE_TEXT, ((WINDOW_WIDTH / 2) - (title_text_width / 2)), 20, TITLE_TEXT_SIZE, rl.BLUE)

	rl.GuiLabel({50, 50, 300, 20}, "Insert Prompt")

	if rl.GuiTextBox({50, 70, 900, 20}, cstring(&prompt_buf[0]), i32(len(prompt_buf)), p_edit_mode^) {
		p_edit_mode^ = !p_edit_mode^
	}


	if rl.GuiButton({50, 100, 100, 20}, "Send") {
		text_len := int(rl.TextLength(cstring(&prompt_buf[0])))
		text_value := string(prompt_buf[:text_len])

		cloned_text, clone_err := strings.clone(text_value)
		if clone_err != nil {
			fmt.println("Some error with cloning the string")
		} else {
			user_prompt^ = cloned_text
		}

	}

	if user_prompt^ != "" {
		rl.DrawText(cstring(raw_data(user_prompt^)), 50, 150, 30, rl.RED)
	}


}

blue_background :: proc() {
	TITLE_TEXT :: "Gemini Rest API BLUE"
	TITLE_TEXT_SIZE :: 60
	rl.ClearBackground(rl.BLUE)
	title_text_width := rl.MeasureText(TITLE_TEXT, TITLE_TEXT_SIZE)
	// log.info(title_text_width)
	rl.DrawText( TITLE_TEXT, ((WINDOW_WIDTH / 2) - (title_text_width / 2)), 20, TITLE_TEXT_SIZE, rl.YELLOW)
}

green_background :: proc() {
	TITLE_TEXT :: "Gemini Rest API GREEN"
	TITLE_TEXT_SIZE :: 100
	rl.ClearBackground(rl.GREEN)
	title_text_width := rl.MeasureText(TITLE_TEXT, TITLE_TEXT_SIZE)
	// log.info(title_text_width)
	rl.DrawText( TITLE_TEXT, ((WINDOW_WIDTH / 2) - (title_text_width / 2)), 30, TITLE_TEXT_SIZE, rl.WHITE)
}

extract_text_from_response :: proc(json_raw: string) -> (string, bool) {
	response: gr
	err := json.unmarshal_string(json_raw, &response)
	if err != nil {
		return "", false
	}
	if len(response.candidates) == 0 {
		return "", false
	}
	if len(response.candidates[0].content.parts) == 0 {
		return "", false
	}

	return response.candidates[0].content.parts[0].text, true
}


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

	raw_response_string := strings.to_string(response_buffer)

	response_string, clone_err := strings.clone(raw_response_string)
	if clone_err != nil {
		panic("Error clonando response string")
	}
	return response_string

}

write_callback :: proc(ptr: rawptr, size, nmemb: uint, userdata: rawptr) -> uint {
	n := size * nmemb
	builder := cast(^strings.Builder)userdata
	chunk := strings.string_from_ptr(cast(^byte)ptr, int(n))
	strings.write_string(builder, chunk)
	return uint(n)
}


get_input_stdin_from_user :: proc() -> string {

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


save_to_local_MD_file :: proc(file_name, clean_response: string) -> (succcess: bool) {
	err := os.write_entire_file_from_string(file_name, clean_response)
	if err != nil {
		fmt.println("COULD NOT SAVE FILE!")
		return false
	}
	return true
}


generate_file_name :: proc() -> string {
	now := time.now()

	now_string, ok := time.time_to_rfc3339(now)

	if !ok {
		fmt.println("Problem with Time")
	}

	fmt.println("NOW STRING:")
	fmt.println(now_string)

	file_name := fmt.tprintfln("response_%s.md", string(now_string))

	return file_name
}

Using `raygui` in Odin is straightforward because the Odin-raylib bindings are very well-maintained. `raygui` is an immediate-mode GUI library, meaning you define your interface inside your main game loop every single frame.

Here are the basics to get you up and running.

### 1. Prerequisites

Ensure you have the [odin-raylib](https://github.com/raylib-go/raylib) bindings (the official/standard community ones) installed. If you are using `vcpkg` or a standard setup, ensure your `vendor` directory is correctly linked.

### 2. Importing

You need to import both `raylib` and `raygui`.

```odin
import rl "vendor:raylib"
import gui "vendor:raygui"
```

### 3. The Basic Pattern

Because `raygui` is immediate-mode, the "state" of the GUI (clicked, value changed, etc.) is returned directly by the function call. You don't create "button objects"; you just call the function, and it returns `true` if it was interacted with.

```odin
main :: proc() {
    rl.InitWindow(800, 450, "Raygui Example")
    defer rl.CloseWindow()

    // Variable to track state
    slider_value: f32 = 50.0

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)

        // Draw a Slider
        // The function returns the current value of the slider
        slider_value = gui.Slider({100, 50, 200, 20}, "Value", nil, slider_value, 0, 100)

        // Draw a Button
        // Returns true only on the frame it is clicked
        if gui.Button({100, 100, 120, 30}, "Click Me!") {
            rl.TraceLog(.INFO, "Button was pressed!")
        }

        rl.EndDrawing()
    }
}
```

### 4. Key Concepts

#### The Rectangle Struct

Almost every `raygui` function takes a `rl.Rectangle` as the first argument: `Rectangle{x, y, width, height}`. This defines where and how big the UI element is.

#### State vs. Input

- **Buttons:** `gui.Button(...)` returns `true` when clicked.
- **Sliders:** `gui.Slider(...)` returns the current `f32` value based on the mouse interaction.
- **Checkboxes:** `gui.CheckBox(...)` returns a `bool` representing the current state.
- **Text Boxes:** `gui.TextBox(...)` takes a pointer to a buffer (a `[len]u8` or `[]u8`) and modifies it in place.

#### Handling Text

Raygui in Odin expects C-style strings (`cstring`).

- If you have a hardcoded string, just wrap it in quotes: `"Label"`.
- If you have an Odin `string`, you must convert it: `strings.clone_to_cstring(my_odin_string)`. **Note:** Be careful with memory allocation inside the loop; it is better to convert strings once or use a static buffer if possible.

### 5. Styling

You can change the look of your UI using `gui.SetStyle`. This should usually be called once before your main loop.

```odin
// Example: Change the base color of all buttons
gui.SetStyle(.BUTTON, i32(gui.ControlProperty.BASE_COLOR_NORMAL), 0x00FF00FF)
```

### 6. Important Tips for Odin

1.  **Memory:** Since `raygui` is a C library, it doesn't know about Odin's `string` type. Always pass `cstring`.
2.  **Performance:** Since you are drawing UI every single frame, avoid heavy allocations inside the `for !rl.WindowShouldClose()` loop.
3.  **Layout:** Because you are manually setting `Rectangle` coordinates, UI layouts can become tedious. For complex apps, consider creating a simple helper function to stack UI elements:

```odin
// Simple helper to stack buttons vertically
y_offset: f32 = 50
draw_menu_button :: proc(text: cstring, y: *f32) -> bool {
    result := gui.Button({100, y^, 120, 30}, text)
    y^ += 40
    return result
}
```

### Where to look next

- **[Raygui Examples](https://github.com/raysan5/raygui/tree/master/examples):** Look at the C examples; the logic is identical in Odin.
- **`vendor/raygui/raygui.odin`:** Open the source file in your Odin installation. You can see all available functions (like `gui.DropdownBox`, `gui.ProgressBar`, etc.) and the exact parameters they require.

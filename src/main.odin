package xogui

import "core:fmt"
import "core:os"
import "core:strings"
import rl "vendor:raylib"


main :: proc()
{
    engine, err := engine_start()
    if err != nil {
        fmt.println("engine start error:", err)
        return
    }

    name    := engine_cmd_name(&engine)
    version := engine_cmd_version(&engine)
    title   := strings.clone_to_cstring(fmt.tprintf("XoGui 0.0.2 (%s engine %s)", name, version))
    game    := game_init()

    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, title)
    rl.SetTargetFPS(60)
    rl.GuiSetStyle(rl.GuiControl.DEFAULT, i32(rl.GuiDefaultProperty.TEXT_SIZE), FONT_SIZE * 1.2)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(BG_COLOR)
        board_draw(&game)
        rl.EndDrawing()
    }

    rl.CloseWindow()
    os.close(engine.stdin)
    os.close(engine.stdout)
}


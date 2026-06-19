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

    game_loop:
    for !rl.WindowShouldClose() {
        switch game.state {
        case .New:
            engine_cmd_cleanboard(&engine)
            game = game_init() //TODO: memory leak?
        case .WaitForPlayerMove:
            if !game_has_message(&game) {
                cell, clicked := board_handle_click_on_cell()
                defer delete(cell)
                if clicked {
                    err, is_ok := engine_cmd_play(&engine, cell)
                    if is_ok {
                        defer delete(err)
                        index := cell_to_index(cell)
                        game_make_move(&game, index, .X)
                    } else {
                        game_set_message(&game, err)
                    }
                }
            }
        case .WaitForEngineMove:
            index := engine_cmd_genmove(&engine)
            game_make_move(&game, index, .O)
        case .EngineMoveReady:
        case .CheckForWinner:
            winner := engine_cmd_getwinner(&engine)
            if winner == .None {
                switch game.last_player {
                case .X:     game.state = .WaitForEngineMove
                case .O:     game.state = .WaitForPlayerMove
                case .Empty: fmt.panicf("UNREACHABLE\n")
                }
            } else {
                msg: string
                #partial switch winner {
                case .X:    msg = "You win!"
                case .O:    msg = "Opponent wins!"
                case .Draw: msg = "This is draw!"
                }
                game_set_message(&game, msg)
                game.state = .Over
            }
        case .Over:
        case .Quit:
            break game_loop
        }

        rl.BeginDrawing()
        rl.ClearBackground(BG_COLOR)
        board_draw(&game)
        rl.EndDrawing()
    }

    engine_cmd_quit(&engine)
    rl.CloseWindow()
    os.close(engine.stdin)
    os.close(engine.stdout)
}


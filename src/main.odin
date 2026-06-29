package xogui

import "core:fmt"
import "core:os"
import "core:strings"
import "core:sync"
import "core:thread"
import rl "vendor:raylib"


main :: proc()
{
    dir, e := os.get_executable_directory(context.allocator)
    if e != os.ERROR_NONE {
        panic("Failed to get executable directory")
    }
    fmt.println("INFO: XOGUI: working dir:", dir)
    defer delete(dir)
    os.setwd(dir)

    engine, err := engine_start()
    if err != nil {
        fmt.println("engine start error:", err)
        return
    }
    thread.create_and_start_with_data(&engine, engine_loop)

    name    := strings.trim(engine_cmd_name(&engine), "\r\n\x00 ")
    version := strings.trim(engine_cmd_version(&engine), "\r\n\x00 ")
    title   := strings.clone_to_cstring(fmt.tprintf("XoGui 0.0.4 (%s engine %s)", name, version))
    game    := game_init()

    rl.InitWindow(1, 1, title)
    game.dims = setup_dimensions()
    rl.SetTargetFPS(60)
    rl.GuiSetStyle(rl.GuiControl.DEFAULT, i32(rl.GuiDefaultProperty.TEXT_SIZE), i32(game.dims.FONT_SIZE * 1.2))
    rl.SetWindowSize(i32(game.dims.WINDOW_WIDTH), i32(game.dims.WINDOW_HEIGHT))

    monitor       := rl.GetCurrentMonitor()
    screen_width  := rl.GetMonitorWidth(monitor)
    screen_height := rl.GetMonitorHeight(monitor)
    rl.SetWindowPosition((screen_width - i32(game.dims.WINDOW_WIDTH)) / 2, (screen_height - i32(game.dims.WINDOW_HEIGHT)) / 2)

    game_loop:
    for !rl.WindowShouldClose() {
        //
        //  Process game commands
        //
        if game.command != nil {
            defer { game.command = nil }
            switch cmd in game.command {
            case NewGame:
                engine_cmd_cleanboard(&engine)
                game = game_reset(&game)
            case SetDifficulty:
                game.difficulty = cmd.difficulty
                engine_cmd_cleanboard(&engine)
                engine_cmd_difficulty(&engine, game.difficulty)
                game = game_reset(&game)
            case SetMessage:
                game_set_message(&game, cmd.message, cmd.bg_color, cmd.fg_color)
            case Quit:
                break game_loop
            }
        }

        //
        //  Process game state
        //
        switch game.state {
        case .WaitForPlayerMove:
            if !game_has_message(&game) {
                cell, clicked := board_handle_click_on_cell(&game.dims)
                defer delete(cell)
                if clicked {
                    err, is_ok := engine_cmd_play(&engine, cell)
                    if is_ok {
                        defer delete(err)
                        index := cell_to_index(cell)
                        game_make_move(&game, index, .X)
                    } else {
                        game.command = Command(SetMessage{
                            message = err, bg_color = MSG_WARN_COLOR, fg_color = BG_COLOR
                        })
                    }
                }
            }
        case .RequestForEngineMove:
            engine_async_cmd_genmove(&engine)
            game.state = .WaitForEngineMove
        case .WaitForEngineMove:
            if (engine.response_is_ready) {
                move, _ := engine_get_response_result(&engine)
                defer delete(move)
                index := cell_to_index(move)
                game_make_move(&game, index, .O)
            }
        case .CheckForWinner:
            winner := engine_cmd_getwinner(&engine)
            if winner == .None {
                switch game.last_player {
                case .X:     game.state = .RequestForEngineMove
                case .O:     game.state = .WaitForPlayerMove
                case .Empty: fmt.panicf("UNREACHABLE\n")
                }
            } else {
                msg:   string
                bg_color: rl.Color
                fg_color: rl.Color
                #partial switch winner {
                case .X:    msg = "You win!";       bg_color = MSG_OK_COLOR;   fg_color = BG_COLOR
                case .O:    msg = "Opponent wins!"; bg_color = MSG_ERR_COLOR;  fg_color = FG_COLOR
                case .Draw: msg = "This is draw!";  bg_color = MSG_WARN_COLOR; fg_color = BG_COLOR
                }
                game.command = Command(SetMessage{
                    message = msg, bg_color = bg_color, fg_color = fg_color
                })
                game.state = .Over
            }
        case .Over:
            // Do nothing, wait for the "new game" button to be pressed
        }

        //
        //  Drawings
        //
        rl.BeginDrawing()
        rl.ClearBackground(BG_COLOR)
        board_draw(&game)
        rl.EndDrawing()
    }

    engine.stop_requested = true
    engine_cmd_quit(&engine)
    rl.CloseWindow()
    sync.sema_post(&engine.sem)
    os.close(engine.stdin)
    os.close(engine.stdout)
}


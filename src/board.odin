package xogui

import "core:math"
import "core:strings"
import rl "vendor:raylib"


pulse_scale :: proc() -> f32
{
    PULSE_SCALE_MIN      :: 0.9  // Minimal scale of the symbol at the lowest point of the pulse
    PULSE_SCALE_RANGE    :: 0.5  // Difference between maximum and minimum scale
    PULSE_FREQUENCY      :: 5.2  // Pulse speed in radians per second
    PULSE_SIN_OFFSET     :: 1.0  // Sin output offset: transforms [-1; 1] into [0; 2]
    PULSE_SIN_NORMALIZER :: 2.0  // Sin output divisor: transforms [0; 2] into [0; 1]
    time := rl.GetTime()
    normalized_sin := ((math.sin(time * PULSE_FREQUENCY) + PULSE_SIN_OFFSET) / PULSE_SIN_NORMALIZER)
    return f32(PULSE_SCALE_MIN + PULSE_SCALE_RANGE * normalized_sin)
}

board_draw_symbol :: proc(sym:   string,
                          x:     int,
                          y:     int,
                          color: rl.Color)
{
    c_sym := strings.clone_to_cstring(sym)
    defer delete(c_sym)

    font      := rl.GetFontDefault()
    text_size := rl.MeasureTextEx(font, c_sym, FONT_SIZE, 1)
    text_x    := f32(x) + (f32(CELL_SIZE) - text_size.x) / 2
    text_y    := f32(y) + (f32(CELL_SIZE) - text_size.y) / 2

    rl.DrawTextEx(font, c_sym, rl.Vector2{text_x, text_y}, FONT_SIZE, 1, color)
}

board_draw_symbol_pulse :: proc(sym:   cstring,
                                x:     int,
                                y:     int,
                                color: rl.Color)
{
    font  := rl.GetFontDefault()
    scale := pulse_scale()

    font_size := f32(FONT_SIZE) * scale
    text_size := rl.MeasureTextEx(font, sym, font_size, 1)
    text_x    := f32(x) + (f32(CELL_SIZE) - text_size[0]) / 2
    text_y    := f32(y) + (f32(CELL_SIZE) - text_size[1]) / 2

    rl.DrawTextEx(font, sym, rl.Vector2{text_x, text_y}, font_size, 1, color)
}

board_draw_x :: proc(x:     int,
                     y:     int,
                     color: rl.Color,
                     pulse: bool)
{
    PADDING   :: CELL_SIZE * 0.20
    THICKNESS :: CELL_SIZE * 0.08

    scale := pulse ? pulse_scale() : 1.0
    half  := f32(CELL_SIZE) / 2
    size  := (f32(CELL_SIZE) - 2 * PADDING) * scale / 2
    cx    := f32(x) + half
    cy    := f32(y) + half

    rl.DrawLineEx(
        rl.Vector2{cx - size, cy - size},
        rl.Vector2{cx + size, cy + size},
        THICKNESS,
        color,
    )
    rl.DrawLineEx(
        rl.Vector2{cx + size, cy - size},
        rl.Vector2{cx - size, cy + size},
        THICKNESS,
        color,
    )
}

board_draw_o :: proc(x:     int,
                     y:     int,
                     color: rl.Color,
                     pulse: bool)
{
    PADDING    :: CELL_SIZE * 0.20
    THICKNESS  :: CELL_SIZE * 0.08
    O_SEGMENTS :: 64

    scale        := pulse ? pulse_scale() : 1.0
    center       := rl.Vector2{f32(x) + f32(CELL_SIZE) / 2, f32(y) + f32(CELL_SIZE) / 2}
    radius_outer := ((f32(CELL_SIZE) / 2) - PADDING) * scale
    radius_inner := radius_outer - THICKNESS

    rl.DrawRing(center, radius_inner, radius_outer, 0, 360, O_SEGMENTS, color)
}

board_draw_message :: proc(message: cstring)
{
    font       := rl.GetFontDefault()
    text_size  := rl.MeasureTextEx(font, message, MSG_FONT_SIZE, 1)
    text_y_gap := MSG_FONT_SIZE / 2
    text_x_gap := MSG_FONT_SIZE / 2
    rect_w_gap := MSG_FONT_SIZE / 1.5
    rect_h_gap := f32(0)
    rect_w     := text_size[0] + rect_w_gap
    rect_h     := text_size[1] + rect_h_gap
    rect_x     := (f32(WINDOW_WIDTH) - rect_w) / 2
    rect_y     := (f32(WINDOW_HEIGHT) - rect_h) / 2
    text_x     := rect_x + text_x_gap
    text_y     := rect_y + text_y_gap
    rl.DrawRectangle(i32(rect_x), i32(rect_y), i32(rect_w), i32(rect_h), MSG_COLOR)
    rl.DrawTextEx(font, message, rl.Vector2{text_x, text_y}, MSG_FONT_SIZE, 1, FG_COLOR)
}

board_draw_controls :: proc(game: ^Game)
{
    BUTTON_WIDTH         :: 300
    BUTTON_HEIGHT        :: 50
    BUTTON_GAP           :: 10
    BUTTON_TOP           :: WINDOW_HEIGHT - BUTTON_HEIGHT - (3 * BUTTON_GAP) - V_GRID_GAP / 2
    BUTTON_NEW_GAME_LEFT :: (WINDOW_WIDTH - BUTTON_WIDTH * 2) / 2 - BUTTON_GAP
    BUTTON_EXIT_LEFT     :: BUTTON_NEW_GAME_LEFT + BUTTON_WIDTH + 2 * BUTTON_GAP

    new_game_button_rect := rl.Rectangle{BUTTON_NEW_GAME_LEFT, BUTTON_TOP, BUTTON_WIDTH, BUTTON_HEIGHT}
    exit_button_rect     := rl.Rectangle{BUTTON_EXIT_LEFT, BUTTON_TOP, BUTTON_WIDTH, BUTTON_HEIGHT}

    if rl.GuiButton(new_game_button_rect, "New game") {
        game.state = .New
    }

    if rl.GuiButton(exit_button_rect, "Exit") {
        game.state = .Quit
    }
}

board_draw :: proc(game: ^Game)
{
    // color: rl.Color = game_has_message(game) || game.is_over || !game.wait_for_pl_move
    color: rl.Color = game_has_message(game) ? INACTIVE_COLOR : FG_COLOR

    text: [2]u8
    text[1] = 0
    for c in 0..=BOARD_SIDE {
        x  :i32 = i32(H_GRID_MARGIN + (CELL_SIZE * c))
        ys :i32 = V_GRID_MARGIN
        ye :i32 = ys + (BOARD_SIDE * CELL_SIZE)
        rl.DrawLine(x, ys, x, ye, color)
        if c < BOARD_SIDE {
            text[0] = 'A' + u8(c)
            board_draw_symbol(string(text[:]), int(x), int(ys - CELL_SIZE), color)
            board_draw_symbol(string(text[:]), int(x), int(ye), color)
        }
    }
    for r in 0..=BOARD_SIDE {
        y  :i32 = i32(V_GRID_MARGIN + (CELL_SIZE * r))
        xs :i32 = H_GRID_MARGIN
        xe :i32 = xs + (BOARD_SIDE * CELL_SIZE)
        rl.DrawLine(xs, y, xe, y, color)
        if r < BOARD_SIDE {
            text[0] = '9' - u8(r)
            board_draw_symbol(string(text[:]), int(xs - CELL_SIZE), int(y), color)
            board_draw_symbol(string(text[:]), int(xe), int(y), color)
        }
    }
    for y in 0..<BOARD_SIDE {
        for x in 0..<BOARD_SIDE {
            index := xy_to_index(x, y)
            if game.board[index] != Cell.Empty {
                py       := V_GRID_MARGIN + (CELL_SIZE * (BOARD_SIDE - y - 1))
                px       := H_GRID_MARGIN + (CELL_SIZE * x)
                pl_color := game.board[index] == Cell.X ? PL_X_COLOR : PL_O_COLOR
                pulse    := index == game.last_played_index
                if game.board[index] == Cell.X {
                    board_draw_x(px, py, pl_color, pulse)
                } else {
                    board_draw_o(px, py, pl_color, pulse)
                }
            }
        }
    }

    board_draw_controls(game)
}

board_handle_click_on_cell :: proc() -> (cell: string, clicked: bool)
{
    clicked = false
    cell    = ""
    if !rl.IsMouseButtonReleased(rl.MouseButton.LEFT) {
        return
    }

    mouse   := rl.GetMousePosition()
    grid_x0 := H_GRID_MARGIN
    grid_y0 := V_GRID_MARGIN
    grid_x1 := H_GRID_MARGIN + BOARD_SIDE * CELL_SIZE
    grid_y1 := V_GRID_MARGIN + BOARD_SIDE * CELL_SIZE

    if int(mouse[0]) < grid_x0 || int(mouse[0]) >= grid_x1 ||
       int(mouse[1]) < grid_y0 || int(mouse[1]) >= grid_y1 {
        return
    }

    col     := (int(mouse[0]) - grid_x0) / CELL_SIZE
    row     := (int(mouse[1]) - grid_y0) / CELL_SIZE
    cell     = pos_to_cell(row, col)
    clicked  = true
    return
}


package xogui

import "core:fmt"
import rl "vendor:raylib"


Dimensions :: struct {
    WINDOW_WIDTH:        int,
    WINDOW_HEIGHT:       int,
    CELL_SIZE:           int,
    FONT_SIZE:           f32,
    GRID_SIDE:           int,
    H_GRID_MARGIN:       int,
    V_GRID_MARGIN:       int,
    CONTROLS_LEFT:       int,
    BUTTON_WIDTH:        int,
    BUTTON_HEIGHT:       int,
    BUTTON_GAP:          int,
    BUTTON_EXIT_TOP:     int,
    BUTTON_NEW_GAME_TOP: int,
    BUTTON_LEFT:         int,
    MSG_FONT_SIZE:       f32,
}

setup_dimensions :: proc() -> (dims: Dimensions)
{
    monitor := rl.GetCurrentMonitor()
    width   := rl.GetMonitorWidth(monitor)
    scale :f32 = f32(width) / 3000.0
    fmt.println("INFO: XOGUI: current monitor width:", width)
    fmt.println("INFO: XOGUI: using scale:          ", scale)

    dims.WINDOW_WIDTH         = int(1265 * scale)
    dims.WINDOW_HEIGHT        = int(900  * scale)
    dims.CELL_SIZE            = int(70   * scale)
    dims.H_GRID_MARGIN        = int(100  * scale)
    dims.BUTTON_WIDTH         = int(300  * scale)
    dims.BUTTON_HEIGHT        = int(50   * scale)
    dims.BUTTON_GAP           = int(10   * scale)
    dims.FONT_SIZE            = f32(dims.CELL_SIZE) / 2
    dims.GRID_SIDE            = BOARD_SIDE * dims.CELL_SIZE
    dims.V_GRID_MARGIN        = (dims.WINDOW_HEIGHT - dims.GRID_SIDE) / 2
    dims.CONTROLS_LEFT        = (dims.H_GRID_MARGIN * 2) + (BOARD_SIDE * dims.CELL_SIZE)
    dims.BUTTON_EXIT_TOP      = dims.V_GRID_MARGIN + (dims.GRID_SIDE - dims.CELL_SIZE) + (dims.CELL_SIZE - dims.BUTTON_HEIGHT)
    dims.BUTTON_NEW_GAME_TOP  = dims.BUTTON_EXIT_TOP - dims.BUTTON_GAP - dims.BUTTON_HEIGHT
    dims.BUTTON_LEFT          = dims.CONTROLS_LEFT
    dims.MSG_FONT_SIZE        = f32(dims.FONT_SIZE) * 1.5
    return
}

BOARD_SIDE           :: 10
BOARD_SIZE           :: BOARD_SIDE * BOARD_SIDE
BG_COLOR             :: rl.Color{18, 18, 18, 255}
FG_COLOR             :: rl.LIGHTGRAY
INACTIVE_COLOR       :: rl.DARKGRAY
PL_X_COLOR           :: rl.GREEN
PL_O_COLOR           :: rl.RED
MSG_COLOR            :: rl.RED
MSG_TIME             :: 2  // sec


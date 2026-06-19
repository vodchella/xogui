package xogui

import rl "vendor:raylib"


WINDOW_WIDTH      :: 1000
WINDOW_HEIGHT     :: 1000
BOARD_SIDE        :: 10
BOARD_SIZE        :: BOARD_SIDE * BOARD_SIDE
CELL_SIZE         :: 70
FONT_SIZE         :: CELL_SIZE - 20 - (10 * 2)
V_GRID_GAP        :: 50
H_GRID_MARGIN     :: (WINDOW_WIDTH  - (BOARD_SIDE * CELL_SIZE)) / 2
V_GRID_MARGIN     :: (WINDOW_HEIGHT - (BOARD_SIDE * CELL_SIZE)) / 2 - V_GRID_GAP
BG_COLOR          :: rl.Color{18, 18, 18, 255}
FG_COLOR          :: rl.LIGHTGRAY
INACTIVE_COLOR    :: rl.DARKGRAY
PL_X_COLOR        :: rl.GREEN
PL_O_COLOR        :: rl.RED
MSG_COLOR         :: rl.RED
MSG_TIME          :: 2 * 1000 // 2 sec

MSG_FONT_SIZE : f32     : FONT_SIZE * 1.5
DRAW_MSG      : string  : "This is draw!\n"


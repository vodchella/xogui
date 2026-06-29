package xogui

import rl "vendor:raylib"


WINDOW_WIDTH         :: 1265
WINDOW_HEIGHT        :: 900
BOARD_SIDE           :: 10
BOARD_SIZE           :: BOARD_SIDE * BOARD_SIDE
CELL_SIZE            :: 70
FONT_SIZE            :: CELL_SIZE - 40
GRID_SIDE            :: BOARD_SIDE * CELL_SIZE
H_GRID_MARGIN        :: 100
V_GRID_MARGIN        :: (WINDOW_HEIGHT - GRID_SIDE) / 2
CONTROLS_LEFT        :: (H_GRID_MARGIN * 2) + (BOARD_SIDE * CELL_SIZE)
BUTTON_WIDTH         :: 300
BUTTON_HEIGHT        :: 50
BUTTON_GAP           :: 10
BUTTON_EXIT_TOP      :: V_GRID_MARGIN + (GRID_SIDE - CELL_SIZE) + (CELL_SIZE - BUTTON_HEIGHT)
BUTTON_NEW_GAME_TOP  :: BUTTON_EXIT_TOP - BUTTON_GAP - BUTTON_HEIGHT
BUTTON_LEFT          :: CONTROLS_LEFT
BG_COLOR             :: rl.Color{18, 18, 18, 255}
FG_COLOR             :: rl.LIGHTGRAY
INACTIVE_COLOR       :: rl.DARKGRAY
PL_X_COLOR           :: rl.GREEN
PL_O_COLOR           :: rl.RED
MSG_COLOR            :: rl.RED
MSG_TIME             :: 2  // sec

MSG_FONT_SIZE :f32 : FONT_SIZE * 1.5


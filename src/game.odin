package xogui

import "core:mem"
import rl "vendor:raylib"


Cell :: enum u8 {
    Empty,
    X,
    O,
}

Winner :: enum {
    None,
    Draw,
    X,
    O,
}

Difficulty :: enum {
    Easy,
    Normal,
}

Game_State :: enum u8 {
    WaitForPlayerMove,
    RequestForEngineMove,
    WaitForEngineMove,
    CheckForWinner,
    Over,
}

Game :: struct {
    state:                  Game_State,
    board:                  [BOARD_SIZE]Cell,
    dims:                   Dimensions,
    command:                Command,
    last_player:            Cell,
    last_played_index:      int,
    message:                string,
    message_time:           f64,
    difficulty:             Difficulty,
    dbox_diff_selected_idx: i32,
    dbox_diff_edit_mode:    bool,
}


game_init :: proc() -> (game: Game)
{
    game = Game{
        state             = .WaitForPlayerMove,
        difficulty        = .Easy,
        last_player       = .Empty,
        last_played_index = -1,
        message   = "",
    }
    mem.set(&game.board, u8(Cell.Empty), BOARD_SIZE)
    return
}

game_reset :: proc(game: ^Game) -> (new_game: Game)
{
    dims := game.dims
    diff := game.difficulty
    diff_idx := game.dbox_diff_selected_idx
    new_game = game_init()
    new_game.dims = dims
    new_game.difficulty = diff
    new_game.dbox_diff_selected_idx = diff_idx
    return
}

game_set_message :: proc(game: ^Game,
                         msg:  string)
{
    if (game.message != "") {
        delete(game.message)
    }
    game.message      = msg
    game.message_time = rl.GetTime()
}

game_has_message :: proc(game: ^Game) -> bool
{
    return game.message != "" && (rl.GetTime() - game.message_time < MSG_TIME)
}

game_make_move :: proc(game:   ^Game,
                       index:  int,
                       player: Cell)
{
    game.board[index]      = player
    game.last_player       = player
    game.last_played_index = index
    game.state             = .CheckForWinner
}


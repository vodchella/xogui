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

Game_State :: enum u8 {
    New,
    WaitForPlayerMove,
    RequestForEngineMove,
    WaitForEngineMove,
    CheckForWinner,
    Over,
    Quit,
}

Game :: struct {
    state:                 Game_State,
    board:                 [BOARD_SIZE]Cell,
    dims:                  Dimensions,
    last_player:           Cell,
    last_played_index:     int,
    current_message:       string,
    current_message_time:  f64,
}


game_init :: proc() -> (game: Game)
{
    game = Game{
        state             = .WaitForPlayerMove,
        dims              = setup_dimensions(),
        last_player       = .Empty,
        last_played_index = -1,
        current_message   = "",
    }
    mem.set(&game.board, u8(Cell.Empty), BOARD_SIZE)
    return
}

game_set_message :: proc(game: ^Game,
                         msg:  string)
{
    if (game.current_message != "") {
        delete(game.current_message)
    }
    game.current_message      = msg
    game.current_message_time = rl.GetTime()
}

game_has_message :: proc(game: ^Game) -> bool
{
    return game.current_message != "" && (rl.GetTime() - game.current_message_time < MSG_TIME)
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


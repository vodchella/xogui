package xogui

import "core:mem"


Cell :: enum u8 {
    Empty,
    X,
    O,
}

Game_State :: enum u8 {
    WaitForPlayerMove,
    WaitForEngineMove,
    EngineMoveReady,
    CheckForWinner,
    Over,
}

Game :: struct {
    state:                 Game_State,
    board:                 [BOARD_SIZE]Cell,
    last_player:           Cell,
    last_played_index:     int,
    current_message:       string,
    current_message_time:  u64,
}


game_init :: proc() -> (game: Game)
{
    game = Game{
        state             = .WaitForPlayerMove,
        last_player       = .Empty,
        last_played_index = -1,
    }
    mem.set(&game.board, u8(Cell.Empty), BOARD_SIZE)
    return
}

game_has_message :: proc(game: ^Game) -> bool
{
    return false
}


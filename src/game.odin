package xogui

import "core:mem"


Cell :: enum u8 {
    Empty,
    X,
    O,
}

Game :: struct {
    board:                 [BOARD_SIZE]u8,
    last_played_index:     int,
    current_message:       string,
    current_message_time:  u64,
}


game_init :: proc() -> (game: Game)
{
    game = Game{}
    mem.set(&game.board, u8(Cell.Empty), BOARD_SIZE)
    return
}

game_has_message :: proc(game: ^Game) -> bool
{
    return false
}


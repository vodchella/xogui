package xogui

import rl "vendor:raylib"


NewGame       :: struct {}
Quit          :: struct {}
SetDifficulty :: struct {
    difficulty: Difficulty
}
SetMessage    :: struct {
    message:  string,
    bg_color: rl.Color,
    fg_color: rl.Color,
}

Command :: union {
    NewGame,
    Quit,
    SetDifficulty,
    SetMessage,
}


package xogui

NewGame       :: struct {}
Quit          :: struct {}
SetDifficulty :: struct {
    difficulty: Difficulty
}

Command :: union {
    NewGame,
    Quit,
    SetDifficulty,
}


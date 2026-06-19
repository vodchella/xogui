package xogui


xy_to_index :: proc(x: int,
                    y: int) -> int
{
    return y * BOARD_SIDE + x
}

index_to_xy :: proc(index: int) -> (int, int)
{
    x := index % BOARD_SIDE
    y := index / BOARD_SIDE

    return x, y
}


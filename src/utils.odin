package xogui

import "core:strings"


xy_to_index :: proc(x: int,
                    y: int) -> int
{
    return y * BOARD_SIDE + x
}

index_to_xy :: proc(index: int) -> (x: int, y: int)
{
    x = index % BOARD_SIDE
    y = index / BOARD_SIDE
    return
}

cell_to_index :: proc(cell: string) -> int
{
    x := int(cell[0] - 'A')
    y := int(cell[1] - '0')
    return y * BOARD_SIDE + x
}

index_to_cell :: proc(index: int) -> string
{
    x := index % BOARD_SIDE
    y := index / BOARD_SIDE
    cell := []u8{'A' + u8(x), '0' + u8(y)}
    return strings.clone(string(cell[:2]))
}

pos_to_cell :: proc(row, col: int) -> string
{
    cell_arr := []u8{'A' + u8(col), '9' - u8(row)}
    return strings.clone(string(cell_arr[:2]))
}


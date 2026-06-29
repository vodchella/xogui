package xogui

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"
import "core:sync"


Engine :: struct {
    process:           os.Process,
    stdin:             ^os.File,
    stdout:            ^os.File,
    request:           string,
    response:          [1024]u8,
    response_len:      int,
    response_is_ready: bool,
    sem:               sync.Sema,
    stop_requested:    bool,
}


engine_start :: proc() -> (engine: Engine, err: os.Error)
{
    stdin_r,  stdin_w,  _ := os.pipe()
    stdout_r, stdout_w, _ := os.pipe()
    engine = Engine{
        stdin = stdin_w,
        stdout = stdout_r
    }

    engine.process, err = os.process_start({
        command = []string{"./xoml", "-GTP"},
        stdin   = stdin_r,
        stdout  = stdout_w,
    })
    os.close(stdin_r)
    os.close(stdout_w)

    if err != nil {
        return Engine{}, err
    }
    return engine, nil
}

engine_loop :: proc(arg: rawptr)
{
    engine := cast(^Engine)arg
    for !engine.stop_requested {
        sync.sema_wait(&engine.sem)

        if engine.stop_requested {
            break
        }

        engine_get_response(engine)
        engine.response_is_ready = true
    }
}

engine_set_request :: proc(engine:  ^Engine,
                           request: string)
{
    engine.response_is_ready = false
    engine.response_len      = 0
    engine.request           = request
}

engine_get_response :: proc(engine: ^Engine)
{
    fmt.print(">", string(engine.request[:]))
    os.write_string(engine.stdin, engine.request)
    mem.zero(&engine.response, 1024)
    n, err := os.read(engine.stdout, engine.response[:])
    engine.response_is_ready = true
    engine.response_len = n
    if err != nil {
        fmt.println("engine response read error:", err)
    } else {
        fmt.print(string(engine.response[:n]))
    }
}

engine_get_sync_response :: proc(engine:  ^Engine,
                                 request: string)
{
    engine_set_request(engine, request)
    engine_get_response(engine)
}

engine_get_response_result :: proc(engine: ^Engine) -> (result: string, is_err: bool)
{
    result = strings.clone(string(engine.response[2:engine.response_len-2]))
    is_err = engine.response[0] == '?'
    return
}

engine_cmd_name :: proc(engine: ^Engine) -> (result: string)
{
    engine_get_sync_response(engine, "name\n")
    result, _ = engine_get_response_result(engine)
    return
}

engine_cmd_version :: proc(engine: ^Engine) -> (result: string)
{
    engine_get_sync_response(engine, "version\n")
    result, _ = engine_get_response_result(engine)
    return
}

engine_cmd_cleanboard :: proc(engine: ^Engine)
{
    engine_get_sync_response(engine, "clean_board\n")
}

engine_cmd_difficulty :: proc(engine:     ^Engine,
                              difficulty: Difficulty)
{
    diff_name: string
    switch difficulty {
    case .Easy:   diff_name = "easy"
    case .Normal: diff_name = "normal"
    }
    cmd := fmt.tprintf("difficulty %s\n", diff_name)
    engine_get_sync_response(engine, cmd)
}

engine_cmd_quit :: proc(engine: ^Engine)
{
    engine_get_sync_response(engine, "quit\n")
}

engine_cmd_play :: proc(engine: ^Engine,
                        cell:   string) -> (err: string, is_ok: bool)
{
    engine_get_sync_response(engine, fmt.tprintf("play X %s\n", cell))
    err, is_ok = engine_get_response_result(engine)
    is_ok = !is_ok
    return
}

engine_cmd_getwinner :: proc(engine: ^Engine) -> Winner
{
    engine_get_sync_response(engine, "winner\n")
    resp, _ := engine_get_response_result(engine)
    switch resp {
    case "draw": return .Draw
    case "X":    return .X
    case "O":    return .O
    case:        return .None
    }
}

engine_cmd_genmove :: proc(engine: ^Engine) -> int
{
    engine_get_sync_response(engine, "gen_move O\n")
    resp, _ := engine_get_response_result(engine)
    defer delete(resp)
    return cell_to_index(resp)
}

engine_async_cmd_genmove :: proc(engine: ^Engine)
{
    engine_set_request(engine, "gen_move O\n")
    sync.sema_post(&engine.sem)
}

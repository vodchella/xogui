package xogui

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"


Engine :: struct {
    process:           os.Process,
    stdin:             ^os.File,
    stdout:            ^os.File,
    request:           string,
    response:          [1024]u8,
    response_len:      int,
    response_is_ready: bool,
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

engine_set_request :: proc(engine:  ^Engine,
                           request: string)
{
    engine.response_is_ready = false
    engine.response_len = 0
    engine.request = request
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
        fmt.print(string(engine.response[:]))
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


package xogui

import "core:fmt"
import "core:os"

main :: proc()
{
    engine, err := engine_start()
    if err != nil {
        fmt.println("engine start error:", err)
        return
    }

    fmt.print(engine_cmd_name(&engine))
    fmt.print(engine_cmd_version(&engine))

    os.close(engine.stdin)
    os.close(engine.stdout)
}

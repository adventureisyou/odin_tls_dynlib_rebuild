package lib

import "base:runtime"
import "core:log"

@(export)
something :: proc() {
    log.info("hi")
}

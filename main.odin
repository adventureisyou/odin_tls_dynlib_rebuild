package main

import "core:dynlib"
import "core:log"
import "core:sys/posix"

handle: dynlib.Library

main :: proc() {
	context.logger = log.create_console_logger()

	for attempt in 1..=10 {
		// Build the dylib
		pid: posix.pid_t
		spawn_err := posix.posix_spawn(
			&pid,
			cstring("odin"),
			nil,
			nil,
			raw_data(
			[]cstring {
				"odin",
				"build",
				"lib.odin",
				"-build-mode:shared",
				"-out:lib.dylib",
				"-debug",
				"-file",
				nil,
			},
			),
			nil,
		)
		if spawn_err != .NONE do log.panic("failed to spawn compile")
		status: i32
		posix.waitpid(pid, &status, {})
		if status != 0 do log.panicf("compile failed with status: %d", status)

		// Reload the library
		if handle != nil do dynlib.unload_library(handle)
		handle = dynlib.load_library("lib.dylib") or_else log.panic("failed to load on attempt", attempt)
		log.info("success on attempt", attempt)
	}
}

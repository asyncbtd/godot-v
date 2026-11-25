// Copyright 2026 Timofey Brukhanchik
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module godot

import os

#include "@VMODROOT/bridge/crash.h"

fn C.godot_v_set_log_path(path &u8)
fn C.godot_v_log_write(line &u8)
fn C.godot_v_install_crash_handlers()

// install_crash_logging installs fatal-signal handlers and the Boehm GC abort
// hook so a crash writes a backtrace and the recent message trail instead of
// only leaving a system coredump. Call once, early, after the V runtime is up.
fn install_crash_logging() {
	C.godot_v_install_crash_handlers()
}

// set_crash_log_path points the persistent log at `path` (a file). Messages and
// crash reports are appended there. Until it is set, output goes to stderr only.
fn set_crash_log_path(path string) {
	C.godot_v_set_log_path(path.str)
}

// log_line appends a message to the persistent log and the in-memory ring that
// crash reports dump. It does not print to Godot's output; use report for that.
fn log_line(message string) {
	C.godot_v_log_write(message.str)
}

// setup_project_log points the log at `godot_v.log` inside the project folder so
// the trail sits next to the project the user is working on. Falls back to
// stderr-only when the project path is not available yet.
fn setup_project_log() {
	dir := project_dir()
	if dir == '' {
		return
	}
	path := os.join_path(dir, 'godot_v.log')
	set_crash_log_path(path)
	log_line('godot-v: logging active; crash reports and errors append to this file')
}

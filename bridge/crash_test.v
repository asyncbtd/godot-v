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

fn C.fork() int
fn C.raise(sig int) int
fn C.waitpid(pid int, status &int, options int) int
fn C._exit(code int)
fn C.alarm(seconds u32) u32

struct RLimit {
mut:
	cur u64
	max u64
}

fn C.setrlimit(resource int, rlim &RLimit) int

// Errors must leave a persistent trail, not just Godot's transient output.
fn test_log_line_persists_messages_to_file() {
	path := os.join_path(os.temp_dir(), 'godot_v_trail_test_${os.getpid()}.log')
	os.rm(path) or {}
	set_crash_log_path(path)
	log_line('trail alpha')
	log_line('trail beta')
	content := os.read_file(path) or { '' }
	assert content.contains('trail alpha')
	assert content.contains('trail beta')
	os.rm(path) or {}
}

// A fatal signal must write the signal, the recent message trail and a native
// backtrace to the log. The crash happens in a forked child so the test runner
// survives; the child only logs and raises (it never allocates GC memory).
fn test_crash_dump_writes_signal_trail_and_backtrace() {
	install_crash_logging()
	path := os.join_path(os.temp_dir(), 'godot_v_crash_test_${os.getpid()}.log')
	os.rm(path) or {}
	pid := C.fork()
	assert pid >= 0, 'fork failed'
	if pid == 0 {
		// Child: inherit the installed handlers, point the log at a fresh file,
		// leave a trail, then abort. alarm() guards against an unexpected hang.
		C.alarm(10)
		// Do not feed the system coredump collector from a test.
		mut lim := RLimit{
			cur: 0
			max: 0
		}
		C.setrlimit(4, &lim) // RLIMIT_CORE
		set_crash_log_path(path)
		log_line('before crash alpha')
		log_line('before crash beta')
		C.raise(6) // SIGABRT
		C._exit(99)
	}
	mut status := 0
	C.waitpid(pid, &status, 0)
	content := os.read_file(path) or { '' }
	assert content.contains('godot-v crash'), 'missing crash header'
	assert content.contains('SIGABRT'), 'missing signal name'
	assert content.contains('before crash alpha'), 'missing recent message'
	assert content.contains('before crash beta'), 'missing recent message'
	assert content.contains('backtrace'), 'missing backtrace'
	os.rm(path) or {}
}

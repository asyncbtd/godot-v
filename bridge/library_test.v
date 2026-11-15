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

const game_manifest = "Module {
	name: 'dodge'
	description: 'test game'
	version: '0.0.0'
	license: 'Apache-2.0'
	dependencies: []
}
"

fn c_library() string {
	$if windows {
		return 'kernel32.dll'
	} $else $if macos {
		return 'libSystem.B.dylib'
	} $else {
		return 'libc.so.6'
	}
}

fn c_symbol() string {
	$if windows {
		return 'GetCurrentProcessId'
	} $else {
		return 'strlen'
	}
}

fn test_script_library_path_finds_one_copy() {
	root := os.join_path(os.vtmp_dir(), 'godot_v_script_lib')
	os.rmdir_all(root) or {}
	os.mkdir_all(root) or { panic(err) }
	defer {
		os.rmdir_all(root) or {}
	}
	os.write_file(os.join_path(root, 'v.mod'), game_manifest) or { panic(err) }
	assert script_library_path(root) == ''
	file_name := 'dodge' + script_library_suffix()
	decoy := os.join_path(root, 'misc', file_name)
	os.mkdir_all(os.dir(decoy)) or { panic(err) }
	os.write_file(decoy, 'x') or { panic(err) }
	assert script_library_path(root) == ''
	dirs := ['', 'bin', 'bins', 'build', 'builds', 'lib', 'libs', 'target', 'targets']
	mut previous := ''
	for dir in dirs {
		if previous != '' {
			os.rm(previous) or { panic(err) }
		}
		path := if dir.len == 0 {
			os.join_path(root, file_name)
		} else {
			os.join_path(root, dir, file_name)
		}
		os.mkdir_all(os.dir(path)) or { panic(err) }
		os.write_file(path, 'x') or { panic(err) }
		assert script_library_path(root) == path
		previous = path
	}
}

fn test_shared_library_symbols() {
	missing := os.join_path(os.vtmp_dir(), 'godot_v_missing.so')
	os.rm(missing) or {}
	assert open_shared(missing) == unsafe { nil }
	$if windows {
		assert load_error() == 'LoadLibrary failed'
	} $else {
		assert load_error().len > 0
	}
	text := os.join_path(os.vtmp_dir(), 'godot_v_not_a_library.so')
	os.write_file(text, 'not a library') or { panic(err) }
	defer {
		os.rm(text) or {}
	}
	assert open_shared(text) == unsafe { nil }
	handle := open_shared(c_library())
	assert handle != unsafe { nil }
	$if windows {
		assert load_error() == 'LoadLibrary failed'
	} $else {
		assert load_error() == ''
	}
	assert symbol_of(handle, c_symbol()) != unsafe { nil }
	assert symbol_of(handle, 'godot_v_no_such_symbol') == unsafe { nil }
	call_symbol(handle, 'godot_v_no_such_symbol')
}

fn test_host_library_reports_the_loaded_extension_only() {
	path := host_library()
	assert path == '' || (path.starts_with('/') && path.ends_with('libgodotv.so'))
	promote_host()
}

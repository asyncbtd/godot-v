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
	assert library_problem(root).contains('must sit next to v.mod')
	os.rm(decoy) or { panic(err) }
	path := os.join_path(root, file_name)
	os.write_file(path, 'x') or { panic(err) }
	assert script_library_path(root) == path
	second := os.join_path(root, 'lib', file_name)
	os.mkdir_all(os.dir(second)) or { panic(err) }
	os.write_file(second, 'x') or { panic(err) }
	assert library_problem(root).contains('found more than one')
}

fn test_shared_library_symbols() {
	missing := os.join_path(os.vtmp_dir(), 'godot_v_missing.so')
	os.rm(missing) or {}
	assert open_shared(missing) == unsafe { nil }
	$if windows {
		assert load_error().starts_with('LoadLibrary failed')
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
	assert load_error() == ''
	assert symbol_of(handle, c_symbol()) != unsafe { nil }
	assert symbol_of(handle, 'godot_v_no_such_symbol') == unsafe { nil }
	call_symbol(handle, 'godot_v_no_such_symbol')
	dyn_close(unsafe { nil })
}

struct KeepDemo {
mut:
	hp i64
}

fn keep_make() voidptr {
	return heap_alloc(int(sizeof(KeepDemo)))
}

fn keep_get(name string) bool {
	if name != 'hp' || bound_state == unsafe { nil } {
		return false
	}
	demo := unsafe { &KeepDemo(bound_state) }
	bound_result = CallValue{
		kind: kind_i64
		i:    demo.hp
	}
	return true
}

fn keep_set(name string) bool {
	if name != 'hp' || bound_state == unsafe { nil } || bound_values.len == 0 {
		return false
	}
	mut demo := unsafe { &KeepDemo(bound_state) }
	demo.hp = bound_values[0].i
	return true
}

fn test_build_arguments_name_the_shared_library() {
	args := build_arguments('dodge.so')
	assert '-shared' in args
	assert '-enable-globals' in args
	assert '-d godot_4_${target_godot_minor()}' in args
	assert '-o' in args
	assert 'dodge.so' in args
	cc := c_compiler()
	if cc != '' {
		assert cc in args
	}
}

fn test_reload_without_godot_does_not_compile() {
	assert reload_game(true) == 0
}

fn test_reload_restores_exported_fields() {
	godot_host.registry.set('keeper', 'Node', []string{})
	godot_host.registry.set_shape('keeper', []MethodRecord{}, [
		PropRecord{
			name:     'hp'
			exported: true
		},
	], []SignalRecord{}, []SignalLink{})
	godot_host.registry.set_runtime('keeper', voidptr(keep_make), unsafe { nil }, voidptr(keep_set),
		voidptr(keep_get), unsafe { nil }, unsafe { nil })
	mut box := ScriptInstance{
		id:    'keeper'
		state: keep_make()
	}
	unsafe {
		(&KeepDemo(box.state)).hp = 7
	}
	saved := godot_host.instances.clone()
	defer {
		godot_host.instances = saved.clone()
	}
	godot_host.instances = [voidptr(&box)]
	kept := capture_fields()
	assert kept.len == 1
	assert kept[0].value.i == 7
	drop_instance_state()
	assert box.state == unsafe { nil }
	apply_fields(kept)
	assert box.state != unsafe { nil }
	restored := unsafe { (&KeepDemo(box.state)).hp }
	assert restored == 7
}

fn test_host_library_reports_the_loaded_extension_only() {
	path := host_library()
	assert path == '' || (path.starts_with('/') && path.ends_with('libgodotv.so'))
	promote_host()
}

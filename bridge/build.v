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

__global library_notice = ''

struct KeptField {
	box   voidptr
	name  string
	value CallValue
}

fn publish_library_problem(problem string) {
	if problem == '' || problem == library_notice {
		return
	}
	library_notice = problem
	report(problem)
}

fn project_dir() string {
	if gdf == unsafe { nil } {
		return ''
	}
	return ProjectSettings.singleton().globalize_path('res://').trim_right('/')
}

fn in_editor() bool {
	if gdf == unsafe { nil } || godot_host.api.engine == unsafe { nil } {
		return false
	}
	return Engine{
		ptr: godot_host.api.engine
	}.is_editor_hint()
}

// c_compiler is the C compiler `v -cc` should use. tcc is skipped: its shared
// libraries lack the non-executable stack flag and Godot refuses to load them.
fn c_compiler() string {
	$if windows {
		choices := ['gcc', 'clang', 'cl']
		names := ['gcc', 'clang', 'msvc']
		for i, exe in choices {
			if os.exists_in_system_path(exe) {
				return names[i]
			}
		}
	} $else {
		for exe in ['clang', 'gcc'] {
			if os.exists_in_system_path(exe) {
				return exe
			}
		}
	}
	return ''
}

// build_arguments is the `v` invocation that writes the game library next to v.mod.
fn build_arguments(output string) []string {
	mut args := []string{}
	cc := c_compiler()
	if cc != '' {
		args << ['-cc', cc]
	}
	args << ['-shared', '-enable-globals', '-d godot_4_${target_godot_minor()}', '-o', output,
		'.']
	return args
}

fn run_compiler(project string, args []string) (int, string) {
	if c_compiler() == '' {
		return 127, 'Build V needs gcc, clang, or msvc on PATH'
	}
	bin := os.find_abs_path_of_executable('v') or {
		return 127, 'v compiler was not found on PATH'
	}
	mut compiler := os.new_process(bin)
	compiler.set_args(args)
	compiler.set_work_folder(project)
	compiler.set_redirect_stdio_merged()
	compiler.run()
	compiler.wait()
	text := compiler.stdout_slurp()
	code := compiler.code
	compiler.close()
	return code, text
}

fn install_built_library(staged string, dest string) bool {
	os.rm(dest) or {}
	os.mv(staged, dest) or {
		report('Build V could not replace ${dest}: ${err}')
		return false
	}
	return true
}

fn reload_game(keep_state bool) i64 {
	if gdf == unsafe { nil } {
		return 0
	}
	project := project_dir()
	if project == '' {
		return 0
	}
	file_name := library_file_name(project) or {
		publish_library_problem(err.msg())
		return i64(GDError.err_compilation_failed)
	}
	dest := os.join_path(project, file_name)
	problem := library_problem(project)
	if problem != '' {
		publish_library_problem(problem)
		return i64(GDError.err_compilation_failed)
	}
	staged := dest + '.build'
	if in_editor() {
		code, text := run_compiler(project, build_arguments(staged))
		if code != 0 {
			os.rm(staged) or {}
			report('Build V failed')
			for line in text.split_into_lines() {
				if line != '' {
					report(line)
				}
			}
			return i64(GDError.err_compilation_failed)
		}
	} else if os.exists(dest) == false {
		publish_library_problem('${file_name} must sit next to v.mod')
		return i64(GDError.err_compilation_failed)
	}
	mut kept := []KeptField{}
	if keep_state {
		kept = capture_fields()
	}
	drop_instance_state()
	close_game_library()
	if in_editor() {
		if install_built_library(staged, dest) == false {
			return i64(GDError.err_compilation_failed)
		}
	}
	if open_script_library(dest) == false {
		return i64(GDError.failed)
	}
	library_notice = ''
	if keep_state {
		apply_fields(kept)
	}
	reload_script_sources(project)
	return 0
}

fn library_problem(project string) string {
	resolve_game_library(project) or { return err.msg() }
	return ''
}

fn drop_instance_state() {
	for data in godot_host.instances {
		mut box := script_instance_of(data)
		if box == unsafe { nil } {
			continue
		}
		box.state = unsafe { nil }
	}
}

fn capture_fields() []KeptField {
	mut kept := []KeptField{}
	for data in godot_host.instances {
		box := script_instance_of(data)
		if box == unsafe { nil } {
			continue
		}
		info := godot_host.registry.hook(box.script_key())
		for prop in info.props {
			if value := read_field(box, info.get_prop, prop.name) {
				kept << KeptField{
					box:   data
					name:  prop.name
					value: value
				}
			}
		}
	}
	return kept
}

fn apply_fields(kept []KeptField) {
	mut ready := map[voidptr]bool{}
	for item in kept {
		if ready[item.box] {
			continue
		}
		mut box := script_instance_of(item.box)
		if box == unsafe { nil } {
			continue
		}
		info := godot_host.registry.hook(box.script_key())
		if box.state == unsafe { nil } && info.factory != unsafe { nil } {
			make := unsafe { StateFactory(info.factory) }
			box.state = make()
		}
		ready[item.box] = true
	}
	for item in kept {
		box := script_instance_of(item.box)
		if box == unsafe { nil } {
			continue
		}
		info := godot_host.registry.hook(box.script_key())
		write_field(box, info.set_prop, item.name, item.value)
	}
}

fn read_field(box &ScriptInstance, get_prop voidptr, name string) ?CallValue {
	if get_prop == unsafe { nil } || box.state == unsafe { nil } {
		return none
	}
	previous_state := bound_state
	previous_force := bound_force
	previous_key := bound_key
	previous_result := bound_result
	bound_key = box.script_key()
	bound_state = box.state
	bound_force = true
	f := unsafe { PropFn(get_prop) }
	ok := f(name)
	value := bound_result
	bound_state = previous_state
	bound_force = previous_force
	bound_key = previous_key
	bound_result = previous_result
	if ok == false {
		return none
	}
	return value
}

fn write_field(box &ScriptInstance, set_prop voidptr, name string, value CallValue) {
	if set_prop == unsafe { nil } || box.state == unsafe { nil } {
		return
	}
	previous_state := bound_state
	previous_force := bound_force
	previous_key := bound_key
	previous_values := bound_values.clone()
	bound_key = box.script_key()
	bound_state = box.state
	bound_force = true
	bound_values = [value]
	f := unsafe { PropFn(set_prop) }
	f(name)
	bound_state = previous_state
	bound_force = previous_force
	bound_key = previous_key
	bound_values = previous_values.clone()
}

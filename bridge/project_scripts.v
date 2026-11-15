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
import v.vmod

fn open_script_library(path string) bool {
	promote_host()
	handle := dyn_open(path)
	if handle == unsafe { nil } {
		report('script library failed to load: ' + dyn_last_error())
		return false
	}
	godot_host.library = handle
	call_symbol(handle, 'godot__init')
	call_symbol(handle, 'script__init')
	return true
}

fn close_game_library() {
	dyn_close(godot_host.library)
	godot_host.library = unsafe { nil }
}

fn remember_script(state voidptr) {
	if state == unsafe { nil } {
		return
	}
	path := script_state(state).path.text()
	if path.len == 0 {
		return
	}
	for item in godot_host.scripts {
		if script_state(item).path.text() == path {
			return
		}
	}
	godot_host.scripts << state
}

fn reload_script_sources(project string) {
	for state in godot_host.scripts {
		res_path := script_state(state).path.text()
		if res_path.starts_with('res://') == false {
			continue
		}
		full := os.join_path(project, res_path.all_after('res://'))
		text := os.read_file(full) or { continue }
		set_script_source(state, text)
	}
}

fn ensure_project_scripts() {
	if godot_host.library != unsafe { nil } || godot_host.api.singleton == unsafe { nil } {
		return
	}
	load_project_scripts()
}

fn script_library_suffix() string {
	$if windows {
		return '.dll'
	} $else $if macos {
		return '.dylib'
	} $else {
		return '.so'
	}
}

fn library_file_name(project string) !string {
	mod_path := os.join_path(project, 'v.mod')
	text := os.read_file(mod_path) or { return error('game v.mod not found at ${mod_path}') }
	manifest := vmod.decode(text) or { return error('game v.mod at ${mod_path} is invalid: ${err}') }
	if manifest.name == '' {
		return error('game v.mod at ${mod_path} has no name')
	}
	return manifest.name + script_library_suffix()
}

// resolve_game_library returns the library that sits next to v.mod.
// The file name is the module name. Another copy in a child directory is an error.
fn resolve_game_library(project string) !string {
	file_name := library_file_name(project)!
	root := os.join_path(project, file_name)
	mut found := []string{}
	if os.exists(root) {
		found << root
	}
	for entry in os.ls(project) or { []string{} } {
		dir := os.join_path(project, entry)
		if os.is_dir(dir) == false {
			continue
		}
		candidate := os.join_path(dir, file_name)
		if os.exists(candidate) {
			found << candidate
		}
	}
	if found.len > 1 {
		return error('found more than one ${file_name}:\n' + found.join('\n'))
	}
	if found.len == 1 && found[0] != root {
		return error('${file_name} must sit next to v.mod, found ${found[0]}')
	}
	if found.len == 0 {
		return ''
	}
	return root
}

fn script_library_path(project string) string {
	path := resolve_game_library(project) or { return '' }
	return path
}

fn load_project_scripts() {
	if gdf == unsafe { nil } {
		return
	}
	project := ProjectSettings.singleton().globalize_path('res://').trim_right('/')
	if project.len == 0 {
		return
	}
	so_path := resolve_game_library(project) or {
		publish_library_problem(err.msg())
		return
	}
	if so_path.len == 0 || godot_host.library != unsafe { nil } {
		return
	}
	library_notice = ''
	if open_script_library(so_path) == false {
		return
	}
	reload_script_sources(project)
}

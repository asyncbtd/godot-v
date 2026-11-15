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
	handle := open_shared(path)
	if handle == unsafe { nil } {
		report('script library failed to load: ' + load_error())
		return false
	}
	godot_host.library = handle
	call_symbol(handle, 'godot__init')
	call_symbol(handle, 'script__init')
	return true
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

fn script_library_path(project string) string {
	mod_path := os.join_path(project, 'v.mod')
	text := os.read_file(mod_path) or { panic('game v.mod not found at ${mod_path}') }
	manifest := vmod.decode(text) or { panic('game v.mod at ${mod_path} is invalid: ${err}') }
	if manifest.name.len == 0 {
		panic('game v.mod at ${mod_path} has no name')
	}
	file_name := manifest.name + script_library_suffix()
	mut found := []string{}
	for dir in ['', 'bin', 'bins', 'build', 'builds', 'lib', 'libs', 'target', 'targets'] {
		path := if dir.len == 0 {
			os.join_path(project, file_name)
		} else {
			os.join_path(project, dir, file_name)
		}
		if os.exists(path) {
			found << path
		}
	}
	if found.len == 0 {
		return ''
	}
	if found.len > 1 {
		panic('found more than one ${file_name}:\n' + found.join('\n'))
	}
	return found[0]
}

fn load_project_scripts() {
	if gdf == unsafe { nil } {
		return
	}
	project := ProjectSettings.singleton().globalize_path('res://').trim_right('/')
	if project.len == 0 {
		return
	}
	so_path := script_library_path(project)
	if so_path.len == 0 || godot_host.library != unsafe { nil } {
		return
	}
	if open_script_library(so_path) == false {
		return
	}
	reload_script_sources(project)
}

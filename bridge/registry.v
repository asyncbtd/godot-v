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

type HookSignal = fn (string) bool

type EnterFn = fn ()

struct ScriptBinding {
mut:
	key     string
	base    string
	methods []string
}

struct ScriptHook {
mut:
	key    string
	enter  voidptr
	frame  voidptr
	signal voidptr
}

struct Registry {
mut:
	bindings []ScriptBinding
	hooks    []ScriptHook
}

__global registry = Registry{}

fn script_id_of_path(path string) string {
	name := path.all_after_last('/')
	if name.ends_with('.v') {
		return name[..name.len - 2]
	}
	return name
}

fn (mut r Registry) set(key string, base string, methods []string) {
	for i, slot in r.bindings {
		if slot.key == key {
			r.bindings[i].base = base
			r.bindings[i].methods = methods
			return
		}
	}
	r.bindings << ScriptBinding{
		key:     key
		base:    base
		methods: methods
	}
}

fn (r &Registry) get(key string) ?ScriptBinding {
	for slot in r.bindings {
		if slot.key == key {
			return slot
		}
	}
	return none
}

fn (mut r Registry) add_script(key string, enter voidptr, frame voidptr, signal voidptr) {
	for i, slot in r.hooks {
		if slot.key == key {
			r.hooks[i].enter = enter
			r.hooks[i].frame = frame
			r.hooks[i].signal = signal
			return
		}
	}
	r.hooks << ScriptHook{
		key:    key
		enter:  enter
		frame:  frame
		signal: signal
	}
}

fn (r &Registry) hook(path string) ScriptHook {
	key := script_id_of_path(path)
	for slot in r.hooks {
		if slot.key == key {
			return slot
		}
	}
	return ScriptHook{}
}

fn (r &Registry) has_method(path string, name string) bool {
	if slot := r.get(script_id_of_path(path)) {
		return name in slot.methods
	}
	return false
}

fn call_signal(signal voidptr, name string) bool {
	if signal == unsafe { nil } {
		return false
	}
	f := unsafe { HookSignal(signal) }
	return f(name)
}

fn run_script_method(data voidptr, name string) bool {
	if data == unsafe { nil } || name == '' {
		return false
	}
	ensure_project_scripts()
	box := script_instance_of(data)
	if box == unsafe { nil } {
		return false
	}
	if registry.has_method(box.path.text(), name) == false {
		return false
	}
	previous := bound_owner
	bound_owner = box.node
	hook := registry.hook(box.path.text())
	ok := call_signal(hook.signal, name)
	bound_owner = previous
	return ok
}

fn run_script_enter(data voidptr) {
	if data == unsafe { nil } {
		return
	}
	box := script_instance_of(data)
	if box == unsafe { nil } {
		return
	}
	if registry.has_method(box.path.text(), '_ready') {
		return
	}
	hook := registry.hook(box.path.text())
	if hook.enter == unsafe { nil } {
		return
	}
	previous := bound_owner
	bound_owner = box.node
	f := unsafe { EnterFn(hook.enter) }
	f()
	bound_owner = previous
}

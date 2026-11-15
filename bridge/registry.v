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

struct ScriptHook {
mut:
	key    string
	enter  voidptr
	frame  voidptr
	signal voidptr
}

__global script_hooks = []ScriptHook{}

fn source_has_method(source string, name string) bool {
	if name == '' || source == '' {
		return false
	}
	if source.contains("name == '${name}'") {
		return true
	}
	if source.contains('name == "${name}"') {
		return true
	}
	return source.contains(') ${name}(')
}

fn script_key(path string) string {
	name := path.all_after_last('/')
	if name.ends_with('.v') {
		return name[..name.len - 2]
	}
	return name
}

fn bind_script(key string, enter voidptr, frame voidptr, signal voidptr) {
	for i, slot in script_hooks {
		if slot.key == key {
			script_hooks[i].enter = enter
			script_hooks[i].frame = frame
			script_hooks[i].signal = signal
			return
		}
	}
	script_hooks << ScriptHook{
		key:    key
		enter:  enter
		frame:  frame
		signal: signal
	}
}

fn hook_for(path string) ScriptHook {
	key := script_key(path)
	for slot in script_hooks {
		if slot.key == key {
			return slot
		}
	}
	return ScriptHook{}
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
	box := live_box(data)
	if box == unsafe { nil } {
		return false
	}
	if answers(box.path.text(), box.source.text(), name) == false {
		return false
	}
	previous := bound_owner
	bound_owner = box.owner
	hook := hook_for(box.path.text())
	ok := call_signal(hook.signal, name)
	bound_owner = previous
	return ok
}

fn run_script_enter(data voidptr) {
	if data == unsafe { nil } {
		return
	}
	box := live_box(data)
	if box == unsafe { nil } {
		return
	}
	if answers(box.path.text(), box.source.text(), '_ready') {
		return
	}
	hook := hook_for(box.path.text())
	if hook.enter == unsafe { nil } {
		return
	}
	previous := bound_owner
	bound_owner = box.owner
	f := unsafe { EnterFn(hook.enter) }
	f()
	bound_owner = previous
}

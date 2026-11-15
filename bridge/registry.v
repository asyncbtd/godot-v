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

type EnterFn = fn ()
type ScriptCall = fn (voidptr, string) bool

struct ScriptInfo {
mut:
	id         string
	base       string
	methods    []string
	info       []MethodRecord
	props      []PropRecord
	signals    []SignalRecord
	links      []SignalLink
	facts      ClassFacts
	factory    voidptr
	call       voidptr
	set_prop   voidptr
	get_prop   voidptr
	can_revert voidptr
	get_revert voidptr
	enter      voidptr
	frame      voidptr
}

struct Registry {
mut:
	scripts []ScriptInfo
}

fn script_id_of_path(path string) string {
	name := path.replace('\\', '/').all_after_last('/')
	if name.ends_with('.v') {
		return name[..name.len - 2]
	}
	return name
}

fn script_stem(key string) string {
	name := key.replace('\\', '/').all_after_last('/').to_lower()
	if name.ends_with('.v') {
		return name[..name.len - 2]
	}
	return name.all_after_last('.')
}

fn compact_stem(key string) string {
	return script_stem(key).replace('_', '')
}

fn (r &Registry) find(key string) int {
	id := key.replace('\\', '/').to_lower()
	stem := script_stem(id)
	flat := compact_stem(id)
	for i, slot in r.scripts {
		if slot.id == id || slot.id == stem || slot.id.ends_with('.' + stem)
			|| (flat != '' && compact_stem(slot.id) == flat) {
			return i
		}
	}
	return -1
}

fn (r &Registry) get(key string) ?ScriptInfo {
	index := r.find(key)
	if index < 0 {
		return none
	}
	return r.scripts[index]
}

fn (mut r Registry) set(key string, base string, methods []string) {
	id := key.to_lower()
	index := r.find(id)
	if index >= 0 {
		r.scripts[index].base = base
		r.scripts[index].methods = methods.clone()
		return
	}
	r.scripts << ScriptInfo{
		id:      id
		base:    base
		methods: methods.clone()
	}
}

fn (mut r Registry) set_shape(key string, info []MethodRecord, props []PropRecord, signals []SignalRecord, links []SignalLink) {
	index := r.find(key)
	if index < 0 {
		return
	}
	r.scripts[index].info = info.clone()
	r.scripts[index].props = props.clone()
	r.scripts[index].signals = signals.clone()
	r.scripts[index].links = links.clone()
}

fn (mut r Registry) set_class(key string, facts ClassFacts) {
	index := r.find(key)
	if index < 0 {
		return
	}
	r.scripts[index].facts = facts
}

fn (mut r Registry) set_runtime(key string, factory voidptr, call voidptr, set_prop voidptr, get_prop voidptr, can_revert voidptr, get_revert voidptr) {
	index := r.find(key)
	if index < 0 {
		return
	}
	r.scripts[index].factory = factory
	r.scripts[index].call = call
	r.scripts[index].set_prop = set_prop
	r.scripts[index].get_prop = get_prop
	r.scripts[index].can_revert = can_revert
	r.scripts[index].get_revert = get_revert
}

fn (mut r Registry) add_script(key string, enter voidptr, frame voidptr, call voidptr) {
	id := script_stem(key)
	index := r.find(id)
	if index >= 0 {
		r.scripts[index].enter = enter
		r.scripts[index].frame = frame
		r.scripts[index].call = call
		return
	}
	r.scripts << ScriptInfo{
		id:    id
		enter: enter
		frame: frame
		call:  call
	}
}

fn (r &Registry) hook(key string) ScriptInfo {
	return r.get(key) or { return ScriptInfo{} }
}

fn (r &Registry) has_method(key string, name string) bool {
	if name == '' {
		return false
	}
	slot := r.get(key) or { return false }
	plain := name.trim_left('_')
	for method in slot.methods {
		if method == name || method == plain {
			return true
		}
	}
	return false
}

fn call_script(callback voidptr, owner voidptr, name string) bool {
	if callback == unsafe { nil } {
		return false
	}
	f := unsafe { ScriptCall(callback) }
	return f(owner, name)
}

fn run_script_method(data voidptr, name string) bool {
	return run_script_call(data, name, unsafe { nil }, 0, unsafe { nil })
}

fn run_script_call(data voidptr, name string, args voidptr, count i64, ret voidptr) bool {
	if data == unsafe { nil } || name == '' {
		return false
	}
	ensure_project_scripts()
	mut box := script_instance_of(data)
	if box == unsafe { nil } {
		return false
	}
	key := box.script_key()
	if godot_host.registry.has_method(key, name) == false {
		return false
	}
	previous_state := bound_state
	previous_type := bound_state_type
	previous_force := bound_force
	previous_values := bound_values.clone()
	previous_ret := bound_ret
	previous_key := bound_key
	bound_key = key
	bound_ret = ret
	if box.state != unsafe { nil } {
		bound_state = box.state
		bound_force = true
	} else {
		bound_state = unsafe { nil }
		bound_force = false
		bound_state_type = ''
	}
	if args != unsafe { nil } {
		bound_values = decode_args(args, count)
	}
	hook := godot_host.registry.hook(key)
	ok := call_script(hook.call, box.node, name)
	if box.state == unsafe { nil } && bound_state != unsafe { nil } {
		box.state = bound_state
	}
	bound_state = previous_state
	bound_state_type = previous_type
	bound_force = previous_force
	bound_values = previous_values.clone()
	bound_ret = previous_ret
	bound_key = previous_key
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
	if godot_host.registry.has_method(box.script_key(), '_ready') {
		return
	}
	hook := godot_host.registry.hook(box.script_key())
	if hook.enter == unsafe { nil } {
		return
	}
	f := unsafe { EnterFn(hook.enter) }
	f()
}

fn (s &ScriptInstance) script_key() string {
	if s.id.len > 0 {
		return s.id
	}
	return script_id_of_path(s.path.text())
}

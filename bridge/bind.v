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

// NodeClass is the native class of the node that carries this script.
@[attribute]
pub struct NodeClass {
pub:
	name string
}

// SignalOn marks which signal a method handles. The editor connects it.
@[attribute]
pub struct SignalOn {
pub:
	node string
	name string
}

struct ScriptBinding {
mut:
	key     string
	base    string
	methods []string
}

__global script_bindings = []ScriptBinding{}

// register reads NodeClass and the methods of T and stores them under the struct name.
pub fn register[T]() int {
	mut base := ''
	$for attr in T.attributes {
		$if attr is NodeClass {
			base = attr.name
		}
	}
	mut methods := []string{}
	$for method in T.methods {
		if method.args.len == 0 {
			methods << method.name
			if method.name == 'ready' {
				methods << '_ready'
			}
		}
		if method.args.len == 1 && method.name == 'process' {
			methods << 'process'
			methods << '_process'
		}
	}
	key := T.name.all_after_last('.').to_lower()
	store_binding(key, base, methods)
	bind_script(key, unsafe { nil }, unsafe { nil }, voidptr(call_named[T]))
	return 0
}

fn call_named[T](name string) bool {
	mut self := T{}
	mut found := false
	$for method in T.methods {
		if method.args.len == 0 && (method.name == name || (method.name == 'ready' && name == '_ready')) {
			self.$method()
			found = true
		}
	}
	$for method in T.methods {
		if method.args.len == 1 && method.name == 'process' && (name == 'process' || name == '_process') {
			self.$method(delta_of(owner()))
			found = true
		}
	}
	return found
}

fn store_binding(key string, base string, methods []string) {
	for i, slot in script_bindings {
		if slot.key == key {
			script_bindings[i].base = base
			script_bindings[i].methods = methods
			return
		}
	}
	script_bindings << ScriptBinding{
		key:     key
		base:    base
		methods: methods
	}
}

fn binding_of_key(key string) ?ScriptBinding {
	for slot in script_bindings {
		if slot.key == key {
			return slot
		}
	}
	return none
}

fn base_for(path string) string {
	slot := binding_of_key(script_key(path)) or { return 'Node' }
	if slot.base.len == 0 {
		return 'Node'
	}
	return slot.base
}

fn answers(path string, source string, name string) bool {
	if slot := binding_of_key(script_key(path)) {
		return name in slot.methods
	}
	return source_has_method(source, name)
}

fn refresh_base(mut state ScriptState) {
	path := state.path.text()
	if path.len == 0 {
		return
	}
	state.base.set_text(base_for(path))
}

fn write_methods(instance voidptr, ret voidptr) {
	write_array(ret)
	state := script_state(instance)
	slot := binding_of_key(script_key(state.path.text())) or { return }
	for name in slot.methods {
		item := scratch()
		dictionary_text(item, 'name', name)
		push_array(ret, item)
		free_variant(item)
	}
}

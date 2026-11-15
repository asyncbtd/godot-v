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
	registry.set(key, base, methods)
	registry.add_script(key, unsafe { nil }, unsafe { nil }, voidptr(call_named[T]))
	return 0
}

fn attach_base[T](mut self T) {
	$for field in T.fields {
		$if field.name == 'base' && field.typ is Node {
			self.base.ptr = bound_owner
		}
	}
}

fn call_named[T](name string) bool {
	mut self := T{}
	attach_base(mut self)
	mut found := false
	$for method in T.methods {
		if method.args.len == 0 && (method.name == name || (method.name == 'ready' && name == '_ready')) {
			self.$method()
			found = true
		}
	}
	$for method in T.methods {
		if method.args.len == 1 && method.name == 'process' && (name == 'process' || name == '_process') {
			$for field in T.fields {
				$if field.name == 'base' && field.typ is Node {
					self.$method(delta_of(self.base.ptr))
					found = true
				}
			}
		}
	}
	return found
}

fn base_for(path string) string {
	slot := registry.get(script_id_of_path(path)) or { return 'Node' }
	if slot.base.len == 0 {
		return 'Node'
	}
	return slot.base
}

fn refresh_base(mut state ScriptResource) {
	path := state.path.text()
	if path.len == 0 {
		return
	}
	state.base.set_text(base_for(path))
}

fn write_methods(instance voidptr, ret voidptr) {
	write_array(ret)
	state := script_state(instance)
	slot := registry.get(script_id_of_path(state.path.text())) or { return }
	for name in slot.methods {
		item := temp_variant()
		dictionary_text(item, 'name', name)
		push_array(ret, item)
		free_variant(item)
	}
}

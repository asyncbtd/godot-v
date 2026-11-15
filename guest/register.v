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

// Export marks a field for the inspector and for scene storage.
@[attribute]
pub struct Export {}

// ExportRange marks a numeric field with a minimum and a maximum.
@[attribute]
pub struct ExportRange {
pub:
	min int
	max int
}

// ExportEnum marks a field whose value is one of a comma-separated list.
@[attribute]
pub struct ExportEnum {
pub:
	values string
}

// Tool runs the script inside the editor.
@[attribute]
pub struct Tool {}

// Abstract marks a script that cannot be instantiated.
@[attribute]
pub struct Abstract {}

// Icon is the path of the class icon shown in the editor.
@[attribute]
pub struct Icon {
pub:
	path string
}

// Rpc exposes a method to the multiplayer API.
@[attribute]
pub struct Rpc {}

// register reads NodeClass, methods, exports, and signals of T and stores them under the struct name.
pub fn register[T]() int {
	mut base := ''
	mut tool := false
	mut abstract := false
	mut icon := ''
	$for attr in T.attributes {
		$if attr is NodeClass {
			base = attr.name
		}
		$if attr is Tool {
			tool = true
		}
		$if attr is Abstract {
			abstract = true
		}
		$if attr is Icon {
			icon = attr.path
		}
	}
	mut methods := []string{}
	mut info := []MethodRecord{}
	mut props := []PropRecord{}
	mut signals := []SignalRecord{}
	mut links := []SignalLink{}
	mut rpcs := []string{}
	$for method in T.methods {
		mut rec := MethodRecord{
			name: method.name
		}
		mut ret_name := ''
		$if method.return_type is bool {
			ret_name = 'bool'
		}
		$if method.return_type is int {
			ret_name = 'int'
		}
		$if method.return_type is i64 {
			ret_name = 'i64'
		}
		$if method.return_type is f32 {
			ret_name = 'f32'
		}
		$if method.return_type is f64 {
			ret_name = 'f64'
		}
		$if method.return_type is string {
			ret_name = 'string'
		}
		$if method.return_type is Vector2 {
			ret_name = 'Vector2'
		}
		$if method.return_type is Object {
			ret_name = 'Object'
		}
		$if method.return_type is voidptr {
			ret_name = 'voidptr'
		}
		rec.ret = ret_name
		mut args := []MethodArg{}
		mut known := false
		$if method.args.len == 0 {
			known = true
		}
		$if method.args.len == 1 {
			mut typ := ''
			$if method.args[0].typ is bool {
				typ = 'bool'
			}
			$if method.args[0].typ is int {
				typ = 'int'
			}
			$if method.args[0].typ is i64 {
				typ = 'i64'
			}
			$if method.args[0].typ is f32 {
				typ = 'f32'
			}
			$if method.args[0].typ is f64 {
				typ = 'f64'
			}
			$if method.args[0].typ is string {
				typ = 'string'
			}
			$if method.args[0].typ is Vector2 {
				typ = 'Vector2'
			}
			$if method.args[0].typ is Object {
				typ = 'Object'
			}
			$if method.args[0].typ is voidptr {
				typ = 'voidptr'
			}
			if typ != '' {
				known = true
				args << MethodArg{
					typ: typ
				}
			}
		}
		$if method.args.len == 2 {
			mut left := ''
			mut right := ''
			$if method.args[0].typ is bool {
				left = 'bool'
			}
			$if method.args[0].typ is int {
				left = 'int'
			}
			$if method.args[0].typ is i64 {
				left = 'i64'
			}
			$if method.args[0].typ is f32 {
				left = 'f32'
			}
			$if method.args[0].typ is f64 {
				left = 'f64'
			}
			$if method.args[0].typ is string {
				left = 'string'
			}
			$if method.args[1].typ is bool {
				right = 'bool'
			}
			$if method.args[1].typ is int {
				right = 'int'
			}
			$if method.args[1].typ is i64 {
				right = 'i64'
			}
			$if method.args[1].typ is f32 {
				right = 'f32'
			}
			$if method.args[1].typ is f64 {
				right = 'f64'
			}
			$if method.args[1].typ is string {
				right = 'string'
			}
			if left != '' && left == right {
				known = true
				args << MethodArg{
					typ: left
				}
				args << MethodArg{
					typ: right
				}
			}
		}
		rec.args = args
		if known {
			methods << method.name
			if method.args.len == 0 && virtual_zero(method.name) {
				methods << '_${method.name}'
			}
			$if method.args.len == 1 {
				$if method.args[0].typ is f64 {
					if virtual_delta(method.name) {
						methods << '_${method.name}'
					}
				}
				$if method.args[0].typ is Object {
					if virtual_input(method.name) {
						methods << '_${method.name}'
					}
				}
				$if method.args[0].typ is voidptr {
					if virtual_input(method.name) {
						methods << '_${method.name}'
					}
				}
			}
		}
		$for attr in method.attributes {
			$if attr is SignalOn {
				links << SignalLink{
					method: method.name
					node:   attr.node
					signal: attr.name
				}
			}
			$if attr is Rpc {
				rec.rpc = true
				rpcs << method.name
			}
		}
		info << rec
	}
	$for field in T.fields {
		if field.name != 'base' {
			mut prop := PropRecord{
				name: field.name
			}
			$if field.typ is bool {
				prop.typ = 'bool'
			}
			$if field.typ is int {
				prop.typ = 'int'
			}
			$if field.typ is i64 {
				prop.typ = 'i64'
			}
			$if field.typ is f32 {
				prop.typ = 'f32'
			}
			$if field.typ is f64 {
				prop.typ = 'f64'
			}
			$if field.typ is string {
				prop.typ = 'string'
			}
			$for attr in field.attributes {
				$if attr is Export {
					prop.exported = true
				}
				$if attr is ExportRange {
					prop.exported = true
					prop.hint = 'range'
					prop.hint_string = '${attr.min},${attr.max}'
				}
				$if attr is ExportEnum {
					prop.exported = true
					prop.hint = 'enum'
					prop.hint_string = attr.values
				}
			}
			if prop.exported {
				props << prop
			}
			$if field.typ is VSignal[bool] {
				signals << signal_of(field.name, 'bool')
			}
			$if field.typ is VSignal[int] {
				signals << signal_of(field.name, 'int')
			}
			$if field.typ is VSignal[i64] {
				signals << signal_of(field.name, 'i64')
			}
			$if field.typ is VSignal[f32] {
				signals << signal_of(field.name, 'f32')
			}
			$if field.typ is VSignal[f64] {
				signals << signal_of(field.name, 'f64')
			}
			$if field.typ is VSignal[string] {
				signals << signal_of(field.name, 'string')
			}
		}
	}
	key := T.name.all_after_last('.').to_lower()
	registry.set(key, base, methods)
	registry.set_shape(key, info, props, signals, links)
	registry.set_class(key, ClassFacts{
		name:     T.name.all_after_last('.')
		base:     base
		icon:     icon
		tool:     tool
		abstract: abstract
		rpcs:     rpcs.clone()
	})
	registry.set_runtime(key, voidptr(alloc_state[T]), voidptr(call_named[T]), voidptr(set_named[T]),
		voidptr(get_named[T]), voidptr(can_revert_named[T]), voidptr(revert_named[T]))
	return 0
}

fn signal_of(name string, typ string) SignalRecord {
	return SignalRecord{
		name: name
		args: [
			MethodArg{
				typ: typ
			},
		]
	}
}

fn attach_base[T](mut self T) {
	$for field in T.fields {
		$if field.name == 'base' && field.typ is Node {
			self.base.ptr = bound_owner
		}
	}
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

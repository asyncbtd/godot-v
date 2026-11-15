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

fn with_hook(data voidptr, name voidptr, value voidptr, which string) bool {
	mut box := script_instance_of(data)
	if box == unsafe { nil } {
		return false
	}
	hook := godot_host.registry.hook(box.script_key())
	target := match which {
		'set' { hook.set_prop }
		'get' { hook.get_prop }
		'revert' { hook.can_revert }
		'origin' { hook.get_revert }
		else { unsafe { nil } }
	}
	if target == unsafe { nil } {
		return false
	}
	previous_state := bound_state
	previous_type := bound_state_type
	previous_force := bound_force
	previous_values := bound_values.clone()
	previous_ret := bound_ret
	previous_key := bound_key
	bound_key = box.script_key()
	bound_ret = value
	if box.state != unsafe { nil } {
		bound_state = box.state
		bound_force = true
	} else {
		bound_state = unsafe { nil }
		bound_force = false
	}
	if which == 'set' {
		bound_values = [value_from_variant(value)]
		bound_ret = unsafe { nil }
	}
	f := unsafe { PropFn(target) }
	ok := f(read_name(name))
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

fn instance_set(data voidptr, name voidptr, value voidptr) u8 {
	if with_hook(data, name, value, 'set') {
		return 1
	}
	return 0
}

fn instance_get(data voidptr, name voidptr, value voidptr) u8 {
	if with_hook(data, name, value, 'get') {
		return 1
	}
	return 0
}

fn instance_can_revert(data voidptr, name voidptr) u8 {
	if with_hook(data, name, unsafe { nil }, 'revert') {
		return 1
	}
	return 0
}

fn instance_get_revert(data voidptr, name voidptr, value voidptr) u8 {
	if with_hook(data, name, value, 'origin') {
		return 1
	}
	return 0
}

fn instance_arg_count(data voidptr, method voidptr, valid voidptr) i64 {
	box := script_instance_of(data)
	if box == unsafe { nil } {
		return 0
	}
	name := read_name(method)
	plain := if name.starts_with('_') { name[1..] } else { name }
	if slot := godot_host.registry.get(box.script_key()) {
		for method_info in slot.info {
			if method_info.name == name || method_info.name == plain {
				if valid != unsafe { nil } {
					unsafe {
						*&u8(valid) = 1
					}
				}
				return i64(method_info.args.len)
			}
		}
	}
	if valid != unsafe { nil } {
		unsafe {
			*&u8(valid) = 0
		}
	}
	return 0
}

fn instance_property_list(data voidptr, count &u32) &GDExtensionPropertyInfo {
	unsafe {
		*count = 0
	}
	if gdf == unsafe { nil } {
		return unsafe { nil }
	}
	box := script_instance_of(data)
	if box == unsafe { nil } {
		return unsafe { nil }
	}
	slot := godot_host.registry.get(box.script_key()) or { return unsafe { nil } }
	mut props := []PropRecord{}
	for prop in slot.props {
		if prop.exported {
			props << prop
		}
	}
	if props.len == 0 {
		return unsafe { nil }
	}
	list := unsafe { &GDExtensionPropertyInfo(heap_alloc(int(sizeof(GDExtensionPropertyInfo)) * props.len)) }
	for i, prop in props {
		mut info := GDExtensionPropertyInfo{
			type_: variant_type_of(prop.typ)
			hint:  hint_code(prop.hint)
			usage: 4102
		}
		name := StringName.new1(prop.name)
		info.name = heap_string_name(name)
		if prop.hint_string != '' {
			hint := String.new1(prop.hint_string)
			info.hint_string = heap_string(hint)
		}
		unsafe {
			list[i] = info
		}
	}
	unsafe {
		*count = u32(props.len)
	}
	return list
}

fn instance_free_property_list(_data voidptr, list &GDExtensionPropertyInfo, count u32) {
	if list == unsafe { nil } || count == 0 {
		return
	}
	for i in 0 .. int(count) {
		info := unsafe { list[i] }
		release_godot(voidptr(info.name), GDExtensionVariantType.type_stringname)
		release_godot(voidptr(info.hint_string), GDExtensionVariantType.type_string)
	}
	heap_free(voidptr(list))
}

fn variant_type_of(name string) GDExtensionVariantType {
	return match name {
		'bool' { GDExtensionVariantType.type_bool }
		'int', 'i64' { GDExtensionVariantType.type_int }
		'f32', 'f64' { GDExtensionVariantType.type_float }
		'string' { GDExtensionVariantType.type_string }
		'Vector2' { GDExtensionVariantType.type_vector2 }
		'Object', 'voidptr' { GDExtensionVariantType.type_object }
		else { GDExtensionVariantType.type_nil }
	}
}

fn hint_code(name string) u32 {
	return match name {
		'range' { u32(1) }
		'enum' { u32(2) }
		else { u32(0) }
	}
}

fn heap_string_name(value StringName) &StringName {
	ptr := heap_alloc(int(sizeof(StringName)))
	unsafe {
		*(&StringName(ptr)) = value
	}
	return unsafe { &StringName(ptr) }
}

fn heap_string(value String) &String {
	ptr := heap_alloc(int(sizeof(String)))
	unsafe {
		*(&String(ptr)) = value
	}
	return unsafe { &String(ptr) }
}

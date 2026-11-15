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

struct InstanceInfo {
mut:
	set_func                       voidptr
	get_func                       voidptr
	get_property_list_func         voidptr
	free_property_list_func        voidptr
	get_class_category_func        voidptr
	property_can_revert_func       voidptr
	property_get_revert_func       voidptr
	get_owner_func                 voidptr
	get_property_state_func        voidptr
	get_method_list_func           voidptr
	free_method_list_func          voidptr
	get_property_type_func         voidptr
	validate_property_func         voidptr
	has_method_func                voidptr
	get_method_argument_count_func voidptr
	call_func                      voidptr
	notification_func              voidptr
	to_string_func                 voidptr
	refcount_incremented_func      voidptr
	refcount_decremented_func      voidptr
	get_script_func                voidptr
	is_placeholder_func            voidptr
	set_fallback_func              voidptr
	get_fallback_func              voidptr
	get_language_func              voidptr
	free_func                      voidptr
}

struct ScriptInstance {
mut:
	node     voidptr
	resource voidptr
	source   GdString
	path     GdString
	id       string
	state    voidptr
	noted    string
}

type StateFactory = fn () voidptr

type PropFn = fn (string) bool

__global script_info InstanceInfo

type ScriptCreate = fn (voidptr, voidptr) voidptr

fn prepare_instance_info() {
	script_info.set_func = voidptr(instance_set)
	script_info.get_func = voidptr(instance_get)
	script_info.get_property_list_func = voidptr(instance_property_list)
	script_info.free_property_list_func = voidptr(instance_free_property_list)
	script_info.property_can_revert_func = voidptr(instance_can_revert)
	script_info.property_get_revert_func = voidptr(instance_get_revert)
	script_info.has_method_func = voidptr(instance_has_method)
	script_info.get_method_argument_count_func = voidptr(instance_arg_count)
	script_info.call_func = voidptr(instance_call)
	script_info.notification_func = voidptr(instance_notify)
	script_info.get_owner_func = voidptr(instance_owner)
	script_info.get_script_func = voidptr(instance_script)
	script_info.get_language_func = voidptr(instance_language)
	script_info.is_placeholder_func = voidptr(instance_placeholder)
	script_info.refcount_decremented_func = voidptr(instance_can_die)
	script_info.free_func = voidptr(instance_free)
}

fn script_can_run(instance voidptr) bool {
	if script_state(instance).source.text().len == 0 {
		return false
	}
	if api.engine == unsafe { nil } || api.editor_hint == unsafe { nil } {
		return false
	}
	mut hint := u8(0)
	call_none(api.editor_hint, api.engine, voidptr(&hint))
	return hint == 0
}

fn script_has_method(instance voidptr, name string) bool {
	state := script_state(instance)
	return registry.has_method(state.path.text(), name)
}

fn make_live(state &ScriptResource, owner voidptr) voidptr {
	mut box := unsafe { &ScriptInstance(alloc(uint(sizeof(ScriptInstance)))) }
	box.node = owner
	box.resource = state.object
	box.source.set_text(state.source.text())
	box.path.set_text(state.path.text())
	box.id = script_id_of_path(state.path.text())
	hook := registry.hook(box.id)
	if hook.factory != unsafe { nil } {
		make := unsafe { StateFactory(hook.factory) }
		box.state = make()
	}
	ensure_project_scripts()
	create := unsafe { ScriptCreate(api.script_instance) }
	instance := create(voidptr(&script_info), voidptr(box))
	enable_loops(owner, box.id)
	return instance
}

fn enable_loops(owner voidptr, key string) {
	if gdf == unsafe { nil } || owner == unsafe { nil } {
		return
	}
	node := Node{
		ptr: owner
	}
	if registry.has_method(key, '_process') || registry.has_method(key, 'process') {
		node.set_process(true)
	}
	if registry.has_method(key, '_physics_process') || registry.has_method(key, 'physics_process') {
		node.set_physics_process(true)
	}
	if registry.has_method(key, '_input') || registry.has_method(key, 'input') {
		node.set_process_input(true)
	}
	if registry.has_method(key, '_unhandled_input')
		|| registry.has_method(key, 'unhandled_input') {
		node.set_process_unhandled_input(true)
	}
}

fn script_instance_of(data voidptr) &ScriptInstance {
	if data == unsafe { nil } {
		return unsafe { nil }
	}
	return unsafe { &ScriptInstance(data) }
}

fn (s &ScriptInstance) has_method(method voidptr) bool {
	return registry.has_method(s.path.text(), read_name(method))
}

fn (mut s ScriptInstance) call(method voidptr, args voidptr, count i64, ret voidptr, err voidptr) {
	s.call_name(read_name(method), args, count, ret, err)
}

fn (mut s ScriptInstance) call_name(name string, args voidptr, count i64, ret voidptr, err voidptr) {
	if ret != unsafe { nil } {
		zero(ret, 24)
	}
	if err != unsafe { nil } {
		zero(err, 12)
	}
	plain := if name.starts_with('_') { name[1..] } else { name }
	if plain != '' && s.noted == plain {
		s.noted = ''
		return
	}
	if run_script_call(voidptr(s), name, args, count, ret) == false {
		mark_bad(err)
	}
}

fn (mut s ScriptInstance) notify(what int) {
	if what == 13 {
		run_script_enter(voidptr(s))
	}
	name := notification_name(what)
	if name == '' {
		return
	}
	if name == 'process' || name == 'physics_process' {
		bound_values = [
			CallValue{
				kind: kind_f64
				f:    delta_of(s.node)
			},
		]
	} else {
		bound_values = []CallValue{}
	}
	if run_script_call(voidptr(s), name, unsafe { nil }, 0, unsafe { nil }) {
		s.noted = name
	}
}

fn (s &ScriptInstance) owner() voidptr {
	return s.node
}

fn (s &ScriptInstance) script() voidptr {
	return s.resource
}

fn (s &ScriptInstance) language() voidptr {
	return api.language
}

fn (s &ScriptInstance) placeholder() u8 {
	return 0
}

fn (s &ScriptInstance) can_die() u8 {
	return 1
}

fn (mut s ScriptInstance) free() {
	s.source.clear()
	s.path.clear()
	heap_free(s.state)
	s.state = unsafe { nil }
	free_mem(voidptr(s))
}

fn mark_bad(err voidptr) {
	if err == unsafe { nil } {
		return
	}
	unsafe {
		*&int(err) = 1
	}
}

fn instance_has_method(data voidptr, method voidptr) bool {
	box := script_instance_of(data)
	if box == unsafe { nil } {
		return false
	}
	return box.has_method(method)
}

fn instance_call(data voidptr, method voidptr, args voidptr, count i64, ret voidptr, err voidptr) {
	mut box := script_instance_of(data)
	if box == unsafe { nil } {
		mark_bad(err)
		return
	}
	box.call(method, args, count, ret, err)
}

fn instance_notify(data voidptr, what int, _reversed u8) {
	mut box := script_instance_of(data)
	if box == unsafe { nil } {
		return
	}
	box.notify(what)
}

fn with_hook(data voidptr, name voidptr, value voidptr, which string) bool {
	mut box := script_instance_of(data)
	if box == unsafe { nil } {
		return false
	}
	hook := registry.hook(box.script_key())
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
	previous_owner := bound_owner
	previous_state := bound_state
	previous_type := bound_state_type
	previous_force := bound_force
	previous_values := bound_values.clone()
	previous_ret := bound_ret
	previous_key := bound_key
	bound_owner = box.node
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
	bound_owner = previous_owner
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
	if slot := registry.get(box.script_key()) {
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
	slot := registry.get(box.script_key()) or { return unsafe { nil } }
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

fn instance_owner(data voidptr) voidptr {
	box := script_instance_of(data)
	if box == unsafe { nil } {
		return unsafe { nil }
	}
	return box.owner()
}

fn instance_script(data voidptr) voidptr {
	box := script_instance_of(data)
	if box == unsafe { nil } {
		return unsafe { nil }
	}
	return box.script()
}

fn instance_language(_data voidptr) voidptr {
	return api.language
}

fn instance_placeholder(_data voidptr) u8 {
	return 0
}

fn instance_can_die(_data voidptr) u8 {
	return 1
}

fn instance_free(data voidptr) {
	mut box := script_instance_of(data)
	if box == unsafe { nil } {
		return
	}
	box.free()
}

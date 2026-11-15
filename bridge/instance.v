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
	if gdf == unsafe { nil } || godot_host.api.engine == unsafe { nil } {
		return false
	}
	editor := Engine{
		ptr: godot_host.api.engine
	}.is_editor_hint()
	if editor == false {
		return true
	}
	return script_facts(instance).tool
}

fn script_has_method(instance voidptr, name string) bool {
	state := script_state(instance)
	return godot_host.registry.has_method(state.path.text(), name)
}

fn make_live(state &ScriptResource, owner voidptr) voidptr {
	mut box := unsafe { &ScriptInstance(alloc(uint(sizeof(ScriptInstance)))) }
	box.node = owner
	box.resource = state.object
	box.source.set_text(state.source.text())
	box.path.set_text(state.path.text())
	box.id = script_id_of_path(state.path.text())
	hook := godot_host.registry.hook(box.id)
	if hook.factory != unsafe { nil } {
		make := unsafe { StateFactory(hook.factory) }
		box.state = make()
	}
	ensure_project_scripts()
	godot_host.instances << voidptr(box)
	create := unsafe { ScriptCreate(godot_host.api.script_instance) }
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
	if godot_host.registry.has_method(key, '_process') || godot_host.registry.has_method(key, 'process') {
		node.set_process(true)
	}
	if godot_host.registry.has_method(key, '_physics_process') || godot_host.registry.has_method(key, 'physics_process') {
		node.set_physics_process(true)
	}
	if godot_host.registry.has_method(key, '_input') || godot_host.registry.has_method(key, 'input') {
		node.set_process_input(true)
	}
	if godot_host.registry.has_method(key, '_unhandled_input')
		|| godot_host.registry.has_method(key, 'unhandled_input') {
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
	return godot_host.registry.has_method(s.path.text(), read_name(method))
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

fn connect_script_links(s &ScriptInstance) {
	if gdf == unsafe { nil } || s.node == unsafe { nil } {
		return
	}
	slot := godot_host.registry.get(s.script_key()) or { return }
	owner := Object{
		ptr: s.node
	}
	node := Node{
		ptr: s.node
	}
	for link in slot.links {
		if link.signal == '' || link.method == '' {
			continue
		}
		mut target := owner
		if link.node != '' && link.node != '.' && link.node != 'self' {
			path := NodePath.new(link.node)
			found := node.get_node_or_null(path)
			path.deinit()
			if found.ptr == unsafe { nil } {
				continue
			}
			target = Object{
				ptr: found.ptr
			}
		}
		cb := Callable.new2(owner, link.method)
		if target.is_connected(link.signal, cb) == false {
			target.connect(link.signal, cb, Object_connect_Cfg{})
		}
		cb.deinit()
	}
}

fn (mut s ScriptInstance) notify(what int) {
	if what == 13 {
		connect_script_links(s)
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
	return godot_host.api.language
}

fn (s &ScriptInstance) placeholder() u8 {
	return 0
}

fn (s &ScriptInstance) can_die() u8 {
	return 1
}

fn (mut s ScriptInstance) free() {
	forget_instance(voidptr(&s))
	s.source.clear()
	s.path.clear()
	heap_free(s.state)
	s.state = unsafe { nil }
	free_mem(voidptr(s))
}

fn forget_instance(data voidptr) {
	mut left := []voidptr{}
	for item in godot_host.instances {
		if item != data {
			left << item
		}
	}
	godot_host.instances = left
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

fn delta_of(object voidptr) f64 {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return 0
	}
	return Node{
		ptr: object
	}.get_process_delta_time()
}

fn instance_notify(data voidptr, what int, _reversed u8) {
	mut box := script_instance_of(data)
	if box == unsafe { nil } {
		return
	}
	box.notify(what)
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
	return godot_host.api.language
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

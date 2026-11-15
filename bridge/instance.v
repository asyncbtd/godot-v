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
}

__global script_info InstanceInfo

type ScriptCreate = fn (voidptr, voidptr) voidptr

fn prepare_instance_info() {
	script_info.has_method_func = voidptr(instance_has_method)
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
	ensure_project_scripts()
	create := unsafe { ScriptCreate(api.script_instance) }
	instance := create(voidptr(&script_info), voidptr(box))
	if registry.has_method(state.path.text(), '_process') {
		set_process_enabled(owner)
	}
	return instance
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

fn (s &ScriptInstance) call(method voidptr, ret voidptr, err voidptr) {
	if ret != unsafe { nil } {
		zero(ret, 24)
	}
	if err != unsafe { nil } {
		zero(err, 12)
	}
	if run_script_method(voidptr(s), read_name(method)) == false {
		mark_bad(err)
	}
}

fn (s &ScriptInstance) notify(what int) {
	if what != 13 {
		return
	}
	run_script_enter(voidptr(s))
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

fn instance_call(data voidptr, method voidptr, _args voidptr, _count i64, ret voidptr, err voidptr) {
	box := script_instance_of(data)
	if box == unsafe { nil } {
		mark_bad(err)
		return
	}
	box.call(method, ret, err)
}

fn instance_notify(data voidptr, what int, _reversed u8) {
	box := script_instance_of(data)
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

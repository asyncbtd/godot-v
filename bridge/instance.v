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

struct Live {
mut:
	owner  voidptr
	script voidptr
	source GdString
	path   GdString
}

__global script_info InstanceInfo

type ScriptCreate = fn (voidptr, voidptr) voidptr

fn prepare_instance_info() {
	script_info.has_method_func = voidptr(live_has_method)
	script_info.call_func = voidptr(live_call)
	script_info.notification_func = voidptr(live_notify)
	script_info.get_owner_func = voidptr(live_owner)
	script_info.get_script_func = voidptr(live_script)
	script_info.get_language_func = voidptr(live_language)
	script_info.is_placeholder_func = voidptr(live_placeholder)
	script_info.refcount_decremented_func = voidptr(live_can_die)
	script_info.free_func = voidptr(live_free)
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
	return answers(state.path.text(), state.source.text(), name)
}

fn make_live(state &ScriptState, owner voidptr) voidptr {
	mut box := unsafe { &Live(alloc(uint(sizeof(Live)))) }
	box.owner = owner
	box.script = state.object
	box.source.set_text(state.source.text())
	box.path.set_text(state.path.text())
	ensure_project_scripts()
	create := unsafe { ScriptCreate(api.script_instance) }
	instance := create(voidptr(&script_info), voidptr(box))
	if answers(state.path.text(), state.source.text(), '_process') {
		set_process_enabled(owner)
	}
	return instance
}

fn live_box(data voidptr) &Live {
	if data == unsafe { nil } {
		return unsafe { nil }
	}
	return unsafe { &Live(data) }
}

fn live_has_method(data voidptr, method voidptr) bool {
	box := live_box(data)
	if box == unsafe { nil } {
		return false
	}
	return answers(box.path.text(), box.source.text(), read_name(method))
}

fn live_call(data voidptr, method voidptr, _args voidptr, _count i64, ret voidptr, err voidptr) {
	if ret != unsafe { nil } {
		zero(ret, 24)
	}
	if err != unsafe { nil } {
		zero(err, 12)
	}
	if run_script_method(data, read_name(method)) == false {
		mark_bad(err)
	}
}

fn mark_bad(err voidptr) {
	if err == unsafe { nil } {
		return
	}
	unsafe {
		*&int(err) = 1
	}
}

fn live_notify(data voidptr, what int, _reversed u8) {
	if what != 13 {
		return
	}
	run_script_enter(data)
}

fn live_owner(data voidptr) voidptr {
	if data == unsafe { nil } {
		return unsafe { nil }
	}
	return unsafe { &Live(data) }.owner
}

fn live_script(data voidptr) voidptr {
	if data == unsafe { nil } {
		return unsafe { nil }
	}
	return unsafe { &Live(data) }.script
}

fn live_language(_data voidptr) voidptr {
	return api.language
}

fn live_placeholder(_data voidptr) u8 {
	return 0
}

fn live_can_die(_data voidptr) u8 {
	return 1
}

fn live_free(data voidptr) {
	mut box := live_box(data)
	if box == unsafe { nil } {
		return
	}
	box.source.clear()
	box.path.clear()
	release(data)
}

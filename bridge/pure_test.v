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

fn ignore_frame(_delta f64) {}

fn guest_enter() {}

fn guest_signal(name string) bool {
	return name == 'hop'
}

struct Scratch {
mut:
	a u8
	b u8
	c u8
}

fn test_memory_and_scalar_writes() {
	mut buf := Scratch{
		a: 9
		b: 9
		c: 9
	}
	zero(voidptr(&buf), 0)
	assert buf.a == 9
	zero(voidptr(&buf), 2)
	assert buf.a == 0
	assert buf.b == 0
	assert buf.c == 9
	mut flag := u8(0)
	write_bool(voidptr(&flag), true)
	assert flag == 1
	write_bool(voidptr(&flag), false)
	assert flag == 0
	mut number := i64(5)
	write_number(voidptr(&number), -3)
	assert number == -3
	mut ptr := voidptr(1)
	marker := 1
	write_pointer(voidptr(&ptr), voidptr(&marker))
	assert ptr == voidptr(&marker)
	write_pointer(voidptr(&ptr), unsafe { nil })
	assert ptr == unsafe { nil }
	for kind in [ret_none, ret_bool, ret_number, ret_pointer, ret_string, ret_string_name,
		ret_dictionary, ret_array, ret_packed_string, ret_variant, 99] {
		write_stub(unsafe { nil }, kind)
	}
}

fn test_empty_strings_and_argument_slots() {
	mut text := GdString{}
	assert text.text() == ''
	text.set_text('')
	text.clear()
	destroy_string_name(&text)
	mut filled := GdString{
		data: voidptr(1)
	}
	destroy_string_name(&filled)
	assert filled.data == voidptr(1)
	mut raw := [8]u8{}
	unsafe {
		for i in 0 .. raw.len {
			raw[i] = 9
		}
		text.copy_to(voidptr(&raw[0]))
		assert raw.all(it == 0)
		for i in 0 .. raw.len {
			raw[i] = 9
		}
		write_string(voidptr(&raw[0]), '')
		assert raw.all(it == 0)
		for i in 0 .. raw.len {
			raw[i] = 9
		}
		write_string_name(voidptr(&raw[0]), '')
		assert raw.all(it == 0)
		assert read_name(voidptr(&raw[0])) == ''
	}
	assert read_name(unsafe { nil }) == ''
	mut flag := u8(1)
	mut held := voidptr(3)
	slots := [voidptr(&flag), voidptr(&held)]
	assert arg(voidptr(&slots[0]), 0) == voidptr(&flag)
	assert arg(voidptr(&slots[0]), 1) == voidptr(&held)
	assert arg_bool(voidptr(&slots[0]), 0)
	flag = 0
	assert arg_bool(voidptr(&slots[0]), 0) == false
	assert arg_object(voidptr(&slots[0]), 1) == voidptr(3)
}

fn test_kind_pointers_and_method_lookup() {
	for kind in [kind_language, kind_script, kind_loader, kind_saver, -1, 40] {
		assert pointer_kind(kind_pointer(kind)) == kind
	}
	assert pointer_kind(unsafe { nil }) == -1
	mut def := MethodDef{
		action: 3
		ret:    1
	}
	list := [
		MethodSlot{
			key:    9
			method: &def
		},
	]
	assert find_method(list, 9) == voidptr(&def)
	assert find_method(list, 1) == unsafe { nil }
	assert find_method([]MethodSlot{}, 9) == unsafe { nil }
	free_instance(kind_pointer(kind_script), unsafe { nil })
}

fn test_remembered_scripts_round_trip() {
	saved := script_resources.clone()
	defer {
		script_resources = saved.clone()
	}
	mut marker := 1
	assert script_is_remembered(voidptr(&marker)) == false
	script_resources << voidptr(&marker)
	assert script_is_remembered(voidptr(&marker))
	assert script_is_remembered(unsafe { nil }) == false
}

fn test_binding_callbacks_ignore_empty_inputs() {
	binding_free(unsafe { nil }, unsafe { nil }, unsafe { nil })
	foreign := ScriptResource{
		kind:  kind_language
		owned: 1
	}
	binding_free(unsafe { nil }, unsafe { nil }, voidptr(&foreign))
	unowned := ScriptResource{
		kind:  kind_script
		owned: 0
	}
	binding_free(unsafe { nil }, unsafe { nil }, voidptr(&unowned))
	assert binding_reference(unsafe { nil }, unsafe { nil }, 0) == 1
	assert binding_of(unsafe { nil }) == unsafe { nil }
	object := 1
	assert binding_of(voidptr(&object)) == unsafe { nil }
	prepare_binding()
	assert binding.create_callback == voidptr(binding_create)
	assert binding.free_callback == voidptr(binding_free)
	assert binding.reference_callback == voidptr(binding_reference)
}

fn test_instance_info_points_at_callbacks() {
	prepare_instance_info()
	assert script_info.has_method_func == voidptr(instance_has_method)
	assert script_info.call_func == voidptr(instance_call)
	assert script_info.notification_func == voidptr(instance_notify)
	assert script_info.get_owner_func == voidptr(instance_owner)
	assert script_info.get_script_func == voidptr(instance_script)
	assert script_info.get_language_func == voidptr(instance_language)
	assert script_info.is_placeholder_func == voidptr(instance_placeholder)
	assert script_info.refcount_decremented_func == voidptr(instance_can_die)
	assert script_info.free_func == voidptr(instance_free)
}

fn test_guest_registration_stores_hooks() {
	register_main(guest_enter, guest_signal)
	main_hook := registry.hook('res://main.v')
	assert main_hook.enter == voidptr(guest_enter)
	assert main_hook.frame == unsafe { nil }
	assert call_signal(main_hook.signal, 'hop')
	register_player(guest_enter, ignore_frame, guest_signal)
	player_hook := registry.hook('player')
	assert player_hook.enter == voidptr(guest_enter)
	assert player_hook.frame == voidptr(ignore_frame)
	assert call_signal(player_hook.signal, 'idle') == false
	register_mob(guest_enter)
	mob_hook := registry.hook('mob.v')
	assert mob_hook.enter == voidptr(guest_enter)
	assert mob_hook.frame == unsafe { nil }
	assert mob_hook.signal == unsafe { nil }
}

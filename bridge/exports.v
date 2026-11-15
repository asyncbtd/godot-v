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

@[export: 'godot_v_report']
fn godot_v_report(ptr &u8, len int) {
	report(text_from_ptr(ptr, len))
}

@[export: 'godot_v_register_main']
fn godot_v_register_main(enter voidptr, signal voidptr) {
	registry.add_script('main', enter, unsafe { nil }, signal)
}

@[export: 'godot_v_register_player']
fn godot_v_register_player(enter voidptr, frame voidptr, signal voidptr) {
	registry.add_script('player', enter, frame, signal)
}

@[export: 'godot_v_register_mob']
fn godot_v_register_mob(enter voidptr) {
	registry.add_script('mob', enter, unsafe { nil }, unsafe { nil })
}

@[export: 'godot_v_live']
fn godot_v_live() voidptr {
	return unsafe { &host_session }
}

@[export: 'godot_v_owner']
fn godot_v_owner() voidptr {
	return bound_owner
}

@[export: 'godot_v_call_group']
fn godot_v_call_group(object voidptr, group &u8, group_len int, method &u8, method_len int) {
	call_group(object, text_from_ptr(group, group_len), text_from_ptr(method, method_len))
}

@[export: 'godot_v_call_method']
fn godot_v_call_method(object voidptr, method &u8, len int) {
	call_void(object, text_from_ptr(method, len))
}

@[export: 'godot_v_node_at']
fn godot_v_node_at(object voidptr, path &u8, len int) voidptr {
	return node_at(object, text_from_ptr(path, len))
}

@[export: 'godot_v_timer_start']
fn godot_v_timer_start(object voidptr) {
	call_void(object, 'start')
}

@[export: 'godot_v_timer_stop']
fn godot_v_timer_stop(object voidptr) {
	call_void(object, 'stop')
}

@[export: 'godot_v_hide_node']
fn godot_v_hide_node(object voidptr) {
	call_void(object, 'hide')
}

@[export: 'godot_v_show_node']
fn godot_v_show_node(object voidptr) {
	call_void(object, 'show')
}

@[export: 'godot_v_audio_play']
fn godot_v_audio_play(object voidptr) {
	call_void(object, 'play')
}

@[export: 'godot_v_audio_stop']
fn godot_v_audio_stop(object voidptr) {
	call_void(object, 'stop')
}

@[export: 'godot_v_load_resource']
fn godot_v_load_resource(path &u8, len int) voidptr {
	return load_resource(text_from_ptr(path, len))
}

@[export: 'godot_v_feature']
fn godot_v_feature(name &u8, len int) u8 {
	return bool_to_u8(feature(text_from_ptr(name, len)))
}

@[export: 'godot_v_set_text_prop']
fn godot_v_set_text_prop(object voidptr, prop &u8, prop_len int, value &u8, value_len int) {
	set_text_prop(object, text_from_ptr(prop, prop_len), text_from_ptr(value, value_len))
}

@[export: 'godot_v_set_flag_prop']
fn godot_v_set_flag_prop(object voidptr, prop &u8, prop_len int, value u8) {
	set_bool_prop(object, text_from_ptr(prop, prop_len), value != 0)
}

@[export: 'godot_v_instance_scene']
fn godot_v_instance_scene(scene voidptr) voidptr {
	return call_object(scene, 'instantiate')
}

@[export: 'godot_v_set_progress_ratio']
fn godot_v_set_progress_ratio(object voidptr, ratio f64) {
	set_float_prop(object, 'progress_ratio', ratio)
}

@[export: 'godot_v_position_of']
fn godot_v_position_of(object voidptr, x &f32, y &f32) {
	px, py := get_vector(object, 'position')
	unsafe {
		*x = px
		*y = py
	}
}

@[export: 'godot_v_rotation_of']
fn godot_v_rotation_of(object voidptr) f64 {
	return get_float(object, 'rotation')
}

@[export: 'godot_v_move_to']
fn godot_v_move_to(object voidptr, x f32, y f32) {
	move_to(object, x, y)
}

@[export: 'godot_v_set_rotation']
fn godot_v_set_rotation(object voidptr, angle f64) {
	set_float_prop(object, 'rotation', angle)
}

@[export: 'godot_v_push_velocity']
fn godot_v_push_velocity(object voidptr, x f32, y f32) {
	push_velocity(object, x, y)
}

@[export: 'godot_v_add_child']
fn godot_v_add_child(parent voidptr, child voidptr) {
	add_child(parent, child)
}

@[export: 'godot_v_play_anim']
fn godot_v_play_anim(object voidptr, name &u8, len int) {
	play_anim(object, text_from_ptr(name, len))
}

@[export: 'godot_v_stop_anim']
fn godot_v_stop_anim(object voidptr) {
	call_void(object, 'stop')
}

@[export: 'godot_v_viewport_size']
fn godot_v_viewport_size(object voidptr, x &f32, y &f32) {
	w, h := viewport_size(object)
	unsafe {
		*x = w
		*y = h
	}
}

@[export: 'godot_v_set_disabled']
fn godot_v_set_disabled(object voidptr, disabled u8) {
	set_bool_prop(object, 'disabled', disabled != 0)
}

@[export: 'godot_v_parent_of']
fn godot_v_parent_of(object voidptr) voidptr {
	return call_object(object, 'get_parent')
}

@[export: 'godot_v_set_deferred_flag']
fn godot_v_set_deferred_flag(object voidptr, prop &u8, len int, value u8) {
	set_deferred_bool(object, text_from_ptr(prop, len), value != 0)
}

@[export: 'godot_v_action_down']
fn godot_v_action_down(name &u8, len int) u8 {
	return bool_to_u8(action_down(text_from_ptr(name, len)))
}

@[export: 'godot_v_delta_of']
fn godot_v_delta_of(object voidptr) f64 {
	return delta_of(object)
}

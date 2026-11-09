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

#include "@VMODROOT/src/script_guest.h"

fn C.godot_v_report(ptr &u8, len int)
fn C.godot_v_register_main(enter voidptr, handler voidptr)
fn C.godot_v_register_player(enter voidptr, frame voidptr, handler voidptr)
fn C.godot_v_register_mob(enter voidptr)
fn C.godot_v_live() voidptr
fn C.godot_v_owner() voidptr
fn C.godot_v_call_group(object voidptr, group &u8, group_len int, method &u8, method_len int)
fn C.godot_v_call_method(object voidptr, method &u8, len int)
fn C.godot_v_node_at(object voidptr, path &u8, len int) voidptr
fn C.godot_v_timer_start(object voidptr)
fn C.godot_v_timer_stop(object voidptr)
fn C.godot_v_hide_node(object voidptr)
fn C.godot_v_show_node(object voidptr)
fn C.godot_v_audio_play(object voidptr)
fn C.godot_v_audio_stop(object voidptr)
fn C.godot_v_load_resource(path &u8, len int) voidptr
fn C.godot_v_feature(name &u8, len int) u8
fn C.godot_v_set_text_prop(object voidptr, prop &u8, prop_len int, value &u8, value_len int)
fn C.godot_v_set_flag_prop(object voidptr, prop &u8, prop_len int, value u8)
fn C.godot_v_instance_scene(scene voidptr) voidptr
fn C.godot_v_set_progress_ratio(object voidptr, ratio f64)
fn C.godot_v_position_of(object voidptr, x &f32, y &f32)
fn C.godot_v_rotation_of(object voidptr) f64
fn C.godot_v_move_to(object voidptr, x f32, y f32)
fn C.godot_v_set_rotation(object voidptr, angle f64)
fn C.godot_v_push_velocity(object voidptr, x f32, y f32)
fn C.godot_v_add_child(parent voidptr, child voidptr)
fn C.godot_v_play_anim(object voidptr, name &u8, len int)
fn C.godot_v_stop_anim(object voidptr)
fn C.godot_v_viewport_size(object voidptr, x &f32, y &f32)
fn C.godot_v_set_disabled(object voidptr, disabled u8)
fn C.godot_v_parent_of(object voidptr) voidptr
fn C.godot_v_set_deferred_flag(object voidptr, prop &u8, len int, value u8)
fn C.godot_v_action_down(name &u8, len int) u8
fn C.godot_v_delta_of(object voidptr) f64

pub struct Session {
pub mut:
	score     int
	phase     int
	mob_scene voidptr
	screen_w  f32
	screen_h  f32
}

__global active_session = unsafe { &Session(nil) }

fn init() {
	active_session = unsafe { &Session(C.godot_v_live()) }
}

fn flag_of(value bool) u8 {
	if value {
		return 1
	}
	return 0
}

// report writes a message to Godot's error output.
pub fn report(message string) {
	C.godot_v_report(message.str, message.len)
}

// register_main stores the callbacks for a main script.
pub fn register_main(enter fn (), signal fn (string) bool) {
	C.godot_v_register_main(voidptr(enter), voidptr(signal))
}

// register_player stores the callbacks for a player script.
pub fn register_player(enter fn (), frame fn (f64), signal fn (string) bool) {
	C.godot_v_register_player(voidptr(enter), voidptr(frame), voidptr(signal))
}

// register_mob stores the callback for a mob script.
pub fn register_mob(enter fn ()) {
	C.godot_v_register_mob(voidptr(enter))
}

// live returns the session shared by the running scripts.
pub fn live() &Session {
	return active_session
}

// owner returns the node whose script is currently running.
pub fn owner() voidptr {
	return C.godot_v_owner()
}

// call_group calls method on every node in group.
pub fn call_group(object voidptr, group string, method string) {
	C.godot_v_call_group(object, group.str, group.len, method.str, method.len)
}

// call_method calls method on object with no arguments.
pub fn call_method(object voidptr, method string) {
	C.godot_v_call_method(object, method.str, method.len)
}

// node_at returns the node at path, or nil when it is missing.
pub fn node_at(object voidptr, path string) voidptr {
	return C.godot_v_node_at(object, path.str, path.len)
}

// timer_start starts a timer node.
pub fn timer_start(object voidptr) {
	C.godot_v_timer_start(object)
}

// timer_stop stops a timer node.
pub fn timer_stop(object voidptr) {
	C.godot_v_timer_stop(object)
}

// hide_node hides a canvas item.
pub fn hide_node(object voidptr) {
	C.godot_v_hide_node(object)
}

// show_node shows a canvas item.
pub fn show_node(object voidptr) {
	C.godot_v_show_node(object)
}

// audio_play starts an audio player.
pub fn audio_play(object voidptr) {
	C.godot_v_audio_play(object)
}

// audio_stop stops an audio player.
pub fn audio_stop(object voidptr) {
	C.godot_v_audio_stop(object)
}

// load_resource loads the resource at path.
pub fn load_resource(path string) voidptr {
	return C.godot_v_load_resource(path.str, path.len)
}

// feature reports whether Godot was started with the named feature.
pub fn feature(name string) bool {
	return C.godot_v_feature(name.str, name.len) != 0
}

// set_text_prop sets a string property on object.
pub fn set_text_prop(object voidptr, prop string, value string) {
	C.godot_v_set_text_prop(object, prop.str, prop.len, value.str, value.len)
}

// set_flag_prop sets a bool property on object.
pub fn set_flag_prop(object voidptr, prop string, value bool) {
	C.godot_v_set_flag_prop(object, prop.str, prop.len, flag_of(value))
}

// instance_scene instantiates a packed scene.
pub fn instance_scene(scene voidptr) voidptr {
	return C.godot_v_instance_scene(scene)
}

// set_progress_ratio sets progress_ratio on a path follow.
pub fn set_progress_ratio(object voidptr, ratio f64) {
	C.godot_v_set_progress_ratio(object, ratio)
}

// position_of reads the position of a node.
pub fn position_of(object voidptr) (f32, f32) {
	mut x := f32(0)
	mut y := f32(0)
	C.godot_v_position_of(object, &x, &y)
	return x, y
}

// rotation_of reads the rotation of a node.
pub fn rotation_of(object voidptr) f64 {
	return C.godot_v_rotation_of(object)
}

// move_to sets the position of a node.
pub fn move_to(object voidptr, x f32, y f32) {
	C.godot_v_move_to(object, x, y)
}

// set_rotation sets the rotation of a node.
pub fn set_rotation(object voidptr, angle f64) {
	C.godot_v_set_rotation(object, angle)
}

// push_velocity sets the linear velocity of a rigid body.
pub fn push_velocity(object voidptr, x f32, y f32) {
	C.godot_v_push_velocity(object, x, y)
}

// add_child adds child to parent.
pub fn add_child(parent voidptr, child voidptr) {
	C.godot_v_add_child(parent, child)
}

// play_anim plays an animation, or the current one when name is empty.
pub fn play_anim(object voidptr, name string) {
	C.godot_v_play_anim(object, name.str, name.len)
}

// stop_anim stops an animated sprite.
pub fn stop_anim(object voidptr) {
	C.godot_v_stop_anim(object)
}

// viewport_size reads the visible size of the node's viewport.
pub fn viewport_size(object voidptr) (f32, f32) {
	mut x := f32(0)
	mut y := f32(0)
	C.godot_v_viewport_size(object, &x, &y)
	return x, y
}

// set_disabled sets the disabled property of a collision shape.
pub fn set_disabled(object voidptr, disabled bool) {
	C.godot_v_set_disabled(object, flag_of(disabled))
}

// parent_of returns the parent of a node.
pub fn parent_of(object voidptr) voidptr {
	return C.godot_v_parent_of(object)
}

// set_deferred_flag sets a bool property at the end of the frame.
pub fn set_deferred_flag(object voidptr, prop string, value bool) {
	C.godot_v_set_deferred_flag(object, prop.str, prop.len, flag_of(value))
}

// action_down reports whether an input action is pressed.
pub fn action_down(name string) bool {
	return C.godot_v_action_down(name.str, name.len) != 0
}

// delta_of reads the process delta of a node.
pub fn delta_of(object voidptr) f64 {
	return C.godot_v_delta_of(object)
}

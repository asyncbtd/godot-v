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

import crypto.sha256
import os

#include "@VMODROOT/src/script_guest.h"

fn C.dlopen(filename &u8, flags int) voidptr

fn C.dlsym(handle voidptr, name &u8) voidptr

fn C.dlerror() &u8

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

type VariantCall = fn (voidptr, voidptr, voidptr, i64, voidptr, voidptr)

type SignalFn = fn (string) bool

type EnterFn = fn ()

struct Vec2 {
	x f32
	y f32
}

struct Rect {
	x f32
	y f32
	w f32
	h f32
}

struct ScriptHook {
mut:
	key    string
	enter  voidptr
	frame  voidptr
	signal voidptr
}

struct CachedName {
	key  string
	name GdString
}

pub struct Session {
pub mut:
	score     int
	phase     int
	mob_scene voidptr
	screen_w  f32
	screen_h  f32
}

__global script_hooks = []ScriptHook{}
__global name_cache = []CachedName{}
__global bound_owner = unsafe { nil }
__global session Session
__global active_session = unsafe { &Session(nil) }
__global script_library = unsafe { nil }
__global loaded_stamp = i64(0)
__global loaded_hash = ''
__global script_resources = []voidptr{}

fn init() {
	$if script_guest ? {
		active_session = unsafe { &Session(C.godot_v_live()) }
	} $else {
		active_session = unsafe { &session }
	}
}

fn text_of(ptr &u8, len int) string {
	if ptr == unsafe { nil } || len <= 0 {
		return ''
	}
	return unsafe { tos(ptr, len) }
}

fn flag_of(value bool) u8 {
	if value {
		return 1
	}
	return 0
}

fn source_has_method(source string, name string) bool {
	if name == '' || source == '' {
		return false
	}
	if source.contains("name == '${name}'") {
		return true
	}
	if source.contains('name == "${name}"') {
		return true
	}
	return source.contains(') ${name}(')
}

fn script_key(path string) string {
	name := path.all_after_last('/')
	if name.ends_with('.v') {
		return name[..name.len - 2]
	}
	return name
}

fn bind_script(key string, enter voidptr, frame voidptr, signal voidptr) {
	for i, slot in script_hooks {
		if slot.key == key {
			script_hooks[i].enter = enter
			script_hooks[i].frame = frame
			script_hooks[i].signal = signal
			return
		}
	}
	script_hooks << ScriptHook{
		key:    key
		enter:  enter
		frame:  frame
		signal: signal
	}
}

fn hook_for(path string) ScriptHook {
	key := script_key(path)
	for slot in script_hooks {
		if slot.key == key {
			return slot
		}
	}
	return ScriptHook{}
}

fn call_signal(signal voidptr, name string) bool {
	if signal == unsafe { nil } {
		return false
	}
	f := unsafe { SignalFn(signal) }
	return f(name)
}

fn run_script_method(data voidptr, name string) bool {
	if data == unsafe { nil } || name == '' {
		return false
	}
	ensure_project_scripts()
	box := unsafe { &Live(data) }
	if box.script == unsafe { nil } {
		return false
	}
	state := script_state(binding_of(box.script))
	if state == unsafe { nil } {
		return false
	}
	if source_has_method(state.source.text(), name) == false {
		return false
	}
	previous := bound_owner
	bound_owner = box.owner
	hook := hook_for(state.path.text())
	mut ok := call_signal(hook.signal, name)
	if ok == false {
		for slot in script_hooks {
			if slot.signal == hook.signal {
				continue
			}
			if call_signal(slot.signal, name) {
				ok = true
				break
			}
		}
	}
	bound_owner = previous
	return ok
}

fn run_script_enter(data voidptr) {
	if data == unsafe { nil } {
		return
	}
	box := unsafe { &Live(data) }
	if box.script == unsafe { nil } {
		return
	}
	state := script_state(binding_of(box.script))
	if state == unsafe { nil } {
		return
	}
	if source_has_method(state.source.text(), '_ready') {
		return
	}
	hook := hook_for(state.path.text())
	if hook.enter == unsafe { nil } {
		return
	}
	previous := bound_owner
	bound_owner = box.owner
	f := unsafe { EnterFn(hook.enter) }
	f()
	bound_owner = previous
}

fn cached_name(text string) GdString {
	for slot in name_cache {
		if slot.key == text {
			return slot.name
		}
	}
	name := string_name(text)
	name_cache << CachedName{
		key:  text
		name: name
	}
	return name
}

fn scratch() voidptr {
	return alloc(24)
}

fn scratch_err() voidptr {
	return alloc(12)
}

fn free_variant(ptr voidptr) {
	drop_variant(ptr)
	release(ptr)
}

fn drop_variant(ptr voidptr) {
	if ptr == unsafe { nil } || api.variant_destroy == unsafe { nil } {
		return
	}
	f := unsafe { VariantDestroy(api.variant_destroy) }
	f(ptr)
}

fn drop_builtin(typ int, ptr voidptr) {
	dtor := unsafe { TypeCtor(destructor_of(typ)) }
	dtor(ptr, unsafe { nil })
}

fn put_bool(dest voidptr, value bool) {
	flag := flag_of(value)
	from := unsafe { TypeCtor(from_type_of(type_bool)) }
	from(dest, voidptr(&flag))
}

fn put_float(dest voidptr, value f64) {
	from := unsafe { TypeCtor(from_type_of(type_float)) }
	from(dest, voidptr(&value))
}

fn put_vector(dest voidptr, x f32, y f32) {
	point := Vec2{
		x: x
		y: y
	}
	from := unsafe { TypeCtor(from_type_of(type_vector2)) }
	from(dest, voidptr(&point))
}

fn put_string(dest voidptr, text &GdString) {
	from := unsafe { TypeCtor(from_type_of(type_string)) }
	from(dest, voidptr(text))
}

fn put_name(dest voidptr, name &GdString) {
	from := unsafe { TypeCtor(from_type_of(type_string_name)) }
	from(dest, voidptr(name))
}

fn invoke(object voidptr, method string, args []voidptr, ret voidptr) bool {
	if object == unsafe { nil } || api.variant_call == unsafe { nil } {
		return false
	}
	self_var := scratch()
	out := scratch()
	err := scratch_err()
	from := unsafe { TypeCtor(from_type_of(type_object)) }
	from(self_var, voidptr(&object))
	name := cached_name(method)
	call := unsafe { VariantCall(api.variant_call) }
	mut argv := unsafe { nil }
	if args.len > 0 {
		argv = unsafe { voidptr(&args[0]) }
	}
	dest := if ret == unsafe { nil } { out } else { ret }
	call(self_var, voidptr(&name), argv, i64(args.len), dest, err)
	free_variant(self_var)
	free_variant(out)
	code := unsafe { *&int(err) }
	release(err)
	return code == 0
}

fn variant_object_ptr(variant voidptr) voidptr {
	mut object := unsafe { nil }
	to := unsafe { TypeCtor(to_type_of(type_object)) }
	to(voidptr(&object), variant)
	return object
}

fn call_object(object voidptr, method string) voidptr {
	ret := scratch()
	ok := invoke(object, method, []voidptr{}, ret)
	found := variant_object_ptr(ret)
	free_variant(ret)
	if ok == false {
		return unsafe { nil }
	}
	return found
}

fn call_void(object voidptr, method string) {
	ret := scratch()
	invoke(object, method, []voidptr{}, ret)
	free_variant(ret)
}

fn call_with(object voidptr, method string, arg voidptr) {
	ret := scratch()
	invoke(object, method, [arg], ret)
	free_variant(ret)
}

fn keep_ref(object voidptr) {
	if object == unsafe { nil } {
		return
	}
	call_void(object, 'reference')
}

fn set_prop(object voidptr, prop string, value voidptr) {
	name_var := scratch()
	stored := cached_name(prop)
	put_name(name_var, stored)
	ret := scratch()
	invoke(object, 'set', [name_var, value], ret)
	free_variant(name_var)
	free_variant(ret)
}

fn set_deferred_prop(object voidptr, prop string, value voidptr) {
	name_var := scratch()
	stored := cached_name(prop)
	put_name(name_var, stored)
	ret := scratch()
	invoke(object, 'set_deferred', [name_var, value], ret)
	free_variant(name_var)
	free_variant(ret)
}

fn get_vector(object voidptr, prop string) (f32, f32) {
	name_var := scratch()
	stored := cached_name(prop)
	put_name(name_var, stored)
	ret := scratch()
	ok := invoke(object, 'get', [name_var], ret)
	mut point := Vec2{}
	if ok {
		to := unsafe { TypeCtor(to_type_of(type_vector2)) }
		to(voidptr(&point), ret)
	}
	free_variant(name_var)
	free_variant(ret)
	return point.x, point.y
}

fn get_float(object voidptr, prop string) f64 {
	name_var := scratch()
	stored := cached_name(prop)
	put_name(name_var, stored)
	ret := scratch()
	ok := invoke(object, 'get', [name_var], ret)
	mut value := f64(0)
	if ok {
		to := unsafe { TypeCtor(to_type_of(type_float)) }
		to(voidptr(&value), ret)
	}
	free_variant(name_var)
	free_variant(ret)
	return value
}

fn set_process_enabled(object voidptr) {
	value := scratch()
	put_bool(value, true)
	call_with(object, 'set_process', value)
	free_variant(value)
}

fn node_at_impl(object voidptr, path string) voidptr {
	if object == unsafe { nil } {
		return unsafe { nil }
	}
	mut text := GdString{}
	text.set_text(path)
	mut node_path := GdString{}
	ctor := unsafe { TypeCtor(constructor_of(type_node_path, 2)) }
	src := voidptr(&text)
	ctor(voidptr(&node_path), voidptr(&src))
	slot := scratch()
	from := unsafe { TypeCtor(from_type_of(type_node_path)) }
	from(slot, voidptr(&node_path))
	ret := scratch()
	ok := invoke(object, 'get_node_or_null', [slot], ret)
	found := variant_object_ptr(ret)
	free_variant(slot)
	free_variant(ret)
	drop_builtin(type_node_path, voidptr(&node_path))
	text.clear()
	if ok == false {
		return unsafe { nil }
	}
	return found
}

fn load_resource_impl(path string) voidptr {
	loader := singleton('ResourceLoader')
	mut text := GdString{}
	text.set_text(path)
	slot := scratch()
	put_string(slot, text)
	ret := scratch()
	ok := invoke(loader, 'load', [slot], ret)
	found := variant_object_ptr(ret)
	if ok && found != unsafe { nil } {
		keep_ref(found)
	}
	free_variant(slot)
	free_variant(ret)
	text.clear()
	if ok == false {
		return unsafe { nil }
	}
	return found
}

fn set_text_prop_impl(object voidptr, prop string, value string) {
	mut text := GdString{}
	text.set_text(value)
	slot := scratch()
	put_string(slot, text)
	set_prop(object, prop, slot)
	free_variant(slot)
	text.clear()
}

fn set_bool_prop(object voidptr, prop string, value bool) {
	slot := scratch()
	put_bool(slot, value)
	set_prop(object, prop, slot)
	free_variant(slot)
}

fn set_deferred_bool(object voidptr, prop string, value bool) {
	slot := scratch()
	put_bool(slot, value)
	set_deferred_prop(object, prop, slot)
	free_variant(slot)
}

fn call_group_impl(object voidptr, group string, method string) {
	tree := call_object(object, 'get_tree')
	if tree == unsafe { nil } {
		return
	}
	group_name := cached_name(group)
	method_name := cached_name(method)
	first := scratch()
	second := scratch()
	put_name(first, group_name)
	put_name(second, method_name)
	ret := scratch()
	invoke(tree, 'call_group', [first, second], ret)
	free_variant(first)
	free_variant(second)
	free_variant(ret)
}

fn play_anim_impl(object voidptr, name string) {
	if name == '' {
		call_void(object, 'play')
		return
	}
	stored := cached_name(name)
	slot := scratch()
	put_name(slot, stored)
	call_with(object, 'play', slot)
	free_variant(slot)
}

fn move_to_impl(object voidptr, x f32, y f32) {
	slot := scratch()
	put_vector(slot, x, y)
	set_prop(object, 'position', slot)
	free_variant(slot)
}

fn push_velocity_impl(object voidptr, x f32, y f32) {
	slot := scratch()
	put_vector(slot, x, y)
	set_prop(object, 'linear_velocity', slot)
	free_variant(slot)
}

fn set_float_prop(object voidptr, prop string, value f64) {
	slot := scratch()
	put_float(slot, value)
	set_prop(object, prop, slot)
	free_variant(slot)
}

fn add_child_impl(parent voidptr, child voidptr) {
	if parent == unsafe { nil } || child == unsafe { nil } {
		return
	}
	slot := scratch()
	from := unsafe { TypeCtor(from_type_of(type_object)) }
	from(slot, voidptr(&child))
	call_with(parent, 'add_child', slot)
	free_variant(slot)
}

fn viewport_size_impl(object voidptr) (f32, f32) {
	ret := scratch()
	ok := invoke(object, 'get_viewport_rect', []voidptr{}, ret)
	mut rect := Rect{}
	if ok {
		to := unsafe { TypeCtor(to_type_of(type_rect2)) }
		to(voidptr(&rect), ret)
	}
	free_variant(ret)
	return rect.w, rect.h
}

fn delta_of_impl(object voidptr) f64 {
	ret := scratch()
	ok := invoke(object, 'get_process_delta_time', []voidptr{}, ret)
	mut value := f64(0)
	if ok {
		to := unsafe { TypeCtor(to_type_of(type_float)) }
		to(voidptr(&value), ret)
	}
	free_variant(ret)
	return value
}

fn feature_impl(name string) bool {
	target := singleton('OS')
	mut text := GdString{}
	text.set_text(name)
	slot := scratch()
	put_string(slot, text)
	ret := scratch()
	ok := invoke(target, 'has_feature', [slot], ret)
	mut flag := u8(0)
	if ok {
		to := unsafe { TypeCtor(to_type_of(type_bool)) }
		to(voidptr(&flag), ret)
	}
	free_variant(slot)
	free_variant(ret)
	text.clear()
	return flag != 0
}

fn action_down_impl(name string) bool {
	input := singleton('Input')
	stored := cached_name(name)
	slot := scratch()
	put_name(slot, stored)
	ret := scratch()
	ok := invoke(input, 'is_action_pressed', [slot], ret)
	mut flag := u8(0)
	if ok {
		to := unsafe { TypeCtor(to_type_of(type_bool)) }
		to(voidptr(&flag), ret)
	}
	free_variant(slot)
	free_variant(ret)
	return flag != 0
}

// register_main stores the callbacks for a main script.
pub fn register_main(enter fn (), signal fn (string) bool) {
	$if script_guest ? {
		C.godot_v_register_main(voidptr(enter), voidptr(signal))
	} $else {
		bind_script('main', voidptr(enter), unsafe { nil }, voidptr(signal))
	}
}

// register_player stores the callbacks for a player script.
pub fn register_player(enter fn (), frame fn (f64), signal fn (string) bool) {
	$if script_guest ? {
		C.godot_v_register_player(voidptr(enter), voidptr(frame), voidptr(signal))
	} $else {
		bind_script('player', voidptr(enter), voidptr(frame), voidptr(signal))
	}
}

// register_mob stores the callback for a mob script.
pub fn register_mob(enter fn ()) {
	$if script_guest ? {
		C.godot_v_register_mob(voidptr(enter))
	} $else {
		bind_script('mob', voidptr(enter), unsafe { nil }, unsafe { nil })
	}
}

// live returns the session shared by the running scripts.
pub fn live() &Session {
	return active_session
}

// owner returns the node whose script is currently running.
pub fn owner() voidptr {
	$if script_guest ? {
		return C.godot_v_owner()
	} $else {
		return bound_owner
	}
}

// call_group calls method on every node in group.
pub fn call_group(object voidptr, group string, method string) {
	$if script_guest ? {
		C.godot_v_call_group(object, group.str, group.len, method.str, method.len)
	} $else {
		call_group_impl(object, group, method)
	}
}

// call_method calls method on object with no arguments.
pub fn call_method(object voidptr, method string) {
	$if script_guest ? {
		C.godot_v_call_method(object, method.str, method.len)
	} $else {
		call_void(object, method)
	}
}

// node_at returns the node at path, or nil when it is missing.
pub fn node_at(object voidptr, path string) voidptr {
	$if script_guest ? {
		return C.godot_v_node_at(object, path.str, path.len)
	} $else {
		return node_at_impl(object, path)
	}
}

// timer_start starts a timer node.
pub fn timer_start(object voidptr) {
	$if script_guest ? {
		C.godot_v_timer_start(object)
	} $else {
		call_void(object, 'start')
	}
}

// timer_stop stops a timer node.
pub fn timer_stop(object voidptr) {
	$if script_guest ? {
		C.godot_v_timer_stop(object)
	} $else {
		call_void(object, 'stop')
	}
}

// hide_node hides a canvas item.
pub fn hide_node(object voidptr) {
	$if script_guest ? {
		C.godot_v_hide_node(object)
	} $else {
		call_void(object, 'hide')
	}
}

// show_node shows a canvas item.
pub fn show_node(object voidptr) {
	$if script_guest ? {
		C.godot_v_show_node(object)
	} $else {
		call_void(object, 'show')
	}
}

// audio_play starts an audio player.
pub fn audio_play(object voidptr) {
	$if script_guest ? {
		C.godot_v_audio_play(object)
	} $else {
		call_void(object, 'play')
	}
}

// audio_stop stops an audio player.
pub fn audio_stop(object voidptr) {
	$if script_guest ? {
		C.godot_v_audio_stop(object)
	} $else {
		call_void(object, 'stop')
	}
}

// load_resource loads the resource at path.
pub fn load_resource(path string) voidptr {
	$if script_guest ? {
		return C.godot_v_load_resource(path.str, path.len)
	} $else {
		return load_resource_impl(path)
	}
}

// feature reports whether Godot was started with the named feature.
pub fn feature(name string) bool {
	$if script_guest ? {
		return C.godot_v_feature(name.str, name.len) != 0
	} $else {
		return feature_impl(name)
	}
}

// set_text_prop sets a string property on object.
pub fn set_text_prop(object voidptr, prop string, value string) {
	$if script_guest ? {
		C.godot_v_set_text_prop(object, prop.str, prop.len, value.str, value.len)
	} $else {
		set_text_prop_impl(object, prop, value)
	}
}

// set_flag_prop sets a bool property on object.
pub fn set_flag_prop(object voidptr, prop string, value bool) {
	$if script_guest ? {
		C.godot_v_set_flag_prop(object, prop.str, prop.len, flag_of(value))
	} $else {
		set_bool_prop(object, prop, value)
	}
}

// instance_scene instantiates a packed scene.
pub fn instance_scene(scene voidptr) voidptr {
	$if script_guest ? {
		return C.godot_v_instance_scene(scene)
	} $else {
		return call_object(scene, 'instantiate')
	}
}

// set_progress_ratio sets progress_ratio on a path follow.
pub fn set_progress_ratio(object voidptr, ratio f64) {
	$if script_guest ? {
		C.godot_v_set_progress_ratio(object, ratio)
	} $else {
		set_float_prop(object, 'progress_ratio', ratio)
	}
}

// position_of reads the position of a node.
pub fn position_of(object voidptr) (f32, f32) {
	$if script_guest ? {
		mut x := f32(0)
		mut y := f32(0)
		C.godot_v_position_of(object, &x, &y)
		return x, y
	} $else {
		return get_vector(object, 'position')
	}
}

// rotation_of reads the rotation of a node.
pub fn rotation_of(object voidptr) f64 {
	$if script_guest ? {
		return C.godot_v_rotation_of(object)
	} $else {
		return get_float(object, 'rotation')
	}
}

// move_to sets the position of a node.
pub fn move_to(object voidptr, x f32, y f32) {
	$if script_guest ? {
		C.godot_v_move_to(object, x, y)
	} $else {
		move_to_impl(object, x, y)
	}
}

// set_rotation sets the rotation of a node.
pub fn set_rotation(object voidptr, angle f64) {
	$if script_guest ? {
		C.godot_v_set_rotation(object, angle)
	} $else {
		set_float_prop(object, 'rotation', angle)
	}
}

// push_velocity sets the linear velocity of a rigid body.
pub fn push_velocity(object voidptr, x f32, y f32) {
	$if script_guest ? {
		C.godot_v_push_velocity(object, x, y)
	} $else {
		push_velocity_impl(object, x, y)
	}
}

// add_child adds child to parent.
pub fn add_child(parent voidptr, child voidptr) {
	$if script_guest ? {
		C.godot_v_add_child(parent, child)
	} $else {
		add_child_impl(parent, child)
	}
}

// play_anim plays an animation, or the current one when name is empty.
pub fn play_anim(object voidptr, name string) {
	$if script_guest ? {
		C.godot_v_play_anim(object, name.str, name.len)
	} $else {
		play_anim_impl(object, name)
	}
}

// stop_anim stops an animated sprite.
pub fn stop_anim(object voidptr) {
	$if script_guest ? {
		C.godot_v_stop_anim(object)
	} $else {
		call_void(object, 'stop')
	}
}

// viewport_size reads the visible size of the node's viewport.
pub fn viewport_size(object voidptr) (f32, f32) {
	$if script_guest ? {
		mut x := f32(0)
		mut y := f32(0)
		C.godot_v_viewport_size(object, &x, &y)
		return x, y
	} $else {
		return viewport_size_impl(object)
	}
}

// set_disabled sets the disabled property of a collision shape.
pub fn set_disabled(object voidptr, disabled bool) {
	$if script_guest ? {
		C.godot_v_set_disabled(object, flag_of(disabled))
	} $else {
		set_bool_prop(object, 'disabled', disabled)
	}
}

// parent_of returns the parent of a node.
pub fn parent_of(object voidptr) voidptr {
	$if script_guest ? {
		return C.godot_v_parent_of(object)
	} $else {
		return call_object(object, 'get_parent')
	}
}

// set_deferred_flag sets a bool property at the end of the frame.
pub fn set_deferred_flag(object voidptr, prop string, value bool) {
	$if script_guest ? {
		C.godot_v_set_deferred_flag(object, prop.str, prop.len, flag_of(value))
	} $else {
		set_deferred_bool(object, prop, value)
	}
}

// action_down reports whether an input action is pressed.
pub fn action_down(name string) bool {
	$if script_guest ? {
		return C.godot_v_action_down(name.str, name.len) != 0
	} $else {
		return action_down_impl(name)
	}
}

// delta_of reads the process delta of a node.
pub fn delta_of(object voidptr) f64 {
	$if script_guest ? {
		return C.godot_v_delta_of(object)
	} $else {
		return delta_of_impl(object)
	}
}

fn script_hash(files []string) string {
	mut all := []u8{}
	for file in files {
		text := os.read_file(file) or { '' }
		all << text.bytes()
	}
	return sha256.hexhash(all.bytestr())
}

fn link_module(cache string) bool {
	dir := os.join_path(cache, 'modules', 'asyncbtd')
	os.mkdir_all(dir) or { return false }
	link := os.join_path(dir, 'godot')
	if os.exists(link) {
		os.rm(link) or { return false }
	}
	os.symlink(@VMODROOT, link) or { return false }
	return true
}

fn host_library() string {
	text := os.read_file('/proc/self/maps') or { return '' }
	for line in text.split_into_lines() {
		if line.contains('libgodotv.so') == false {
			continue
		}
		start := line.index('/') or { continue }
		return line[start..]
	}
	return ''
}

fn load_error() string {
	ptr := C.dlerror()
	if ptr == unsafe { nil } {
		return ''
	}
	return unsafe { cstring_to_vstring(ptr) }
}

fn promote_host() {
	path := host_library()
	if path.len == 0 {
		return
	}
	C.dlopen(path.str, 262)
}

fn call_symbol(handle voidptr, name string) {
	ptr := C.dlsym(handle, name.str)
	if ptr == unsafe { nil } {
		return
	}
	f := unsafe { EnterFn(ptr) }
	f()
}

fn open_script_library(path string) bool {
	promote_host()
	handle := C.dlopen(path.str, 10)
	if handle == unsafe { nil } {
		report('script library failed to load: ' + load_error())
		return false
	}
	script_library = handle
	call_symbol(handle, 'godot__init')
	call_symbol(handle, 'script__init')
	return true
}

fn remember_script(state voidptr) {
	if state == unsafe { nil } {
		return
	}
	path := script_state(state).path.text()
	if path.len == 0 {
		return
	}
	for item in script_resources {
		if script_state(item).path.text() == path {
			return
		}
	}
	script_resources << state
}

fn files_stamp(files []string) i64 {
	mut stamp := i64(0)
	for file in files {
		stamp += os.file_last_mod_unix(file)
	}
	return stamp
}

fn reload_script_sources(project string) {
	for state in script_resources {
		res_path := script_state(state).path.text()
		if res_path.starts_with('res://') == false {
			continue
		}
		full := os.join_path(project, res_path.all_after('res://'))
		text := os.read_file(full) or { continue }
		set_script_source(state, text)
	}
}

fn ensure_project_scripts() {
	if script_library != unsafe { nil } {
		return
	}
	load_project_scripts()
}

fn load_project_scripts() {
	project := call_string(singleton('ProjectSettings'), 'ProjectSettings', 'globalize_path',
		3135753539, 'res://').trim_right('/')
	if project.len == 0 {
		return
	}
	script_dir := os.join_path(project, 'script')
	if os.exists(os.join_path(script_dir, 'entry.v')) == false {
		return
	}
	mut files := os.walk_ext(script_dir, '.v')
	files.sort()
	if files.len == 0 {
		return
	}
	stamp := files_stamp(files)
	if script_library != unsafe { nil } && stamp == loaded_stamp {
		return
	}
	sum := script_hash(files)
	loaded_stamp = stamp
	if script_library != unsafe { nil } && sum == loaded_hash {
		return
	}
	cache := os.join_path(project, '.godot', 'godot-v')
	os.mkdir_all(cache) or {
		report('script cache directory failed')
		return
	}
	so_path := os.join_path(cache, 'libscript-' + sum + '.so')
	if os.exists(so_path) == false {
		if link_module(cache) == false {
			report('script module link failed')
			return
		}
		limit := bind_ram_kb.str()
		modules := os.join_path(cache, 'modules')
		command := 'cd ' + sh_quote(script_dir) + ' && ulimit -v ' + limit + ' && VMODULES=' +
			sh_quote(modules) + ' v -cc gcc -d script_guest -shared -enable-globals -o ' +
			sh_quote(so_path) + ' .'
		if shell(command) != 0 {
			report('script compile failed')
			return
		}
	}
	if open_script_library(so_path) == false {
		return
	}
	loaded_hash = sum
	reload_script_sources(project)
}

$if !script_guest ? {
	@[export: 'godot_v_report']
	fn godot_v_report(ptr &u8, len int) {
		report_impl(text_of(ptr, len))
	}

	@[export: 'godot_v_register_main']
	fn godot_v_register_main(enter voidptr, signal voidptr) {
		bind_script('main', enter, unsafe { nil }, signal)
	}

	@[export: 'godot_v_register_player']
	fn godot_v_register_player(enter voidptr, frame voidptr, signal voidptr) {
		bind_script('player', enter, frame, signal)
	}

	@[export: 'godot_v_register_mob']
	fn godot_v_register_mob(enter voidptr) {
		bind_script('mob', enter, unsafe { nil }, unsafe { nil })
	}

	@[export: 'godot_v_live']
	fn godot_v_live() voidptr {
		return unsafe { &session }
	}

	@[export: 'godot_v_owner']
	fn godot_v_owner() voidptr {
		return bound_owner
	}

	@[export: 'godot_v_call_group']
	fn godot_v_call_group(object voidptr, group &u8, group_len int, method &u8, method_len int) {
		call_group_impl(object, text_of(group, group_len), text_of(method, method_len))
	}

	@[export: 'godot_v_call_method']
	fn godot_v_call_method(object voidptr, method &u8, len int) {
		call_void(object, text_of(method, len))
	}

	@[export: 'godot_v_node_at']
	fn godot_v_node_at(object voidptr, path &u8, len int) voidptr {
		return node_at_impl(object, text_of(path, len))
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
		return load_resource_impl(text_of(path, len))
	}

	@[export: 'godot_v_feature']
	fn godot_v_feature(name &u8, len int) u8 {
		return flag_of(feature_impl(text_of(name, len)))
	}

	@[export: 'godot_v_set_text_prop']
	fn godot_v_set_text_prop(object voidptr, prop &u8, prop_len int, value &u8, value_len int) {
		set_text_prop_impl(object, text_of(prop, prop_len), text_of(value, value_len))
	}

	@[export: 'godot_v_set_flag_prop']
	fn godot_v_set_flag_prop(object voidptr, prop &u8, prop_len int, value u8) {
		set_bool_prop(object, text_of(prop, prop_len), value != 0)
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
		move_to_impl(object, x, y)
	}

	@[export: 'godot_v_set_rotation']
	fn godot_v_set_rotation(object voidptr, angle f64) {
		set_float_prop(object, 'rotation', angle)
	}

	@[export: 'godot_v_push_velocity']
	fn godot_v_push_velocity(object voidptr, x f32, y f32) {
		push_velocity_impl(object, x, y)
	}

	@[export: 'godot_v_add_child']
	fn godot_v_add_child(parent voidptr, child voidptr) {
		add_child_impl(parent, child)
	}

	@[export: 'godot_v_play_anim']
	fn godot_v_play_anim(object voidptr, name &u8, len int) {
		play_anim_impl(object, text_of(name, len))
	}

	@[export: 'godot_v_stop_anim']
	fn godot_v_stop_anim(object voidptr) {
		call_void(object, 'stop')
	}

	@[export: 'godot_v_viewport_size']
	fn godot_v_viewport_size(object voidptr, x &f32, y &f32) {
		w, h := viewport_size_impl(object)
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
		set_deferred_bool(object, text_of(prop, len), value != 0)
	}

	@[export: 'godot_v_action_down']
	fn godot_v_action_down(name &u8, len int) u8 {
		return flag_of(action_down_impl(text_of(name, len)))
	}

	@[export: 'godot_v_delta_of']
	fn godot_v_delta_of(object voidptr) f64 {
		return delta_of_impl(object)
	}
}

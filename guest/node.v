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

type VariantCall = fn (voidptr, voidptr, voidptr, i64, voidptr, voidptr)

pub type PropertyValue = bool | f64 | string

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

struct CachedName {
	key  string
	name GdString
}

__global name_cache = []CachedName{}
__global bound_owner = unsafe { nil }

// call_method calls method on object with no arguments.
pub fn call_method(object voidptr, method string) {
	call_void(object, method)
}

// connect binds signal on source to method on target.
pub fn connect(source voidptr, signal_name string, target voidptr, method string) {
	if source == unsafe { nil } || target == unsafe { nil } || signal_name == '' || method == '' {
		return
	}
	method_name := cached_name(method)
	callable := alloc(24)
	mut ctor_args := [2]voidptr{}
	ctor_args[0] = voidptr(&target)
	ctor_args[1] = voidptr(&method_name)
	build := unsafe { TypeCtor(constructor_of(type_callable, 2)) }
	build(callable, voidptr(&ctor_args[0]))
	signal := cached_name(signal_name)
	flags := i64(0)
	mut args := [3]voidptr{}
	args[0] = voidptr(&signal)
	args[1] = callable
	args[2] = voidptr(&flags)
	mut err := i64(0)
	bind := method_bind('Object', 'connect', 1518946055)
	call := unsafe { Ptrcall(api.ptrcall) }
	call(bind, source, voidptr(&args[0]), voidptr(&err))
	drop := unsafe { TypeCtor(destructor_of(type_callable)) }
	drop(callable, unsafe { nil })
	free_mem(callable)
	if err != 0 {
		report('connect ${signal_name} -> ${method} failed: ${err}')
	}
}

// timer_start starts a timer node.
pub fn timer_start(object voidptr) {
	call_void(object, 'start')
}

// timer_stop stops a timer node.
pub fn timer_stop(object voidptr) {
	call_void(object, 'stop')
}

// set_property sets a bool, number, or string property on object.
pub fn set_property(object voidptr, prop string, value PropertyValue) {
	match value {
		bool { set_bool_prop(object, prop, value) }
		f64 { set_float_prop(object, prop, value) }
		string { set_string_prop(object, prop, value) }
	}
}

// set_property_deferred sets a bool property at the end of the frame.
pub fn set_property_deferred(object voidptr, prop string, value bool) {
	set_deferred_bool(object, prop, value)
}

// set_progress_ratio sets progress_ratio on a path follow.
pub fn set_progress_ratio(object voidptr, ratio f64) {
	set_float_prop(object, 'progress_ratio', ratio)
}

// position_of reads the position of a node.
pub fn position_of(object voidptr) (f32, f32) {
	return get_vector(object, 'position')
}

// rotation_of reads the rotation of a node.
pub fn rotation_of(object voidptr) f64 {
	return get_float(object, 'rotation')
}

// set_rotation sets the rotation of a node.
pub fn set_rotation(object voidptr, angle f64) {
	set_float_prop(object, 'rotation', angle)
}

// set_disabled sets the disabled property of a collision shape.
pub fn set_disabled(object voidptr, disabled bool) {
	set_bool_prop(object, 'disabled', disabled)
}

// parent_of returns the parent of a node.
pub fn parent_of(object voidptr) voidptr {
	return call_object(object, 'get_parent')
}

// node_at returns the node at path, or nil when it is missing.
pub fn node_at(object voidptr, path string) voidptr {
	if object == unsafe { nil } {
		return unsafe { nil }
	}
	mut text := GdString{}
	text.set_text(path)
	mut node_path := GdString{}
	ctor := unsafe { TypeCtor(constructor_of(type_node_path, 2)) }
	src := voidptr(&text)
	ctor(voidptr(&node_path), voidptr(&src))
	slot := temp_variant()
	from := unsafe { TypeCtor(from_type_of(type_node_path)) }
	from(slot, voidptr(&node_path))
	ret := temp_variant()
	ok := invoke(object, 'get_node_or_null', [slot], ret)
	found := variant_object_ptr(ret)
	free_variant(slot)
	free_variant(ret)
	destroy_builtin(type_node_path, voidptr(&node_path))
	text.clear()
	if ok == false {
		return unsafe { nil }
	}
	return found
}

// call_group calls method on every node in group.
pub fn call_group(object voidptr, group string, method string) {
	tree := call_object(object, 'get_tree')
	if tree == unsafe { nil } {
		return
	}
	group_name := cached_name(group)
	method_name := cached_name(method)
	first := temp_variant()
	second := temp_variant()
	write_variant_name(first, group_name)
	write_variant_name(second, method_name)
	ret := temp_variant()
	invoke(tree, 'call_group', [first, second], ret)
	free_variant(first)
	free_variant(second)
	free_variant(ret)
}

// add_child adds child to parent.
pub fn add_child(parent voidptr, child voidptr) {
	if parent == unsafe { nil } || child == unsafe { nil } {
		return
	}
	slot := temp_variant()
	from := unsafe { TypeCtor(from_type_of(type_object)) }
	from(slot, voidptr(&child))
	call_with(parent, 'add_child', slot)
	free_variant(slot)
}

// viewport_size reads the visible size of the node's viewport.
pub fn viewport_size(object voidptr) (f32, f32) {
	ret := temp_variant()
	ok := invoke(object, 'get_viewport_rect', []voidptr{}, ret)
	mut rect := Rect{}
	if ok {
		to := unsafe { TypeCtor(to_type_of(type_rect2)) }
		to(voidptr(&rect), ret)
	}
	free_variant(ret)
	return rect.w, rect.h
}

fn text_from_ptr(ptr &u8, len int) string {
	if ptr == unsafe { nil } || len <= 0 {
		return ''
	}
	return unsafe { tos(ptr, len) }
}

fn bool_to_u8(value bool) u8 {
	if value {
		return 1
	}
	return 0
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

fn temp_variant() voidptr {
	return alloc(24)
}

fn temp_call_error() voidptr {
	return alloc(12)
}

fn free_variant(ptr voidptr) {
	destroy_variant(ptr)
	free_mem(ptr)
}

fn destroy_variant(ptr voidptr) {
	if ptr == unsafe { nil } || api.variant_destroy == unsafe { nil } {
		return
	}
	f := unsafe { VariantDestroy(api.variant_destroy) }
	f(ptr)
}

fn destroy_builtin(typ int, ptr voidptr) {
	dtor := unsafe { TypeCtor(destructor_of(typ)) }
	dtor(ptr, unsafe { nil })
}

fn write_variant_bool(dest voidptr, value bool) {
	flag := bool_to_u8(value)
	from := unsafe { TypeCtor(from_type_of(type_bool)) }
	from(dest, voidptr(&flag))
}

fn write_variant_float(dest voidptr, value f64) {
	from := unsafe { TypeCtor(from_type_of(type_float)) }
	from(dest, voidptr(&value))
}

fn write_variant_string(dest voidptr, text &GdString) {
	from := unsafe { TypeCtor(from_type_of(type_string)) }
	from(dest, voidptr(text))
}

fn write_variant_name(dest voidptr, name &GdString) {
	from := unsafe { TypeCtor(from_type_of(type_string_name)) }
	from(dest, voidptr(name))
}

fn invoke(object voidptr, method string, args []voidptr, ret voidptr) bool {
	if object == unsafe { nil } || api.variant_call == unsafe { nil } {
		return false
	}
	self_var := temp_variant()
	out := temp_variant()
	err := temp_call_error()
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
	free_mem(err)
	return code == 0
}

fn variant_object_ptr(variant voidptr) voidptr {
	mut object := unsafe { nil }
	to := unsafe { TypeCtor(to_type_of(type_object)) }
	to(voidptr(&object), variant)
	return object
}

fn call_object(object voidptr, method string) voidptr {
	ret := temp_variant()
	ok := invoke(object, method, []voidptr{}, ret)
	found := variant_object_ptr(ret)
	free_variant(ret)
	if ok == false {
		return unsafe { nil }
	}
	return found
}

fn call_void(object voidptr, method string) {
	ret := temp_variant()
	invoke(object, method, []voidptr{}, ret)
	free_variant(ret)
}

fn call_with(object voidptr, method string, arg voidptr) {
	ret := temp_variant()
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
	name_var := temp_variant()
	stored := cached_name(prop)
	write_variant_name(name_var, stored)
	ret := temp_variant()
	invoke(object, 'set', [name_var, value], ret)
	free_variant(name_var)
	free_variant(ret)
}

fn set_deferred_prop(object voidptr, prop string, value voidptr) {
	name_var := temp_variant()
	stored := cached_name(prop)
	write_variant_name(name_var, stored)
	ret := temp_variant()
	invoke(object, 'set_deferred', [name_var, value], ret)
	free_variant(name_var)
	free_variant(ret)
}

fn get_vector(object voidptr, prop string) (f32, f32) {
	name_var := temp_variant()
	stored := cached_name(prop)
	write_variant_name(name_var, stored)
	ret := temp_variant()
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
	name_var := temp_variant()
	stored := cached_name(prop)
	write_variant_name(name_var, stored)
	ret := temp_variant()
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
	value := temp_variant()
	write_variant_bool(value, true)
	call_with(object, 'set_process', value)
	free_variant(value)
}

fn set_string_prop(object voidptr, prop string, value string) {
	mut text := GdString{}
	text.set_text(value)
	slot := temp_variant()
	write_variant_string(slot, text)
	set_prop(object, prop, slot)
	free_variant(slot)
	text.clear()
}

fn set_bool_prop(object voidptr, prop string, value bool) {
	slot := temp_variant()
	write_variant_bool(slot, value)
	set_prop(object, prop, slot)
	free_variant(slot)
}

fn set_deferred_bool(object voidptr, prop string, value bool) {
	slot := temp_variant()
	write_variant_bool(slot, value)
	set_deferred_prop(object, prop, slot)
	free_variant(slot)
}

fn set_float_prop(object voidptr, prop string, value f64) {
	slot := temp_variant()
	write_variant_float(slot, value)
	set_prop(object, prop, slot)
	free_variant(slot)
}

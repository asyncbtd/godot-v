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

pub type PropertyValue = bool | f64 | string

__global bound_owner = unsafe { nil }

// call_method calls method on object with no arguments.
pub fn call_method(object voidptr, method string) {
	if gdf == unsafe { nil } || object == unsafe { nil } || method == '' {
		return
	}
	result := Object{
		ptr: object
	}.call(method)
	result.deinit()
}

// connect binds signal on source to method on target.
pub fn connect(source voidptr, signal_name string, target voidptr, method string) {
	if gdf == unsafe { nil } || source == unsafe { nil } || target == unsafe { nil } || signal_name == ''
		|| method == '' {
		return
	}
	signal := Signal.new2(Object{ ptr: source }, signal_name)
	defer { signal.deinit() }
	callback := Callable.new2(Object{ ptr: target }, method)
	defer { callback.deinit() }
	err := signal.connect(callback)
	if err != 0 {
		report('connect ${signal_name} -> ${method} failed: ${err}')
	}
}

// timer_start starts a timer node.
pub fn timer_start(object voidptr) {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return
	}
	Timer{
		ptr: object
	}.start()
}

// timer_stop stops a timer node.
pub fn timer_stop(object voidptr) {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return
	}
	Timer{
		ptr: object
	}.stop()
}

// set_property sets a bool, number, or string property on object.
pub fn set_property(object voidptr, prop string, value PropertyValue) {
	if gdf == unsafe { nil } || object == unsafe { nil } || prop == '' {
		return
	}
	target := Object{
		ptr: object
	}
	match value {
		bool {
			held := Variant.from_bool(value)
			target.set(prop, held)
		}
		f64 {
			held := Variant.from_f64(value)
			target.set(prop, held)
		}
		string {
			held := String.new(value)
			defer { held.deinit() }
			target.set(prop, held)
		}
	}
}

// set_property_deferred sets a bool property at the end of the frame.
pub fn set_property_deferred(object voidptr, prop string, value bool) {
	if gdf == unsafe { nil } || object == unsafe { nil } || prop == '' {
		return
	}
	held := Variant.from_bool(value)
	Object{
		ptr: object
	}.set_deferred(prop, held)
}

// set_progress_ratio sets progress_ratio on a path follow.
pub fn set_progress_ratio(object voidptr, ratio f64) {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return
	}
	PathFollow2D{
		ptr: object
	}.set_progress_ratio(ratio)
}

// position_of reads the position of a node.
pub fn position_of(object voidptr) (f32, f32) {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return 0, 0
	}
	point := Node2D{
		ptr: object
	}.get_position()
	return point.x, point.y
}

// rotation_of reads the rotation of a node.
pub fn rotation_of(object voidptr) f64 {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return 0
	}
	return Node2D{
		ptr: object
	}.get_rotation()
}

// set_rotation sets the rotation of a node.
pub fn set_rotation(object voidptr, angle f64) {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return
	}
	Node2D{
		ptr: object
	}.set_rotation(angle)
}

// set_disabled sets the disabled property of a collision shape.
pub fn set_disabled(object voidptr, disabled bool) {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return
	}
	CollisionShape2D{
		ptr: object
	}.set_disabled(disabled)
}

// parent_of returns the parent of a node.
pub fn parent_of(object voidptr) voidptr {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return unsafe { nil }
	}
	return Node{
		ptr: object
	}.get_parent().ptr
}

// node_at returns the node at path, or nil when it is missing.
pub fn node_at(object voidptr, path string) voidptr {
	if gdf == unsafe { nil } || object == unsafe { nil } || path == '' {
		return unsafe { nil }
	}
	route := NodePath.new(path)
	defer { route.deinit() }
	return Node{
		ptr: object
	}.get_node_or_null(route).ptr
}

// call_group calls method on every node in group.
pub fn call_group(object voidptr, group string, method string) {
	if gdf == unsafe { nil } || object == unsafe { nil } || group == '' || method == '' {
		return
	}
	tree := Node{
		ptr: object
	}.get_tree()
	if tree.ptr == unsafe { nil } {
		return
	}
	tree.call_group(group, method)
}

// add_child adds child to parent.
pub fn add_child(parent voidptr, child voidptr) {
	if gdf == unsafe { nil } || parent == unsafe { nil } || child == unsafe { nil } {
		return
	}
	Node{
		ptr: parent
	}.add_child(Node{ ptr: child })
}

// viewport_size reads the visible size of the node's viewport.
pub fn viewport_size(object voidptr) (f32, f32) {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return 0, 0
	}
	rect := CanvasItem{
		ptr: object
	}.get_viewport_rect()
	return rect.size.x, rect.size.y
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

fn temp_variant() voidptr {
	return alloc(24)
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

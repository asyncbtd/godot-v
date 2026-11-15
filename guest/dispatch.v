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

fn call_named[T](owner voidptr, name string) bool {
	mut self := unsafe { ensure_state[T]() }
	attach_base(self, owner)
	bound_result = CallValue{}
	mut found := false
	$for method in T.methods {
		$if method.args.len == 0 {
			if wants_alias(method.name, name, virtual_zero(method.name)) {
				found = true

				$if method.return_type is bool {
					value := self.$method()
					bound_result = CallValue{
						kind: kind_bool
						b:    value
					}
				} $else $if method.return_type is int {
					value := self.$method()
					bound_result = CallValue{
						kind: kind_int
						i:    i64(value)
					}
				} $else $if method.return_type is i64 {
					value := self.$method()
					bound_result = CallValue{
						kind: kind_i64
						i:    value
					}
				} $else $if method.return_type is f32 {
					value := self.$method()
					bound_result = CallValue{
						kind: kind_f32
						f:    f64(value)
					}
				} $else $if method.return_type is f64 {
					value := self.$method()
					bound_result = CallValue{
						kind: kind_f64
						f:    value
					}
				} $else $if method.return_type is string {
					value := self.$method()
					bound_result = CallValue{
						kind: kind_string
						s:    value
					}
				} $else $if method.return_type is Vector2 {
					value := self.$method()
					bound_result = CallValue{
						kind: kind_vector2
						x:    value.x
						y:    value.y
					}
				} $else $if method.return_type is Object {
					value := self.$method()
					bound_result = CallValue{
						kind: kind_object
						o:    value.ptr
					}
				} $else $if method.return_type is voidptr {
					value := self.$method()
					bound_result = CallValue{
						kind: kind_object
						o:    value
					}
				} $else $if method.return_type is void {
					self.$method()
					bound_result = CallValue{}
				} $else {
					_ = self.$method()
					bound_result = CallValue{}
				}
			}
		}
		$if method.args.len == 1 {
			$if method.args[0].typ is bool {
				if wants_alias(method.name, name, false) {
					found = true
					$if method.return_type is bool {
						value := self.$method(take_arg(0).b)
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(take_arg(0).b)
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(take_arg(0).b)
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(take_arg(0).b)
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(take_arg(0).b)
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(take_arg(0).b)
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(take_arg(0).b)
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(take_arg(0).b)
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(take_arg(0).b)
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(take_arg(0).b)
						bound_result = CallValue{}
					} $else {
						_ = self.$method(take_arg(0).b)
						bound_result = CallValue{}
					}
				}
			}
			$if method.args[0].typ is int {
				if wants_alias(method.name, name, false) {
					found = true
					$if method.return_type is bool {
						value := self.$method(int(take_arg(0).i))
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(int(take_arg(0).i))
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(int(take_arg(0).i))
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(int(take_arg(0).i))
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(int(take_arg(0).i))
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(int(take_arg(0).i))
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(int(take_arg(0).i))
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(int(take_arg(0).i))
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(int(take_arg(0).i))
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(int(take_arg(0).i))
						bound_result = CallValue{}
					} $else {
						_ = self.$method(int(take_arg(0).i))
						bound_result = CallValue{}
					}
				}
			}
			$if method.args[0].typ is i64 {
				if wants_alias(method.name, name, false) {
					found = true
					$if method.return_type is bool {
						value := self.$method(take_arg(0).i)
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(take_arg(0).i)
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(take_arg(0).i)
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(take_arg(0).i)
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(take_arg(0).i)
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(take_arg(0).i)
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(take_arg(0).i)
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(take_arg(0).i)
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(take_arg(0).i)
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(take_arg(0).i)
						bound_result = CallValue{}
					} $else {
						_ = self.$method(take_arg(0).i)
						bound_result = CallValue{}
					}
				}
			}
			$if method.args[0].typ is f32 {
				if wants_alias(method.name, name, false) {
					found = true
					$if method.return_type is bool {
						value := self.$method(f32(take_arg(0).f))
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(f32(take_arg(0).f))
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(f32(take_arg(0).f))
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(f32(take_arg(0).f))
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(f32(take_arg(0).f))
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(f32(take_arg(0).f))
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(f32(take_arg(0).f))
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(f32(take_arg(0).f))
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(f32(take_arg(0).f))
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(f32(take_arg(0).f))
						bound_result = CallValue{}
					} $else {
						_ = self.$method(f32(take_arg(0).f))
						bound_result = CallValue{}
					}
				}
			}
			$if method.args[0].typ is f64 {
				if wants_alias(method.name, name, virtual_delta(method.name)) {
					found = true
					$if method.return_type is bool {
						value := self.$method(take_arg(0).f)
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(take_arg(0).f)
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(take_arg(0).f)
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(take_arg(0).f)
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(take_arg(0).f)
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(take_arg(0).f)
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(take_arg(0).f)
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(take_arg(0).f)
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(take_arg(0).f)
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(take_arg(0).f)
						bound_result = CallValue{}
					} $else {
						_ = self.$method(take_arg(0).f)
						bound_result = CallValue{}
					}
				}
			}
			$if method.args[0].typ is string {
				if wants_alias(method.name, name, false) {
					found = true
					$if method.return_type is bool {
						value := self.$method(take_arg(0).s)
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(take_arg(0).s)
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(take_arg(0).s)
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(take_arg(0).s)
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(take_arg(0).s)
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(take_arg(0).s)
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(take_arg(0).s)
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(take_arg(0).s)
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(take_arg(0).s)
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(take_arg(0).s)
						bound_result = CallValue{}
					} $else {
						_ = self.$method(take_arg(0).s)
						bound_result = CallValue{}
					}
				}
			}
			$if method.args[0].typ is Vector2 {
				if wants_alias(method.name, name, false) {
					found = true
					$if method.return_type is bool {
						value := self.$method(Vector2{ x: take_arg(0).x, y: take_arg(0).y })
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(Vector2{ x: take_arg(0).x, y: take_arg(0).y })
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(Vector2{ x: take_arg(0).x, y: take_arg(0).y })
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(Vector2{ x: take_arg(0).x, y: take_arg(0).y })
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(Vector2{ x: take_arg(0).x, y: take_arg(0).y })
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(Vector2{ x: take_arg(0).x, y: take_arg(0).y })
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(Vector2{ x: take_arg(0).x, y: take_arg(0).y })
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(Vector2{ x: take_arg(0).x, y: take_arg(0).y })
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(Vector2{ x: take_arg(0).x, y: take_arg(0).y })
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(Vector2{ x: take_arg(0).x, y: take_arg(0).y })
						bound_result = CallValue{}
					} $else {
						_ = self.$method(Vector2{ x: take_arg(0).x, y: take_arg(0).y })
						bound_result = CallValue{}
					}
				}
			}
			$if method.args[0].typ is Object {
				if wants_alias(method.name, name, virtual_input(method.name)) {
					found = true
					$if method.return_type is bool {
						value := self.$method(Object{ ptr: take_arg(0).o })
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(Object{ ptr: take_arg(0).o })
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(Object{ ptr: take_arg(0).o })
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(Object{ ptr: take_arg(0).o })
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(Object{ ptr: take_arg(0).o })
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(Object{ ptr: take_arg(0).o })
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(Object{ ptr: take_arg(0).o })
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(Object{ ptr: take_arg(0).o })
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(Object{ ptr: take_arg(0).o })
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(Object{ ptr: take_arg(0).o })
						bound_result = CallValue{}
					} $else {
						_ = self.$method(Object{ ptr: take_arg(0).o })
						bound_result = CallValue{}
					}
				}
			}
			$if method.args[0].typ is voidptr {
				if wants_alias(method.name, name, virtual_input(method.name)) {
					found = true
					$if method.return_type is bool {
						value := self.$method(take_arg(0).o)
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(take_arg(0).o)
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(take_arg(0).o)
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(take_arg(0).o)
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(take_arg(0).o)
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(take_arg(0).o)
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(take_arg(0).o)
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(take_arg(0).o)
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(take_arg(0).o)
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(take_arg(0).o)
						bound_result = CallValue{}
					} $else {
						_ = self.$method(take_arg(0).o)
						bound_result = CallValue{}
					}
				}
			}
		}
		$if method.args.len == 2 {
			if method.name == name {
				$if method.args[0].typ is bool && method.args[1].typ is bool {
					found = true
					$if method.return_type is bool {
						value := self.$method(take_arg(0).b, take_arg(1).b)
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(take_arg(0).b, take_arg(1).b)
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(take_arg(0).b, take_arg(1).b)
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(take_arg(0).b, take_arg(1).b)
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(take_arg(0).b, take_arg(1).b)
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(take_arg(0).b, take_arg(1).b)
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(take_arg(0).b, take_arg(1).b)
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(take_arg(0).b, take_arg(1).b)
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(take_arg(0).b, take_arg(1).b)
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(take_arg(0).b, take_arg(1).b)
						bound_result = CallValue{}
					} $else {
						_ = self.$method(take_arg(0).b, take_arg(1).b)
						bound_result = CallValue{}
					}
				}
				$if method.args[0].typ is int && method.args[1].typ is int {
					found = true
					$if method.return_type is bool {
						value := self.$method(int(take_arg(0).i), int(take_arg(1).i))
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(int(take_arg(0).i), int(take_arg(1).i))
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(int(take_arg(0).i), int(take_arg(1).i))
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(int(take_arg(0).i), int(take_arg(1).i))
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(int(take_arg(0).i), int(take_arg(1).i))
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(int(take_arg(0).i), int(take_arg(1).i))
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(int(take_arg(0).i), int(take_arg(1).i))
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(int(take_arg(0).i), int(take_arg(1).i))
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(int(take_arg(0).i), int(take_arg(1).i))
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(int(take_arg(0).i), int(take_arg(1).i))
						bound_result = CallValue{}
					} $else {
						_ = self.$method(int(take_arg(0).i), int(take_arg(1).i))
						bound_result = CallValue{}
					}
				}
				$if method.args[0].typ is i64 && method.args[1].typ is i64 {
					found = true
					$if method.return_type is bool {
						value := self.$method(take_arg(0).i, take_arg(1).i)
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(take_arg(0).i, take_arg(1).i)
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(take_arg(0).i, take_arg(1).i)
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(take_arg(0).i, take_arg(1).i)
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(take_arg(0).i, take_arg(1).i)
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(take_arg(0).i, take_arg(1).i)
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(take_arg(0).i, take_arg(1).i)
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(take_arg(0).i, take_arg(1).i)
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(take_arg(0).i, take_arg(1).i)
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(take_arg(0).i, take_arg(1).i)
						bound_result = CallValue{}
					} $else {
						_ = self.$method(take_arg(0).i, take_arg(1).i)
						bound_result = CallValue{}
					}
				}
				$if method.args[0].typ is f32 && method.args[1].typ is f32 {
					found = true
					$if method.return_type is bool {
						value := self.$method(f32(take_arg(0).f), f32(take_arg(1).f))
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(f32(take_arg(0).f), f32(take_arg(1).f))
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(f32(take_arg(0).f), f32(take_arg(1).f))
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(f32(take_arg(0).f), f32(take_arg(1).f))
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(f32(take_arg(0).f), f32(take_arg(1).f))
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(f32(take_arg(0).f), f32(take_arg(1).f))
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(f32(take_arg(0).f), f32(take_arg(1).f))
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(f32(take_arg(0).f), f32(take_arg(1).f))
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(f32(take_arg(0).f), f32(take_arg(1).f))
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(f32(take_arg(0).f), f32(take_arg(1).f))
						bound_result = CallValue{}
					} $else {
						_ = self.$method(f32(take_arg(0).f), f32(take_arg(1).f))
						bound_result = CallValue{}
					}
				}
				$if method.args[0].typ is f64 && method.args[1].typ is f64 {
					found = true
					$if method.return_type is bool {
						value := self.$method(take_arg(0).f, take_arg(1).f)
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(take_arg(0).f, take_arg(1).f)
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(take_arg(0).f, take_arg(1).f)
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(take_arg(0).f, take_arg(1).f)
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(take_arg(0).f, take_arg(1).f)
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(take_arg(0).f, take_arg(1).f)
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(take_arg(0).f, take_arg(1).f)
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(take_arg(0).f, take_arg(1).f)
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(take_arg(0).f, take_arg(1).f)
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(take_arg(0).f, take_arg(1).f)
						bound_result = CallValue{}
					} $else {
						_ = self.$method(take_arg(0).f, take_arg(1).f)
						bound_result = CallValue{}
					}
				}
				$if method.args[0].typ is string && method.args[1].typ is string {
					found = true
					$if method.return_type is bool {
						value := self.$method(take_arg(0).s, take_arg(1).s)
						bound_result = CallValue{
							kind: kind_bool
							b:    value
						}
					} $else $if method.return_type is int {
						value := self.$method(take_arg(0).s, take_arg(1).s)
						bound_result = CallValue{
							kind: kind_int
							i:    i64(value)
						}
					} $else $if method.return_type is i64 {
						value := self.$method(take_arg(0).s, take_arg(1).s)
						bound_result = CallValue{
							kind: kind_i64
							i:    value
						}
					} $else $if method.return_type is f32 {
						value := self.$method(take_arg(0).s, take_arg(1).s)
						bound_result = CallValue{
							kind: kind_f32
							f:    f64(value)
						}
					} $else $if method.return_type is f64 {
						value := self.$method(take_arg(0).s, take_arg(1).s)
						bound_result = CallValue{
							kind: kind_f64
							f:    value
						}
					} $else $if method.return_type is string {
						value := self.$method(take_arg(0).s, take_arg(1).s)
						bound_result = CallValue{
							kind: kind_string
							s:    value
						}
					} $else $if method.return_type is Vector2 {
						value := self.$method(take_arg(0).s, take_arg(1).s)
						bound_result = CallValue{
							kind: kind_vector2
							x:    value.x
							y:    value.y
						}
					} $else $if method.return_type is Object {
						value := self.$method(take_arg(0).s, take_arg(1).s)
						bound_result = CallValue{
							kind: kind_object
							o:    value.ptr
						}
					} $else $if method.return_type is voidptr {
						value := self.$method(take_arg(0).s, take_arg(1).s)
						bound_result = CallValue{
							kind: kind_object
							o:    value
						}
					} $else $if method.return_type is void {
						self.$method(take_arg(0).s, take_arg(1).s)
						bound_result = CallValue{}
					} $else {
						_ = self.$method(take_arg(0).s, take_arg(1).s)
						bound_result = CallValue{}
					}
				}
			}
		}
	}
	write_result()
	return found
}

fn set_named[T](name string) bool {
	mut self := unsafe { ensure_state[T]() }
	mut ok := false
	$for field in T.fields {
		if field.name == name && field.name != 'base' {
			$if field.typ is bool {
				self.$(field.name) = take_arg(0).b
				ok = true
			}
			$if field.typ is int {
				self.$(field.name) = int(take_arg(0).i)
				ok = true
			}
			$if field.typ is i64 {
				self.$(field.name) = take_arg(0).i
				ok = true
			}
			$if field.typ is f32 {
				self.$(field.name) = f32(take_arg(0).f)
				ok = true
			}
			$if field.typ is f64 {
				self.$(field.name) = take_arg(0).f
				ok = true
			}
			$if field.typ is string {
				self.$(field.name) = take_arg(0).s
				ok = true
			}
			$if field.typ is Vector2 {
				self.$(field.name) = Vector2{
					x: take_arg(0).x
					y: take_arg(0).y
				}
				ok = true
			}
			$if field.typ is Object {
				self.$(field.name) = Object{
					ptr: take_arg(0).o
				}
				ok = true
			}
			$if field.typ is Node {
				self.$(field.name) = Node{
					ptr: take_arg(0).o
				}
				ok = true
			}
		}
	}
	return ok
}

fn get_named[T](name string) bool {
	ptr := ensure_state[T]()
	self := unsafe { *ptr }
	mut ok := false
	$for field in T.fields {
		if field.name == name && field.name != 'base' {
			$if field.typ is bool {
				bound_result = CallValue{
					kind: kind_bool
					b:    self.$(field.name)
				}
				ok = true
			}
			$if field.typ is int {
				bound_result = CallValue{
					kind: kind_int
					i:    i64(self.$(field.name))
				}
				ok = true
			}
			$if field.typ is i64 {
				bound_result = CallValue{
					kind: kind_i64
					i:    self.$(field.name)
				}
				ok = true
			}
			$if field.typ is f32 {
				bound_result = CallValue{
					kind: kind_f32
					f:    f64(self.$(field.name))
				}
				ok = true
			}
			$if field.typ is f64 {
				bound_result = CallValue{
					kind: kind_f64
					f:    self.$(field.name)
				}
				ok = true
			}
			$if field.typ is string {
				bound_result = CallValue{
					kind: kind_string
					s:    self.$(field.name)
				}
				ok = true
			}
			$if field.typ is Vector2 {
				value := self.$(field.name)
				bound_result = CallValue{
					kind: kind_vector2
					x:    value.x
					y:    value.y
				}
				ok = true
			}
			$if field.typ is Object {
				bound_result = CallValue{
					kind: kind_object
					o:    self.$(field.name).ptr
				}
				ok = true
			}
			$if field.typ is Node {
				bound_result = CallValue{
					kind: kind_object
					o:    self.$(field.name).ptr
				}
				ok = true
			}
		}
	}
	write_result()
	return ok
}

fn zero_value[T](name string) CallValue {
	blank := T{}
	$for field in T.fields {
		if field.name == name {
			$if field.typ is bool {
				return CallValue{
					kind: kind_bool
					b:    blank.$(field.name)
				}
			}
			$if field.typ is int {
				return CallValue{
					kind: kind_int
					i:    i64(blank.$(field.name))
				}
			}
			$if field.typ is i64 {
				return CallValue{
					kind: kind_i64
					i:    blank.$(field.name)
				}
			}
			$if field.typ is f32 {
				return CallValue{
					kind: kind_f32
					f:    f64(blank.$(field.name))
				}
			}
			$if field.typ is f64 {
				return CallValue{
					kind: kind_f64
					f:    blank.$(field.name)
				}
			}
			$if field.typ is string {
				return CallValue{
					kind: kind_string
					s:    blank.$(field.name)
				}
			}
			$if field.typ is Vector2 {
				value := blank.$(field.name)
				return CallValue{
					kind: kind_vector2
					x:    value.x
					y:    value.y
				}
			}
		}
	}
	return CallValue{}
}

fn can_revert_named[T](name string) bool {
	if exported_prop(name) == false {
		return false
	}
	current := read_prop[T](name)
	origin := zero_value[T](name)
	return current.b != origin.b || current.i != origin.i || current.f != origin.f
		|| current.s != origin.s || current.x != origin.x || current.y != origin.y
		|| current.o != origin.o
}

fn revert_named[T](name string) bool {
	if exported_prop(name) == false {
		return false
	}
	bound_result = zero_value[T](name)
	write_result()
	return true
}

fn read_prop[T](name string) CallValue {
	saved := bound_result
	get_named[T](name)
	value := bound_result
	bound_result = saved
	return value
}

fn exported_prop(name string) bool {
	if slot := godot_host.registry.get(bound_key) {
		for prop in slot.props {
			if prop.name == name && prop.exported {
				return true
			}
		}
	}
	return false
}

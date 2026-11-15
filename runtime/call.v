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

fn call_none(bind voidptr, instance voidptr, ret voidptr) {
	f := unsafe { Ptrcall(godot_host.api.ptrcall) }
	f(bind, instance, unsafe { nil }, ret)
}

fn call_ptr(bind voidptr, instance voidptr, arg voidptr, ret voidptr) {
	f := unsafe { Ptrcall(godot_host.api.ptrcall) }
	slot := arg
	f(bind, instance, voidptr(&slot), ret)
}

fn call_ptr2(bind voidptr, instance voidptr, first voidptr, second voidptr, ret voidptr) {
	unsafe {
		mut args := [2]voidptr{}
		args[0] = first
		args[1] = second
		f := Ptrcall(godot_host.api.ptrcall)
		f(bind, instance, voidptr(&args[0]), ret)
	}
}

fn call_list(bind voidptr, instance voidptr, args []voidptr, ret voidptr) {
	mut argv := unsafe { nil }
	if args.len > 0 {
		argv = unsafe { voidptr(&args[0]) }
	}
	f := unsafe { Ptrcall(godot_host.api.ptrcall) }
	f(bind, instance, argv, ret)
}

fn postinitialize(object voidptr) {
	if gdf == unsafe { nil } || object == unsafe { nil } {
		return
	}
	Object{
		ptr: object
	}.notification(0)
}

fn editor_open() bool {
	if gdf == unsafe { nil } || godot_host.api.engine == unsafe { nil } {
		return false
	}
	return Engine{
		ptr: godot_host.api.engine
	}.is_editor_hint()
}

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
	f := unsafe { Ptrcall(api.ptrcall) }
	f(bind, instance, unsafe { nil }, ret)
}

fn call_ptr(bind voidptr, instance voidptr, arg voidptr, ret voidptr) {
	f := unsafe { Ptrcall(api.ptrcall) }
	slot := arg
	f(bind, instance, voidptr(&slot), ret)
}

fn call_ptr2(bind voidptr, instance voidptr, first voidptr, second voidptr, ret voidptr) {
	unsafe {
		mut args := [2]voidptr{}
		args[0] = first
		args[1] = second
		f := Ptrcall(api.ptrcall)
		f(bind, instance, voidptr(&args[0]), ret)
	}
}

fn call_list(bind voidptr, instance voidptr, args []voidptr, ret voidptr) {
	mut argv := unsafe { nil }
	if args.len > 0 {
		argv = unsafe { voidptr(&args[0]) }
	}
	f := unsafe { Ptrcall(api.ptrcall) }
	f(bind, instance, argv, ret)
}

fn postinitialize(object voidptr) {
	what := i64(0)
	reversed := u8(0)
	call_ptr2(api.notification, object, voidptr(&what), voidptr(&reversed), unsafe { nil })
}

fn object_class(object voidptr) string {
	mut name := GdString{}
	call_none(api.get_class, object, voidptr(&name))
	text := name.text()
	name.clear()
	return text
}

fn editor_open() bool {
	if api.editor_hint == unsafe { nil } || api.engine == unsafe { nil } {
		return false
	}
	mut hint := u8(0)
	call_none(api.editor_hint, api.engine, voidptr(&hint))
	return hint != 0
}

fn call_string(instance voidptr, class_name string, method string, hash i64, arg string) string {
	bind := method_bind(class_name, method, hash)
	mut result := GdString{}
	if arg == '' {
		call_none(bind, instance, voidptr(&result))
	} else {
		mut input := GdString{}
		input.set_text(arg)
		call_ptr(bind, instance, voidptr(&input), voidptr(&result))
		input.clear()
	}
	text := result.text()
	result.clear()
	return text
}

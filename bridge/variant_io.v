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

fn write_bool(dest voidptr, value bool) {
	unsafe {
		*(&u8(dest)) = if value { 1 } else { 0 }
	}
}

fn write_number(dest voidptr, value i64) {
	unsafe {
		*(&i64(dest)) = value
	}
}

fn write_pointer(dest voidptr, value voidptr) {
	unsafe {
		*(&voidptr(dest)) = value
	}
}

fn construct_empty(ctor voidptr, dest voidptr) {
	call := unsafe { TypeCtor(ctor) }
	call(dest, unsafe { nil })
}

fn write_dictionary(dest voidptr) {
	construct_empty(api.new_dictionary, dest)
}

fn write_array(dest voidptr) {
	construct_empty(api.new_array, dest)
}

fn write_packed(dest voidptr, values []string) {
	construct_empty(api.new_packed, dest)
	push := unsafe { BuiltinCall(api.packed_push) }
	for value in values {
		mut item := GdString{}
		item.set_text(value)
		item_ptr := voidptr(&item)
		mut added := u8(0)
		push(dest, voidptr(&item_ptr), voidptr(&added), 1)
		item.clear()
	}
}

fn dictionary_bool(dest voidptr, key string, value bool) {
	write_dictionary(dest)
	mut key_string := GdString{}
	key_string.set_text(key)
	mut key_variant := [24]u8{}
	mut value_variant := [24]u8{}
	from_string := unsafe { TypeCtor(api.variant_from_string) }
	from_bool := unsafe { TypeCtor(api.variant_from_bool) }
	flag := u8(if value { 1 } else { 0 })
	unsafe {
		from_string(voidptr(&key_variant[0]), voidptr(&key_string))
		from_bool(voidptr(&value_variant[0]), voidptr(&flag))
		set := KeyedSet(api.dict_set)
		set(dest, voidptr(&key_variant[0]), voidptr(&value_variant[0]))
		destroy := VariantDestroy(api.variant_destroy)
		destroy(voidptr(&key_variant[0]))
		destroy(voidptr(&value_variant[0]))
	}
	key_string.clear()
}

fn dictionary_text(dest voidptr, key string, value string) {
	write_dictionary(dest)
	mut key_string := GdString{}
	key_string.set_text(key)
	mut value_string := GdString{}
	value_string.set_text(value)
	mut key_variant := [24]u8{}
	mut value_variant := [24]u8{}
	from_string := unsafe { TypeCtor(api.variant_from_string) }
	unsafe {
		from_string(voidptr(&key_variant[0]), voidptr(&key_string))
		from_string(voidptr(&value_variant[0]), voidptr(&value_string))
		set := KeyedSet(api.dict_set)
		set(dest, voidptr(&key_variant[0]), voidptr(&value_variant[0]))
		destroy := VariantDestroy(api.variant_destroy)
		destroy(voidptr(&key_variant[0]))
		destroy(voidptr(&value_variant[0]))
	}
	key_string.clear()
	value_string.clear()
}

fn push_array(array voidptr, item voidptr) {
	name := string_name('push_back')
	method := builtin_method_of(type_array, voidptr(&name), 3316032543)
	if method == unsafe { nil } {
		return
	}
	call := unsafe { BuiltinCall(method) }
	call(array, voidptr(&item), unsafe { nil }, 1)
}

fn variant_object(dest voidptr, object voidptr) {
	from_object := unsafe { TypeCtor(api.variant_from_object) }
	from_object(dest, voidptr(&object))
}

fn variant_number(dest voidptr, value i64) {
	from_int := unsafe { TypeCtor(api.variant_from_int) }
	from_int(dest, voidptr(&value))
}

fn arg(args voidptr, index int) voidptr {
	return unsafe { (&voidptr(args))[index] }
}

fn arg_string(args voidptr, index int) string {
	return read_gd_string(arg(args, index))
}

fn arg_object(args voidptr, index int) voidptr {
	ptr := arg(args, index)
	return unsafe { *&voidptr(ptr) }
}

fn arg_bool(args voidptr, index int) bool {
	ptr := arg(args, index)
	return unsafe { *&u8(ptr) } != 0
}

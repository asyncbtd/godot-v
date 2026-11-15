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
	construct_empty(godot_host.api.new_dictionary, dest)
}

fn write_array(dest voidptr) {
	construct_empty(godot_host.api.new_array, dest)
}

fn write_packed(dest voidptr, values []string) {
	if gdf == unsafe { nil } || dest == unsafe { nil } {
		return
	}
	mut packed := unsafe { &PackedStringArray(dest) }
	unsafe {
		*packed = PackedStringArray.new0()
	}
	for value in values {
		packed.push_back(value)
	}
}

fn dictionary_bool(dest voidptr, key string, value bool) {
	write_dictionary(dest)
	mut key_string := GdString{}
	key_string.set_text(key)
	mut key_variant := [24]u8{}
	mut value_variant := [24]u8{}
	from_string := unsafe { TypeCtor(godot_host.api.variant_from_string) }
	from_bool := unsafe { TypeCtor(godot_host.api.variant_from_bool) }
	flag := u8(if value { 1 } else { 0 })
	unsafe {
		from_string(voidptr(&key_variant[0]), voidptr(&key_string))
		from_bool(voidptr(&value_variant[0]), voidptr(&flag))
		set := KeyedSet(godot_host.api.dict_set)
		set(dest, voidptr(&key_variant[0]), voidptr(&value_variant[0]))
		destroy := VariantDestroy(godot_host.api.variant_destroy)
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
	from_string := unsafe { TypeCtor(godot_host.api.variant_from_string) }
	unsafe {
		from_string(voidptr(&key_variant[0]), voidptr(&key_string))
		from_string(voidptr(&value_variant[0]), voidptr(&value_string))
		set := KeyedSet(godot_host.api.dict_set)
		set(dest, voidptr(&key_variant[0]), voidptr(&value_variant[0]))
		destroy := VariantDestroy(godot_host.api.variant_destroy)
		destroy(voidptr(&key_variant[0]))
		destroy(voidptr(&value_variant[0]))
	}
	key_string.clear()
	value_string.clear()
}

fn push_array(array voidptr, item voidptr) {
	if gdf == unsafe { nil } || array == unsafe { nil } || item == unsafe { nil } {
		return
	}
	list := unsafe { &Array(array) }
	held := unsafe { &Variant(item) }
	list.push_back(held)
}

fn variant_object(dest voidptr, object voidptr) {
	from_object := unsafe { TypeCtor(godot_host.api.variant_from_object) }
	from_object(dest, voidptr(&object))
}

fn variant_number(dest voidptr, value i64) {
	from_int := unsafe { TypeCtor(godot_host.api.variant_from_int) }
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

fn arg_i64(args voidptr, index int) i64 {
	ptr := arg(args, index)
	if ptr == unsafe { nil } {
		return 0
	}
	return unsafe { *&i64(ptr) }
}

fn arg_bool(args voidptr, index int) bool {
	ptr := arg(args, index)
	return unsafe { *&u8(ptr) } != 0
}

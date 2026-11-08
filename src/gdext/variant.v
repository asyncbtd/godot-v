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

module gdext

@[heap]
pub struct Variant {
	data_ [24]u8
}

pub interface ToVariant {
	to_variant() Variant
}

pub interface FromVariant {
mut:
	from_variant(var &Variant)
}

pub fn (s &Variant) deinit() {
	gdf.variant_destroy(s)
}

pub fn (s Variant) to_variant() Variant {
	return s
}

pub fn (s &Variant) from_variant(src Variant) {
	unsafe {
		C.memcpy(&s.data_, &src.data_, sizeof(s.data_))
	}
}

pub fn (s &Variant) to_bool() bool {
	var_to_type := gdf.get_variant_to_type_constructor(GDExtensionVariantType.type_bool)
	t := false
	var_to_type(voidptr(&t), s)
	return t
}

pub fn (s &Variant) from_bool(src bool) {
	to_variant := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_bool)
	to_variant(GDExtensionUninitializedVariantPtr(s), GDExtensionTypePtr(&src))
}

pub fn (s &Variant) to_int() int {
	var_to_type := gdf.get_variant_to_type_constructor(GDExtensionVariantType.type_i64)
	t := 0
	var_to_type(voidptr(&t), s)
	return t
}

pub fn (s &Variant) to_i64() i64 {
	var_to_type := gdf.get_variant_to_type_constructor(GDExtensionVariantType.type_i64)
	t := 0
	var_to_type(voidptr(&t), s)
	return t
}

pub fn (s &Variant) to_f64() f64 {
	var_to_type := gdf.get_variant_to_type_constructor(GDExtensionVariantType.type_f64)
	t := f64(0)
	var_to_type(voidptr(&t), s)
	return t
}

pub fn (s &Variant) from_int(src int) {
	to_variant := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_i64)
	to_variant(GDExtensionUninitializedVariantPtr(s), GDExtensionTypePtr(&src))
}

pub fn (s &Variant) to_string() string {
	var_to_type := gdf.get_variant_to_type_constructor(GDExtensionVariantType.type_string)
	t := String{}
	var_to_type(voidptr(&t), s)
	return t.to_v()
}

pub fn Variant.from_bool(src bool) Variant {
	result := Variant{}
	result.from_bool(src)
	return result
}

pub fn Variant.from_i64(src i64) Variant {
	to_variant := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_i64)
	result := Variant{}
	to_variant(GDExtensionUninitializedVariantPtr(&result), GDExtensionTypePtr(&src))
	return result
}

pub fn Variant.from_int(src int) Variant {
	return Variant.from_i64(i64(src))
}

pub fn Variant.from_f64(src f64) Variant {
	to_variant := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_f64)
	result := Variant{}
	to_variant(GDExtensionUninitializedVariantPtr(&result), GDExtensionTypePtr(&src))
	return result
}

pub fn Variant.from_variant(src Variant) Variant {
	result := Variant{}
	result.from_variant(src)
	return result
}

pub fn String.new(value string) String {
	result := String{}
	gdf.string_new_with_utf8_chars_and_len2(voidptr(&result), value.str, value.len)
	return result
}

pub fn StringName.new(value string) StringName {
	return StringName.new2(value)
}

pub fn NodePath.new(value string) NodePath {
	return NodePath.new2(value)
}

pub fn (s &StringName) to_v() string {
	pba := s.to_utf8_buffer()
	defer { pba.deinit() }
	length := pba.size()
	mut array := []u8{cap: int(length)}
	for i in 0 .. length {
		array << u8(pba.index(i))
	}
	return array.bytestr()
}

pub fn (s &String) to_v() string {
	pba := s.to_utf8_buffer()
	defer { pba.deinit() }
	length := pba.size()
	mut array := []u8{cap: int(length)}
	for i in 0 .. length {
		array << u8(pba.index(i))
	}
	return array.bytestr()
}

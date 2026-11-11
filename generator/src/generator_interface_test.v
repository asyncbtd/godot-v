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

module generator

const sample_dump = '{
	"format_version": 1,
	"types": [
		{"name": "GDExtensionInitializationLevel", "kind": "enum", "values": [
			{"name": "GDEXTENSION_INITIALIZATION_CORE", "value": 0},
			{"name": "GDEXTENSION_MAX_INITIALIZATION_LEVEL", "value": 1}
		]},
		{"name": "GDExtensionBool", "kind": "alias", "type": "uint8_t"},
		{"name": "GDExtensionTypePtr", "kind": "handle"},
		{"name": "GDExtensionCb", "kind": "function", "arguments": [
			{"name": "p_userdata", "type": "void*"},
			{"name": "p_type", "type": "GDExtensionBool"}
		]},
		{"name": "GDExtensionInfo", "kind": "struct", "members": [
			{"name": "type", "type": "GDExtensionBool"},
			{"name": "callback", "type": "GDExtensionCb"}
		]}
	],
	"interface": [
		{"name": "old_fn", "since": "4.1"},
		{"name": "mem_alloc2", "since": "4.6", "return_value": {"type": "void*"},
			"arguments": [{"name": "p_bytes", "type": "size_t"}]},
		{"name": "new_fn", "since": "4.7"},
		{"name": "gone_fn", "since": "4.1", "deprecated": {"since": "4.5", "replace_with": "old_fn"}}
	]
}'

fn test_c_to_v_primitives() {
	assert c_to_v('uint32_t') == 'u32'
	assert c_to_v('int32_t') == 'int'
	assert c_to_v('size_t') == 'GDSize'
	assert c_to_v('const char*') == '&i8'
	assert c_to_v('char32_t*') == '&u32'
	assert c_to_v('void*') == 'voidptr'
	assert c_to_v('void') == 'void'
}

fn test_c_to_v_wide_char_is_platform_alias() {
	assert c_to_v('const wchar_t*') == '&GDWideChar'
}

fn test_c_to_v_handles() {
	assert c_to_v('GDExtensionConstStringPtr') == '&String'
	assert c_to_v('GDExtensionStringNamePtr') == '&StringName'
	assert c_to_v('GDExtensionVariantPtr') == '&Variant'
	assert c_to_v('GDExtensionObjectPtr') == 'GDExtensionObjectPtr'
}

fn test_c_to_v_pointer_to_variant_array() {
	assert c_to_v('const GDExtensionConstVariantPtr*') == '&&Variant'
	assert c_to_v('const GDExtensionConstTypePtr*') == '&GDExtensionConstTypePtr'
}

fn test_safe_name() {
	assert safe_name('type') == 'type_'
	assert safe_name('string') == 'string_'
	assert safe_name('p_base') == 'p_base'
}

fn test_since_minor() {
	assert since_minor('4.7') == 7
	assert since_minor('') == 0
}

fn test_fn_signature_keeps_names() {
	args := [GDExtArg{'p_a', 'uint8_t'}, GDExtArg{'p_type', 'void*'}]
	assert fn_signature(args, GDExtReturn{'void'}) == 'fn (p_a u8, p_type voidptr)'
	assert fn_signature(args, GDExtReturn{'int32_t'}) == 'fn (p_a u8, p_type voidptr) int'
}

fn test_fn_signature_drops_names_when_incomplete() {
	args := [GDExtArg{'', 'uint8_t'}, GDExtArg{'p_b', 'void*'}]
	assert fn_signature(args, GDExtReturn{}) == 'fn (u8, voidptr)'
}

fn test_deprecation_note() {
	assert deprecation_note(GDExtDeprecated{}) == ''
	note := deprecation_note(GDExtDeprecated{ since: '4.6', replace_with: 'mem_alloc2' })
	assert note == '// Deprecated since 4.6, use mem_alloc2'
}

fn test_new_rejects_unknown_format_version() {
	if _ := InterfaceGen.new('{"format_version": 2, "types": [], "interface": []}', '') {
		assert false
	}
}

fn test_gate_by_since() {
	g := InterfaceGen.new(sample_dump, '')!
	assert g.max_minor == 7
	assert g.gate('') == ''
	assert g.gate('4.5') == ''
	assert g.gate('4.6') == 'godot_4_6 ? || godot_4_7 ?'
	assert g.gate('4.7') == 'godot_4_7 ?'
}

fn test_interface_output() {
	g := InterfaceGen.new(sample_dump, '')!
	out := g.gen_interface()!
	assert out.contains('pub enum GDExtensionInitializationLevel {')
	assert out.contains('pub type GDExtensionCb = fn (p_userdata voidptr, p_type GDExtensionBool)')
	assert out.contains('\ttype_ GDExtensionBool')
	assert out.contains('pub type GDExtensionInterfaceMemAlloc2 = fn (p_bytes GDSize) voidptr')
	assert out.contains('// Deprecated since 4.5, use old_fn')
}

fn test_runtime_gates_new_entry_points() {
	g := InterfaceGen.new(sample_dump, '')!
	out := g.gen_runtime()
	assert out.contains('\$if godot_4_6 ? || godot_4_7 ? {')
	assert out.contains('\$if godot_4_7 ? {')
	assert out.contains('fns.old_fn == unsafe { nil }')
	assert !out.contains('fns.gone_fn == unsafe { nil }')
}

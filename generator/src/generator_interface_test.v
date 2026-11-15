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
	assert c_to_v('int8_t') == 'i8'
	assert c_to_v('uint8_t') == 'u8'
	assert c_to_v('int16_t') == 'i16'
	assert c_to_v('uint16_t') == 'u16'
	assert c_to_v('int64_t') == 'i64'
	assert c_to_v('uint64_t') == 'u64'
	assert c_to_v('size_t') == 'GDSize'
	assert c_to_v('size_t*') == '&GDSize'
	assert c_to_v('float') == 'f32'
	assert c_to_v('double') == 'f64'
	assert c_to_v('char16_t') == 'u16'
	assert c_to_v('const char*') == '&i8'
	assert c_to_v('char32_t*') == '&u32'
	assert c_to_v('void*') == 'voidptr'
	assert c_to_v('void**') == 'voidptr'
	assert c_to_v('void') == 'void'
	assert c_to_v('  float * ') == '&f32'
	assert c_to_v('const  void  *') == 'voidptr'
	assert c_to_v('Something') == 'Something'
	assert smart_v('GDExtensionConstVariantPtr') == '&Variant'
	assert smart_v('GDExtensionConstStringNamePtr') == '&StringName'
	assert smart_v('GDExtensionStringPtr') == '&String'
	assert smart_v('GDExtensionObjectPtr') == ''
	assert base_type('char') == 'i8'
	assert base_type('wchar_t') == 'GDWideChar'
	assert base_type('Unknown') == 'Unknown'
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
	assert safe_name('ok') == 'ok'
}

fn test_enum_names_and_pascal_case() {
	assert enum_value_name('GDExtensionVariantType', 'GDEXTENSION_VARIANT_TYPE_NIL') == 'type_nil'
	assert enum_value_name('GDExtensionVariantType', 'GDEXTENSION_VARIANT_TYPE_PACKED_BYTE_ARRAY') == 'type_packedbytearray'
	assert enum_value_name('GDExtensionVariantOperator', 'GDEXTENSION_VARIANT_OP_ADD') == 'op_add'
	assert enum_value_name('GDExtensionInitializationLevel', 'GDEXTENSION_MAX_INITIALIZATION_LEVEL') == 'gdextension_max_initialization_level'
	assert pascal_case('mem_alloc2') == 'MemAlloc2'
	assert pascal_case('') == ''
	assert pascal_case('_ab') == 'Ab'
	assert interface_type_name('mem_alloc2') == 'GDExtensionInterfaceMemAlloc2'
	assert has_duplicate_values([]) == false
	assert has_duplicate_values([GDExtValue{'a', 1}, GDExtValue{'b', 2}]) == false
	assert has_duplicate_values([GDExtValue{'a', 1}, GDExtValue{'b', 1}])
}

fn test_since_minor() {
	assert since_minor('4.7') == 7
	assert since_minor('4.6.2') == 6
	assert since_minor('4') == 0
	assert since_minor('4.x') == 0
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
	assert fn_signature([]GDExtArg{}, GDExtReturn{}) == 'fn ()'
	assert fn_signature([]GDExtArg{}, GDExtReturn{'void'}) == 'fn ()'
	assert fn_signature([]GDExtArg{}, GDExtReturn{'int32_t'}) == 'fn () int'
	assert fn_signature([GDExtArg{'type', 'uint8_t'}], GDExtReturn{}) == 'fn (type_ u8)'
}

fn test_deprecation_note() {
	assert deprecation_note(GDExtDeprecated{}) == ''
	note := deprecation_note(GDExtDeprecated{ since: '4.6', replace_with: 'mem_alloc2' })
	assert note == '// Deprecated since 4.6, use mem_alloc2'
	full := deprecation_note(GDExtDeprecated{
		since:   '4.6'
		message: 'line\nbreak'
	})
	assert full == '// Deprecated since 4.6. line break'
}

fn test_new_rejects_unknown_format_version() {
	if _ := GeneratorInterface.new('{"format_version": 2, "types": [], "interface": []}', '') {
		assert false
	} else {
		assert err.msg().contains('format_version')
	}
	if _ := GeneratorInterface.new('{"types": [], "interface": []}', '') {
		assert false
	} else {
		assert err.msg().contains('format_version')
	}
	if _ := GeneratorInterface.new('{', '') {
		assert false
	}
}

fn test_gate_by_since() {
	g := GeneratorInterface.new(sample_dump, '')!
	assert g.max_minor == 7
	assert g.gate('') == ''
	assert g.gate('4.5') == ''
	assert g.gate('4.6') == 'godot_4_6 ? || godot_4_7 ?'
	assert g.gate('4.7') == 'godot_4_7 ?'
	assert g.gate('4.0') == ''
	assert g.gate('nope') == ''
	assert g.gate('4.8') == ''
	groups := g.gated_fns()
	keys := g.gate_keys(groups)
	assert keys.len > 0
	assert keys[0] == ''
	assert g.is_function_type('GDExtensionCb')
	assert g.is_function_type('GDExtensionBool') == false
}

fn test_interface_output() {
	g := GeneratorInterface.new(sample_dump, '')!
	out := g.gen_interface()!
	assert out.contains('pub enum GDExtensionInitializationLevel {')
	assert out.contains('pub type GDExtensionCb = fn (p_userdata voidptr, p_type GDExtensionBool)')
	assert out.contains('\ttype_ GDExtensionBool')
	assert out.contains('pub type GDExtensionInterfaceMemAlloc2 = fn (p_bytes GDSize) voidptr')
	assert out.contains('// Deprecated since 4.5, use old_fn')
	assert out.contains('callback GDExtensionCb = unsafe { nil }')
	assert out.contains('\ttype_ GDExtensionBool\n')
}

fn test_version_follows_dump_max_minor() {
	g := GeneratorInterface.new(sample_dump, '')!
	out := g.gen_version()
	assert out.contains('pub const gdextension_interface_format_version = 1')
	assert out.contains('pub const godot_base_minor = 5')
	assert out.contains('\$if godot_4_7 ? {')
	assert out.contains('\$if godot_4_6 ? {')
	assert out.contains('\treturn godot_base_minor')
	assert !out.contains('godot_4_8')
}

fn test_load_gates_new_entry_points() {
	g := GeneratorInterface.new(sample_dump, '')!
	out := g.gen_load()
	assert out.contains('\$if godot_4_6 ? || godot_4_7 ? {')
	assert out.contains('\$if godot_4_7 ? {')
	assert out.contains('fns.mem_alloc2 = unsafe { GDExtensionInterfaceMemAlloc2(fns.gpaddr(c"mem_alloc2")) }')
	assert out.contains('fns.old_fn = unsafe { GDExtensionInterfaceOldFn(fns.gpaddr(c"old_fn")) }')
	assert out.contains("panic('GDExtension interface: missing entry point old_fn")
	assert out.contains('fns.gone_fn = unsafe { GDExtensionInterfaceGoneFn(fns.gpaddr(c"gone_fn")) }')
	assert !out.contains("panic('GDExtension interface: missing entry point gone_fn")
}

fn test_empty_interface_dump_stays_at_base_minor() {
	g := GeneratorInterface.new('{"format_version": 1, "types": [], "interface": []}', '')!
	assert g.max_minor == base_minor
	assert g.gate('4.6') == ''
	out := g.gen_interface()! + g.gen_version() + g.gen_load()
	assert out.contains('pub type GDWideChar = ')
	assert out.contains('pub const godot_base_minor = ${base_minor}')
	assert !out.contains('godot_4_6')
	assert out.contains("panic('GDExtension interface: get_proc_address is null')")
	assert out.contains("panic('GDExtension interface: class library pointer is null')")
}

fn test_gen_interface_rejects_unknown_kind() {
	g := GeneratorInterface.new('{"format_version": 1, "types": [{"name": "Odd", "kind": "union"}], "interface": []}',
		'')!
	if _ := g.gen_interface() {
		assert false
	} else {
		assert err.msg().contains('union')
	}
}

fn test_interface_writes_aliases_handles_and_duplicate_enums() {
	g := GeneratorInterface.new('{
		"format_version": 1,
		"types": [
			{"name": "Dup", "kind": "enum", "values": [
				{"name": "A", "value": 1},
				{"name": "B", "value": 1}
			]},
			{"name": "GDExtensionVariantPtr", "kind": "handle"},
			{"name": "PlainHandle", "kind": "handle"},
			{"name": "OldBool", "kind": "alias", "type": "uint8_t", "deprecated": {
				"since": "4.2", "message": "use bool\\ninstead"
			}},
			{"name": "Box", "kind": "struct", "members": [
				{"name": "next", "type": "char*"},
				{"name": "raw", "type": "void*"},
				{"name": "count", "type": "int32_t"}
			]}
		],
		"interface": []
	}', '')!
	out := g.gen_interface()!
	assert out.contains('@[_allow_multiple_values]')
	assert out.contains('\ta = 1')
	assert out.contains('\tb = 1')
	assert out.contains('pub type PlainHandle = voidptr')
	assert !out.contains('pub type GDExtensionVariantPtr')
	assert out.contains('// Deprecated since 4.2. use bool instead')
	assert out.contains('pub type OldBool = u8')
	assert out.contains('\tnext &i8 = unsafe { nil }')
	assert out.contains('\traw voidptr\n')
	assert out.contains('\tcount int\n')
}

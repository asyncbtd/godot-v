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

import strings

// GenArg is one parameter of a generated method, constructor, or utility function.
struct GenArg {
	name          string
	typ           string
	default_value string
}

// EnumMember is one value of a generated enum.
struct EnumMember {
	name        string
	value       i64
	description string
}

// smart_v maps the handles that are expressed as real V types elsewhere in the
// `godot` module (Variant, StringName, String) to their pointer form. Object
// handles stay opaque: the generated `Object` is a wrapper, not the engine type.
fn smart_v(t string) string {
	return match t {
		'GDExtensionVariantPtr', 'GDExtensionConstVariantPtr' { '&Variant' }
		'GDExtensionStringNamePtr', 'GDExtensionConstStringNamePtr' { '&StringName' }
		'GDExtensionStringPtr', 'GDExtensionConstStringPtr' { '&String' }
		else { '' }
	}
}

// base_type maps a pointer-free C base type to its V equivalent.
fn base_type(t string) string {
	s := smart_v(t)
	if s != '' {
		return s
	}
	return match t {
		'char' { 'i8' }
		'char16_t' { 'u16' }
		'char32_t' { 'u32' }
		'wchar_t' { 'GDWideChar' }
		'int8_t' { 'i8' }
		'uint8_t' { 'u8' }
		'int16_t' { 'i16' }
		'uint16_t' { 'u16' }
		'int32_t' { 'int' }
		'uint32_t' { 'u32' }
		'int64_t' { 'i64' }
		'uint64_t' { 'u64' }
		'size_t' { 'GDSize' }
		'float' { 'f32' }
		'double' { 'f64' }
		'void' { 'void' }
		else { t }
	}
}

// c_to_v converts a C type string from the dump into a V type.
fn c_to_v(t string) string {
	mut typ := t.trim_space().replace('const ', '')
	mut ptrs := 0
	for typ.ends_with('*') {
		ptrs++
		typ = typ[..typ.len - 1].trim_space()
	}
	base := base_type(typ)
	if base == 'void' {
		return if ptrs > 0 { 'voidptr' } else { 'void' }
	}
	return '&'.repeat(ptrs) + base
}

// enum_value_name converts a GDEXTENSION_* value name to its V enum value.
fn enum_value_name(enum_name string, val string) string {
	match enum_name {
		'GDExtensionVariantType' {
			s := val.replace('GDEXTENSION_VARIANT_TYPE_', '').replace('_', '').to_lower()
			return 'type_' + s
		}
		'GDExtensionVariantOperator' {
			s := val.replace('GDEXTENSION_VARIANT_OP_', '').to_lower()
			return 'op_' + s
		}
		else {
			return val.to_lower()
		}
	}
}

// pascal_case converts snake_case to PascalCase for interface type names.
fn pascal_case(s string) string {
	mut parts := s.split('_')
	for i, p in parts {
		if p.len > 0 {
			parts[i] = p[0..1].to_upper() + p[1..]
		}
	}
	return parts.join('')
}

// safe_name appends `_` when the identifier is a V keyword.
fn safe_name(name string) string {
	return if name in keywords { '${name}_' } else { name }
}

// since_minor reads the minor number of a `4.N` version string.
fn since_minor(since string) int {
	parts := since.split('.')
	if parts.len < 2 {
		return 0
	}
	return parts[1].int()
}

// deprecation_note renders a deprecation comment, empty when not deprecated.
fn deprecation_note(d GDExtDeprecated) string {
	if d.since == '' {
		return ''
	}
	mut s := '// Deprecated since ${d.since}'
	if d.replace_with != '' {
		s += ', use ${d.replace_with}'
	}
	if d.message != '' {
		s += '. ${d.message.replace('\n', ' ')}'
	}
	return s
}

// write_note writes the deprecation comment of a declaration, if any.
fn write_note(mut buf strings.Builder, d GDExtDeprecated) {
	note := deprecation_note(d)
	if note != '' {
		buf.writeln(note)
	}
}

// fn_signature renders `fn (args) ret`. Parameter names are kept when the dump
// names every parameter, so user callbacks stay readable.
fn fn_signature(args []GDExtArg, ret GDExtReturn) string {
	named := args.len > 0 && args.all(it.name != '')
	mut params := []string{cap: args.len}
	for a in args {
		typ := c_to_v(a.typ)
		params << if named { '${safe_name(a.name)} ${typ}' } else { typ }
	}
	sig := 'fn (${params.join(', ')})'
	if ret.typ != '' && ret.typ != 'void' {
		return '${sig} ${c_to_v(ret.typ)}'
	}
	return sig
}

fn interface_type_name(name string) string {
	return 'GDExtensionInterface' + pascal_case(name)
}

// write_enum writes one V enum. Duplicate values are dropped when skip_duplicates is set.
fn write_enum(mut buf strings.Builder, name string, as_type string, members []EnumMember, skip_duplicates bool) {
	if as_type == '' {
		buf.writeln('pub enum ${name} {')
	} else {
		buf.writeln('pub enum ${name} as ${as_type} {')
	}
	mut seen := []i64{}
	for m in members {
		if skip_duplicates && m.value in seen {
			continue
		}
		seen << m.value
		buf.write_string(docstring(m.description, before: '\t', after: '\n'))
		buf.writeln('\t${m.name} = ${m.value}')
	}
	buf.writeln('}')
}

// from_api copies constructor and signal arguments into GenArg.
fn from_api(args []APIArg) []GenArg {
	mut out := []GenArg{cap: args.len}
	for arg in args {
		out << GenArg{
			name: arg.name
			typ:  arg.type
		}
	}
	return out
}

// arg_v_type is the V type of a parameter. Variant arrives as ToVariant.
fn arg_v_type(typ string) string {
	if typ == 'Variant' {
		return 'ToVariant'
	}
	return convert_strings(convert_type(typ))
}

// write_optional_cfg writes the `@[params]` struct of a method that has defaults.
fn write_optional_cfg(mut buf strings.Builder, owner string, method_name string, args []GenArg, noted bool) {
	if !args.any(it.default_value != '') {
		return
	}
	buf.writeln('')
	if noted {
		buf.writeln('// Optional parameters for ${owner}#${method_name}')
	}
	buf.writeln('@[params]')
	buf.writeln('pub struct ${owner}_${method_name}_Cfg {')
	buf.writeln('pub:')
	for arg in args {
		if arg.default_value == '' {
			continue
		}
		field_name := convert_name(arg.name)
		field_value := if val := convert_dumb_value(arg.typ, arg.default_value) {
			' = ${val}'
		} else {
			''
		}
		buf.writeln('\t${field_name} ${arg_v_type(arg.typ)}${field_value}')
	}
	buf.writeln('}')
}

// write_required_params writes the required parameters of a method signature.
// The returned flag is true when every parameter has a default.
fn write_required_params(mut buf strings.Builder, args []GenArg) bool {
	mut first_arg_optional := true
	for a, arg in args {
		if arg.default_value != '' {
			continue
		}
		first_arg_optional = false
		if a != 0 {
			buf.write_string(', ')
		}
		name := convert_name(arg.name)
		if arg.typ == 'Variant' {
			buf.write_string('${name}_ ToVariant')
		} else {
			buf.write_string('${name} ${arg_v_type(arg.typ)}')
		}
	}
	return first_arg_optional
}

// write_const_getter writes a module constant and the inline getter of a class.
fn write_const_getter(mut buf strings.Builder, description string, const_name string, value string, owner string, getter string, ret string) {
	doc := docstring(description, prefix: '|')
	buf.writeln('
		${doc}
		|pub const ${const_name} = ${value}
		|
		${doc}
		|@[inline]
		|pub fn ${owner}.${getter}() ${ret} {
		|	return ${const_name}
		|}
	'.strip_margin().trim_right('\n'))
}

// api_enum_name prefixes an enum with its class and, when asked, avoids interface names.
fn api_enum_name(owner string, name string, clash bool) string {
	mut enum_name := name
	if !name.starts_with(owner) {
		enum_name = '${owner}${name}'
	}
	if clash {
		return avoid_interface_clash(enum_name)
	}
	return enum_name
}

// write_call_args writes the `args []voidptr` setup of a method or constructor.
// where is `Class#method`, printed when a vararg kind is not lowered yet.
fn write_call_args(mut buf strings.Builder, args []GenArg, class_names []string, has_optionals bool, is_vararg bool, where string) {
	if is_vararg {
		buf.writeln('\ttotal_args := ${args.len} + varargs.len')
		buf.writeln('\tmut args := []voidptr{cap: total_args}')
	} else if args.len > 0 {
		buf.writeln('\tmut args := []voidptr{cap: ${args.len}}')
	}
	for a, arg in args {
		name := convert_name(arg.name)
		mut name_prefix := if has_optionals && arg.default_value != '' { 'cfg.' } else { '' }
		name_suffix := if arg.typ == 'Variant' && name_prefix != '' { '' } else { '_' }
		if arg.typ == 'Variant' {
			buf.writeln('\t${name} := ${name_prefix}${name}${name_suffix}.to_variant()')
			name_prefix = ''
		}
		match true {
			arg.typ in strings {
				buf.writeln('\targ${a} := ${arg.typ}.new(${name_prefix}${name})')
				buf.writeln('\tdefer { arg${a}.deinit() }')
				if is_vararg {
					buf.writeln('\targ${a}_var := arg${a}.to_variant()')
					buf.writeln('\tdefer { arg${a}_var.deinit() }')
					buf.writeln('\targs << &arg${a}_var')
				} else {
					buf.writeln('\targs << &arg${a}')
				}
			}
			convert_type(arg.typ) in class_names {
				buf.writeln('\targ${a} := ${name_prefix}${name}.ptr')
				if is_vararg {
					println('TODO: varargs for classes: ${where}')
				}
				buf.writeln('\targs << &arg${a}')
			}
			arg.typ.starts_with('enum::') || arg.typ.starts_with('bitfield::') {
				buf.writeln('\ti64_${name} := i64(${name_prefix}${name})')
				buf.writeln('\targs << &i64_${name}')
				if is_vararg {
					println('TODO: varargs for enums: ${where}')
				}
			}
			else {
				buf.writeln('\targs << unsafe{&${name_prefix}${name}}')
				if is_vararg {
					println('TODO: varargs for else: ${where}')
				}
			}
		}
	}
	if is_vararg {
		buf.writeln('\tmut vararg_values := []Variant{len: varargs.len}')
		buf.writeln('\tfor i in 0 .. varargs.len {')
		buf.writeln('\t\tvararg_values[i] = varargs[i].to_variant()')
		buf.writeln('\t\targs << unsafe { &vararg_values[i] }')
		buf.writeln('\t}')
		buf.writeln('\tdefer {')
		buf.writeln('\t\tfor mut item in vararg_values {')
		buf.writeln('\t\t\titem.deinit()')
		buf.writeln('\t\t}')
		buf.writeln('\t}')
	}
}

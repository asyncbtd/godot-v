// Adapted from gdext-v (https://github.com/rawsp33d/gdext-v).
// Copyright (c) 2025 Ross Hadden
//
// Modifications Copyright 2026 Timofey Brukhanchik
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

module generator

import os
import strings

fn (mut g GeneratorAPI) gen_builtin_classes() ! {
	for class in g.api.builtin_classes {
		if class.name.is_lower() {
			continue
		}
		mut buf := strings.new_builder(1024)
		buf.writeln('module godot')
		write_builtin_enums(mut buf, class)
		g.write_builtin_struct(mut buf, class)
		write_builtin_constants(mut buf, class)
		g.write_builtin_constructors(mut buf, class)
		write_builtin_destructor(mut buf, class)
		g.write_builtin_methods(mut buf, class)
		write_builtin_variants(mut buf, class)
		write_builtin_index(mut buf, class)
		gen_operators(mut buf, convert_type(class.name), class.operators)
		mut f := os.create(g.file('_${class.name}.v'))!
		defer { f.close() }
		f.write(buf)!
	}
}

fn write_builtin_enums(mut buf strings.Builder, class APIBuiltinClass) {
	owner := convert_type(class.name)
	for enm in class.enums {
		mut members := []EnumMember{cap: enm.values.len}
		for val in enm.values {
			members << EnumMember{
				name:        val.name.to_lower()
				value:       val.value
				description: val.description
			}
		}
		buf.writeln('')
		write_enum(mut buf, api_enum_name(owner, enm.name, false), 'i64', members, true)
	}
}

fn (g &GeneratorAPI) write_builtin_struct(mut buf strings.Builder, class APIBuiltinClass) {
	buf.writeln('')
	buf.write_string(docstring(class.brief_description, after: '\n//\n'))
	buf.write_string(docstring(class.description, after: '\n'))
	buf.writeln('@[packed]')
	buf.writeln('pub struct ${class.name} {')
	mut defined_size := 0
	if offsets := g.api.builtin_class_member_offsets[g.layout_index()].classes.filter(it.name == class.name)[0] {
		sorted_mem := offsets.members.sorted(a.offset < b.offset)
		buf.writeln('pub mut:')
		for m, mem in sorted_mem {
			buf.write_string(docstring(class.members[m].description, before: '\t', after: '\n'))
			if mem.meta in ['int32', 'float'] {
				defined_size += 4
			} else {
				defined_size += g.api.builtin_class_sizes[g.layout_index()].sizes.filter(it.name == mem.meta).first().size
			}
			if mem.meta == 'float' {
				buf.writeln('\t${mem.member} f32 // offset ${mem.offset}')
			} else {
				buf.writeln('\t${mem.member} ${convert_type(mem.meta)} // offset ${mem.offset}')
			}
		}
	}
	class_size := g.api.builtin_class_sizes[g.layout_index()].sizes.filter(it.name == class.name).first().size
	if defined_size < class_size {
		buf.writeln('\tdata_ [${class_size - defined_size}]u8')
	}
	if defined_size > class_size {
		println('${class.name} defined size ${defined_size} does not match class size ${class_size}')
	}
	buf.writeln('}')
}

fn write_builtin_constants(mut buf strings.Builder, class APIBuiltinClass) {
	for constant in class.constants {
		const_name := '${class.name.to_lower()}_${convert_name(constant.name)}'
		value := convert_dumb_value(class.name, constant.value) or { 'none' }
		write_const_getter(mut buf, constant.description, const_name, value, class.name,
			convert_name(constant.name), constant.type)
	}
}

fn (g &GeneratorAPI) write_builtin_constructors(mut buf strings.Builder, class APIBuiltinClass) {
	for method in class.constructors {
		args := from_api(method.arguments)
		buf.writeln('')
		buf.write_string(docstring(method.description, after: '\n'))
		buf.write_string('pub fn ${class.name}.new${method.index}(')
		write_required_params(mut buf, args)
		buf.writeln(') ${class.name} {')
		buf.writeln('\tmut inst := ${class.name}{}')
		buf.writeln('\tconstructor := gdf.variant_get_ptr_constructor(GDExtensionVariantType.type_${class.name.to_lower()}, ${method.index})')
		write_call_args(mut buf, args, g.class_names, false, false, '')
		arg_ptr := if args.len > 0 { 'unsafe { &args[0] }' } else { 'unsafe{nil}' }
		buf.writeln('\tconstructor(voidptr(&inst), ${arg_ptr})')
		buf.writeln('\treturn inst')
		buf.writeln('}')
	}
}

fn write_builtin_destructor(mut buf strings.Builder, class APIBuiltinClass) {
	if !class.has_destructor {
		return
	}
	buf.writeln('
		|pub fn (s &${class.name}) deinit() {
		|	destructor := gdf.variant_get_ptr_destructor(GDExtensionVariantType.type_${class.name.to_lower()})
		|	destructor(voidptr(s))
		|}
	'.strip_margin().trim_right('\n'))
}

fn (mut g GeneratorAPI) write_builtin_methods(mut buf strings.Builder, class APIBuiltinClass) {
	for method in class.methods {
		mut args := []GenArg{cap: method.arguments.len}
		for arg in method.arguments {
			args << GenArg{
				name:          arg.name
				typ:           arg.type
				default_value: arg.default_value
			}
		}
		g.write_builtin_method(mut buf, class.name, method.name, method.description, method.return_type,
			method.is_static, method.is_vararg, method.hash, args)
	}
}

fn (mut g GeneratorAPI) write_builtin_method(mut buf strings.Builder, class_name string, raw_name string, description string, raw_return string, is_static bool, is_vararg bool, hash u64, args []GenArg) {
	has_args := args.len > 0
	has_return := raw_return != ''
	return_type := convert_type(raw_return)
	method_name := convert_name(raw_name)
	has_optionals := args.any(it.default_value != '')
	ptr := match true {
		is_static { 'unsafe{nil}' }
		class_name in g.class_names { 's.ptr' }
		else { 'voidptr(s)' }
	}
	write_optional_cfg(mut buf, class_name, method_name, args, false)
	buf.writeln('')
	buf.write_string(docstring(description, after: '\n'))
	if is_static {
		buf.write_string('pub fn ${class_name}.${method_name}(')
	} else {
		buf.write_string('pub fn (s &${class_name}) ${method_name}(')
	}
	first_arg_optional := write_required_params(mut buf, args)
	if is_vararg {
		if has_args {
			buf.write_string(', ')
		}
		buf.write_string('varargs ...ToVariant')
	}
	if has_optionals {
		if !first_arg_optional {
			buf.write_string(', ')
		}
		buf.write_string('cfg ${class_name}_${method_name}_Cfg')
	}
	if has_return {
		buf.writeln(') ${return_type} {')
	} else {
		buf.writeln(') {')
	}
	buf.writeln("\tf := builtin_method_bind(${g.builtin_bind}, GDExtensionVariantType.type_${class_name.to_lower()}, '${raw_name}', i64(${hash}))")
	g.builtin_bind++
	write_call_args(mut buf, args, g.class_names, has_optionals, is_vararg, '${class_name}#${raw_name}')
	arg_ptr := match true {
		has_args || is_vararg { 'unsafe { &args[0] }' }
		else { 'unsafe{ nil }' }
	}
	ret_ptr := if has_return { 'voidptr(&result)' } else { 'unsafe{ nil }' }
	if has_return {
		buf.writeln('\tmut result := ${convert_return(return_type, raw_return, g.enum_defaults)}')
	}
	if is_vararg {
		buf.writeln('
			|	if total_args > 0 {
			|		f(${ptr}, ${arg_ptr}, ${ret_ptr}, total_args)
			|	} else {
			|		f(${ptr}, unsafe { nil }, ${ret_ptr}, total_args)
			|	}
		'.strip_margin().trim_right('\n'))
	} else {
		buf.writeln('\tf(${ptr}, ${arg_ptr}, ${ret_ptr}, ${args.len})')
	}
	if has_return {
		buf.writeln('\treturn result')
	}
	buf.writeln('}')
}

fn write_builtin_variants(mut buf strings.Builder, class APIBuiltinClass) {
	buf.writeln('
		|pub fn (s &${class.name}) to_variant() Variant {
		|	to_variant := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_${class.name.to_lower()})
		|	result := Variant{}
		|	to_variant(GDExtensionUninitializedVariantPtr(&result), GDExtensionTypePtr(s))
		|	return result
		|}
	'.strip_margin().trim_right('\n'))
	buf.writeln('
		|pub fn (mut s ${class.name}) from_variant(variant &Variant) {
		|	variant_to_type := gdf.get_variant_to_type_constructor(GDExtensionVariantType.type_${class.name.to_lower()})
		|	variant_to_type(voidptr(&s), variant)
		|}
	'.strip_margin().trim_right('\n'))
	buf.writeln('
		|pub fn ${class.name}.from_variant(variant &Variant) ${class.name} {
		|	mut s := ${class.name}{}
		|	variant_to_type := gdf.get_variant_to_type_constructor(GDExtensionVariantType.type_${class.name.to_lower()})
		|	variant_to_type(voidptr(&s), variant)
		|	return s
		|}
	'.strip_margin().trim_right('\n'))
}

fn write_builtin_index(mut buf strings.Builder, class APIBuiltinClass) {
	if class.indexing_return_type == '' {
		return
	}
	if class.is_keyed {
		write_builtin_keyed(mut buf, class.name)
		return
	}
	return_type := convert_type(class.indexing_return_type)
	buf.writeln('')
	buf.writeln('pub fn (v &${class.name}) index(i i64) ${return_type} {')
	buf.writeln('\tindex_fn := gdf.variant_get_ptr_indexed_getter(GDExtensionVariantType.type_${class.name.to_lower()})')
	if return_type in numbers {
		buf.writeln('\tmut result := ${return_type}(0)')
	} else {
		buf.writeln('\tmut result := ${return_type}{}')
	}
	buf.writeln('\tindex_fn(GDExtensionConstTypePtr(v), GDExtensionInt(i), GDExtensionTypePtr(&result))')
	buf.writeln('\treturn result')
	buf.writeln('}')
}

fn write_builtin_keyed(mut buf strings.Builder, class_name string) {
	buf.writeln('
		|pub fn (v &${class_name}) index_get(i &Variant) ?Variant {
		|	as_var := v.to_variant()
		|	ret := Variant{}
		|	suc := GDExtensionBool(false)
		|	gdf.variant_get(&as_var, i, voidptr(&ret), &suc)
		|	if suc != GDExtensionBool(true) {
		|		return none
		|	}
		|	return ret
		|}
	'.strip_margin().trim_right('\n'))
	buf.writeln('
		|pub fn (v &${class_name}) index_get_named(sn &StringName) ?Variant {
		|	as_var := v.to_variant()
		|	ret := Variant{}
		|	suc := GDExtensionBool(false)
		|	gdf.variant_get_named(&as_var, sn, voidptr(&ret), &suc)
		|	if suc != GDExtensionBool(true) {
		|		return none
		|	}
		|	return ret
		|}
	'.strip_margin().trim_right('\n'))
	buf.writeln('
		|pub fn (v &${class_name}) index_get_keyed(i &Variant) ?Variant {
		|	as_var := v.to_variant()
		|	ret := Variant{}
		|	suc := GDExtensionBool(false)
		|	gdf.variant_get_keyed(&as_var, i, voidptr(&ret), &suc)
		|	if suc != GDExtensionBool(true) {
		|		return none
		|	}
		|	return ret
		|}
	'.strip_margin().trim_right('\n'))
	buf.writeln('
		|pub fn (v &${class_name}) index_set(key &Variant, value &Variant) ! {
		|	as_var := v.to_variant()
		|	suc := GDExtensionBool(false)
		|	gdf.variant_set(&as_var, key, value, &suc)
		|	if suc != GDExtensionBool(true) {
		|		return error("invalid set on ${class_name}")
		|	}
		|}
	'.strip_margin().trim_right('\n'))
	buf.writeln('
		|pub fn (v &${class_name}) index_set_named(key &StringName, value &Variant) ! {
		|	as_var := v.to_variant()
		|	suc := GDExtensionBool(false)
		|	gdf.variant_set_named(&as_var, key, value, &suc)
		|	if suc != GDExtensionBool(true) {
		|		return error("invalid set_named on ${class_name}")
		|	}
		|}
	'.strip_margin().trim_right('\n'))
	buf.writeln('
		|pub fn (v &${class_name}) index_set_keyed(key &Variant, value &Variant) ! {
		|	as_var := v.to_variant()
		|	suc := GDExtensionBool(false)
		|	gdf.variant_set_keyed(&as_var, key, value, &suc)
		|	if suc != GDExtensionBool(true) {
		|		return error("invalid set_keyed on ${class_name}")
		|	}
		|}
	'.strip_margin().trim_right('\n'))
}

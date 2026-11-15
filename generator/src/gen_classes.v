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

fn (mut g GeneratorAPI) gen_classes() ! {
	for class in g.api.classes {
		mut buf := strings.new_builder(1024)
		buf.writeln('module godot')
		write_class_enums(mut buf, class)
		write_class_struct(mut buf, class)
		write_class_constants(mut buf, class)
		write_class_constructor(mut buf, class)
		g.write_class_singleton(mut buf, class)
		write_class_signals(mut buf, class)
		write_class_variants(mut buf, class)
		g.write_class_methods(mut buf, class)
		write_class_properties(mut buf, class)
		mut f := os.create(g.file('_${class.name}.v'))!
		defer { f.close() }
		f.write(buf)!
	}
}

fn write_class_enums(mut buf strings.Builder, class APIClass) {
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
		write_enum(mut buf, api_enum_name(class.name, enm.name, true), 'i64', members, true)
	}
}

fn write_class_struct(mut buf strings.Builder, class APIClass) {
	buf.writeln('')
	buf.write_string(docstring(class.brief_description, after: '\n//\n'))
	buf.writeln('pub struct ${class.name} {')
	if class.inherits == '' {
		buf.writeln('pub mut:')
		buf.writeln('\tptr voidptr = unsafe{nil}')
	} else {
		buf.writeln('\t${convert_type(class.inherits)}')
	}
	buf.writeln('}')
}

fn write_class_constants(mut buf strings.Builder, class APIClass) {
	for constant in class.constants {
		const_name := '${class.name.to_lower()}_${convert_name(constant.name)}'
		write_const_getter(mut buf, constant.description, const_name, '${constant.value}',
			class.name, convert_name(constant.name), 'int')
	}
}

fn write_class_constructor(mut buf strings.Builder, class APIClass) {
	if !class.is_instantiable {
		return
	}
	buf.writeln("
		|pub fn ${class.name}.new() ${class.name} {
		|	variant := ClassDB.singleton().instantiate('${class.name}')
		|	mut result := ${class.name}{}
		|	result.from_variant(variant)
		|	return result
		|}
	".strip_margin().trim_right('\n'))
}

fn (g &GeneratorAPI) write_class_singleton(mut buf strings.Builder, class APIClass) {
	if g.api.singletons.filter(it.type == class.name).len == 0 {
		return
	}
	buf.writeln("
		|pub fn ${class.name}.singleton() ${class.name} {
		|	sn := StringName.new('${class.name}')
		|	defer { sn.deinit() }
		|	result := ${class.name}{
		|		ptr: gdf.global_get_singleton(sn)
		|	}
		|	return result
		|}
	".strip_margin().trim_right('\n'))
}

fn write_class_signals(mut buf strings.Builder, class APIClass) {
	for signal in class.signals {
		doc := docstring(signal.description, prefix: '|')
		_, sig_name := signature(signal.arguments, strip_names: true)
		method_name := convert_name(signal.name)
		buf.writeln('
			${doc}
			|pub fn (s &${class.name}) ${method_name}() &VSignal[${sig_name}] {
			|	signal := Signal.new2(s.obj(), "${signal.name}")
			|	return &VSignal[${sig_name}]{signal}
			|}
		'.strip_margin().trim_right('\n'))
		buf.writeln('')
		buf.writeln('pub fn (s &${class.name}) connect_${method_name}(cb Callable, cfg Signal_connect_Cfg) i64 {')
		buf.writeln('\treturn s.${method_name}().connect(cb, cfg)')
		buf.writeln('}')
		write_emit(mut buf, class.name, method_name, signal.arguments)
	}
}

fn write_class_variants(mut buf strings.Builder, class APIClass) {
	buf.writeln('
		|pub fn (s &${class.name}) to_variant() Variant {
		|	if s.ptr == unsafe{nil} { return Variant{} }
		|	to_variant := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_object)
		|	result := Variant{}
		|	to_variant(GDExtensionUninitializedVariantPtr(&result), s.ptr)
		|	return result
		|}
	'.strip_margin().trim_right('\n'))
	buf.writeln('
		|pub fn (mut s ${class.name}) from_variant(variant &Variant) {
		|	variant_to_type := gdf.get_variant_to_type_constructor(GDExtensionVariantType.type_object)
		|	variant_to_type(voidptr(&s.ptr), variant)
		|}
	'.strip_margin().trim_right('\n'))
	buf.writeln('
		|pub fn ${class.name}.from_variant(variant &Variant) ${class.name} {
		|	mut s := ${class.name}{}
		|	variant_to_type := gdf.get_variant_to_type_constructor(GDExtensionVariantType.type_object)
		|	variant_to_type(voidptr(&s.ptr), variant)
		|	return s
		|}
	'.strip_margin().trim_right('\n'))
}

fn (mut g GeneratorAPI) write_class_methods(mut buf strings.Builder, class APIClass) {
	for method in class.methods {
		mut args := []GenArg{cap: method.arguments.len}
		for arg in method.arguments {
			args << GenArg{
				name:          arg.name
				typ:           arg.type
				default_value: arg.default_value
			}
		}
		g.write_class_method(mut buf, class.name, method.name, method.description, method.return_value.type,
			method.is_static, method.is_vararg, method.is_virtual, method.hash, args)
	}
}

fn (mut g GeneratorAPI) write_class_method(mut buf strings.Builder, class_name string, raw_name string, description string, raw_return string, is_static bool, is_vararg bool, is_virtual bool, hash u64, args []GenArg) {
	has_args := args.len > 0
	has_return := raw_return != ''
	return_type := convert_type(raw_return)
	method_name := convert_name(raw_name)
	has_optionals := args.any(it.default_value != '')
	ptr := match true {
		is_static { 'unsafe { nil }' }
		class_name in g.class_names { 's.ptr' }
		else { 'voidptr(s)' }
	}
	if is_virtual {
		write_virtual_interface(mut buf, class_name, raw_name, return_type, has_return, args)
	}
	write_optional_cfg(mut buf, class_name, method_name, args, true)
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
		buf.writeln(') ${convert_strings(return_type)} {')
	} else {
		buf.writeln(') {')
	}
	buf.writeln("\tmb := class_method_bind(${g.class_bind}, '${class_name}', '${raw_name}', i64(${hash}))")
	g.class_bind++
	write_call_args(mut buf, args, g.class_names, has_optionals, is_vararg, '${class_name}#${raw_name}')
	arg_ptr := if has_args { 'unsafe { &args[0] }' } else { 'unsafe{nil}' }
	ret_ptr := if has_return { 'voidptr(&result)' } else { 'unsafe{nil}' }
	if has_return {
		buf.writeln('\tmut result := ${convert_return(return_type, raw_return, g.enum_defaults)}')
	}
	if is_vararg {
		buf.writeln('\tmut err := GDExtensionCallError{}')
		buf.writeln('\tvariant_args := unsafe { &&Variant(if args.len > 0 { voidptr(&args[0]) } else { nil }) }')
		buf.writeln('\tgdf.object_method_bind_call(mb, ${ptr}, variant_args, total_args, ${ret_ptr}, &err)')
	} else {
		buf.writeln('\tgdf.object_method_bind_ptrcall(mb, ${ptr}, ${arg_ptr}, ${ret_ptr})')
	}
	if has_return {
		match true {
			raw_return in strings {
				buf.writeln('\tresult_v := result.to_v()')
				buf.writeln('\tdefer { result.deinit() }')
				buf.writeln('\treturn result_v')
			}
			raw_return.starts_with('enum::') || raw_return.starts_with('bitfield::') {
				buf.writeln('\treturn unsafe{${return_type}(result)}')
			}
			else {
				buf.writeln('\treturn result')
			}
		}
	}
	buf.writeln('}')
}

fn write_virtual_interface(mut buf strings.Builder, class_name string, raw_name string, return_type string, has_return bool, args []GenArg) {
	buf.writeln('')
	buf.writeln('pub interface ${interface_name(.virtual, class_name, raw_name)} {')
	buf.writeln('mut:')
	buf.write_string('\t${convert_name(raw_name[1..])}_(')
	for i, arg in args {
		if i != 0 {
			buf.write_string(', ')
		}
		buf.write_string('${convert_name(arg.name)} ${convert_type(arg.typ)}')
	}
	if has_return {
		buf.writeln(') ${return_type}')
	} else {
		buf.writeln(')')
	}
	buf.writeln('}')
}

fn write_class_properties(mut buf strings.Builder, class APIClass) {
	mut method_names := map[string]bool{}
	for method in class.methods {
		method_names[convert_name(method.name)] = true
	}
	for prop in class.properties {
		prop_name := convert_name(prop.name)
		getter := convert_name(prop.getter)
		if getter !in method_names || prop_name in method_names {
			continue
		}
		ret := convert_strings(convert_type(prop.type))
		buf.writeln('')
		buf.writeln('pub fn (s &${class.name}) ${prop_name}() ${ret} {')
		buf.writeln('\treturn s.${getter}()')
		buf.writeln('}')
		setter := convert_name(prop.setter)
		set_name := 'set_${prop_name}'
		if prop.setter != '' && setter in method_names && set_name !in method_names && set_name != setter {
			buf.writeln('')
			buf.writeln('pub fn (s &${class.name}) ${set_name}(value ${ret}) {')
			buf.writeln('\ts.${setter}(value)')
			buf.writeln('}')
		}
	}
}

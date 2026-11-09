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

import json2
import os
import strings
import time
import v.vmod

pub struct Generator {
	api     API @[required]
	out_dir string
mut:
	class_names   []string
	builtin_names []string
	enum_defaults map[string]string
	class_bind    int
	builtin_bind  int
	utility_bind  int
}

fn (g &Generator) layout_index() int {
	bits := if sizeof(voidptr) == 8 { '64' } else { '32' }
	precision := if g.api.header.precision == 'double' { 'double' } else { 'float' }
	name := '${precision}_${bits}'
	for i, row in g.api.builtin_class_sizes {
		if row.build_configuration == name {
			return i
		}
	}
	panic('missing builtin layout ${name}')
}

// Generator.new decodes an extension API dump into a generator.
pub fn Generator.new(api_dump string, out_dir string) Generator {
	api := json2.decode[API](api_dump) or { panic('Failed to parse API dump JSON: ${err}') }

	return Generator{
		api:     api
		out_dir: out_dir
	}
}

fn (g &Generator) file(name string) string {
	return os.join_path(g.out_dir, name)
}

// run writes the V bindings for the decoded API.
pub fn (mut g Generator) run() ! {
	g.setup()

	g.gen_gdext_info()!
	g.gen_functions()!
	g.gen_enums()!
	g.gen_signals()!
	g.gen_builtin_classes()!
	g.gen_classes()!
	g.gen_structs()!
	g.gen_bind_counts()!
}

fn (g &Generator) gen_bind_counts() ! {
	os.write_file(g.file('__bind_count.v'), "
		|module godot
		|
		|const class_bind_count = ${g.class_bind}
		|const builtin_bind_count = ${g.builtin_bind}
		|const utility_bind_count = ${g.utility_bind}
	".strip_margin().trim_space())!
}

// makes useful mappings
// - populate class names
// - populate enum defaults with the first value of each enum
fn (mut g Generator) setup() {
	for enm in g.api.global_enums {
		name := convert_type(enm.name)
		g.enum_defaults[name] = convert_name(enm.values.first().name)
	}
	for class in g.api.classes {
		g.class_names << convert_type(class.name)
		for class_enum in class.enums {
			// strip prefix if redundant
			key := if class_enum.name.starts_with(class.name) {
				class_enum.name
			} else {
				'${class.name}${class_enum.name}'
			}
			g.enum_defaults[key] = convert_name(class_enum.values.first().name)
		}
	}
	for class in g.api.builtin_classes {
		g.builtin_names << convert_type(class.name)
		for class_enum in class.enums {
			// strip prefix if redundant
			key := if class_enum.name.starts_with(class.name) {
				class_enum.name
			} else {
				'${class.name}${class_enum.name}'
			}
			g.enum_defaults[key] = convert_name(class_enum.values.first().name)
		}
	}
}

fn (g &Generator) gen_gdext_info() ! {
	mut buf := strings.new_builder(1024)
	manifest_path := os.join_path(os.dir(g.out_dir), 'v.mod')
	manifest_text := os.read_file(manifest_path) or { panic(err) }
	mod := vmod.decode(manifest_text) or { panic(err) }
	version := mod.version.split('.')
	buf.writeln("
		|module godot
		|
		|import time
		|
		|pub fn (g GDExt) info() Info {
		|	return Info{
		|		version: InfoVersion{
		|			name:        '${mod.name}'
		|			description: '${mod.description}'
		|			major:       ${version[0].int()}
		|			minor:       ${version[1].int()}
		|			patch:       ${version[2].int()}
		|			full:        'v${mod.version}'
		|			time:        time.unix(${time.now().unix()})
		|		}
		|		godot: InfoVersion{
		|			name:        'Godot Engine'
		|			description: 'Multi-platform 2D and 3D game engine'
		|			major:       ${g.api.header.version_major}
		|			minor:       ${g.api.header.version_minor}
		|			patch:       ${g.api.header.version_patch}
		|			full:        '${g.api.header.version_full_name}'
		|			status:      '${g.api.header.version_status}'
		|			build:       '${g.api.header.version_build}'
		|		}
		|	}
		|}
	".strip_margin().trim('\n'))

	mut f := os.create(g.file('__info.v'))!
	defer { f.close() }
	f.write(buf)!
}

fn (mut g Generator) gen_functions() ! {
	mut buf := strings.new_builder(1024)
	buf.writeln('module godot')

	for method in g.api.utility_functions {
		has_args := method.arguments.len > 0
		has_return := method.return_type != ''
		return_type := convert_type(method.return_type)
		method_name := convert_name(method.name)

		// fn def
		buf.writeln('')
		buf.write_string(docstring(method.description, after: '\n'))
		buf.write_string('pub fn ${method_name}(')

		// args
		for a, arg in method.arguments {
			if a != 0 {
				buf.write_string(', ')
			}
			if arg.type == 'Variant' {
				buf.write_string('${convert_name(arg.name)}_ ToVariant')
			} else {
				buf.write_string('${convert_name(arg.name)} ${convert_type(arg.type)}')
			}
		}
		// varargs get tacked on to the end
		if method.is_vararg {
			if method.arguments.len > 0 {
				buf.write_string(', ')
			}
			buf.write_string('varargs ...ToVariant')
		}

		// return signature
		if has_return {
			buf.writeln(') ${return_type} {')
		} else {
			buf.writeln(') {')
		}

		// body
		if has_return {
			buf.writeln('\tmut result := ${convert_return(return_type, method.return_type, g.enum_defaults)}')
		}
		buf.writeln("\tf := utility_function(${g.utility_bind}, '${method.name}', i64(${method.hash}))")
		g.utility_bind++

		// Variant -> ToVariant
		for arg in method.arguments {
			if arg.type == 'Variant' {
				buf.writeln('\t${convert_name(arg.name)} := ${convert_name(arg.name)}_.to_variant()')
			}
		}

		// args
		if method.is_vararg {
			// varargs can't used a fixed-size array
			buf.writeln('\ttotal_args := ${method.arguments.len} + varargs.len')
			buf.writeln('\tmut args := []voidptr{cap: total_args}')
			// add the fixed arguments
			for arg in method.arguments {
				buf.writeln('\targs << voidptr(&${convert_name(arg.name)})')
			}
			// add each vararg
			buf.writeln('
				|	for i in 0..varargs.len {
				|		vararg := varargs[i].to_variant()
				|		args << voidptr(&vararg)
				|	}
			'.strip_margin().trim('\n'))
		} else if has_args {
			// use fixed-size array
			arg_list := method.arguments.map('voidptr(&${convert_name(it.name)})')
			buf.writeln('\targs := [${arg_list.join(', ')}]!')
		}
		arg_ptr := match true {
			// FIX: this may have the same issue classes did with (no args) + (varargs)
			has_args && method.is_vararg {
				'unsafe { &args[0] }'
			}
			has_args {
				'&args[0]'
			}
			else {
				'unsafe{nil}'
			}
		}
		ret_ptr := if has_return {
			'voidptr(&result)'
		} else {
			'unsafe{nil}'
		}
		arg_len := if method.is_vararg {
			'total_args'
		} else {
			'${method.arguments.len}'
		}
		buf.writeln('\tf(${ret_ptr}, ${arg_ptr}, ${arg_len})')

		// return
		if has_return {
			buf.writeln('\treturn result')
		}

		// end
		buf.writeln('}')
	}

	mut f := os.create(g.file('__functions.v'))!
	defer { f.close() }
	f.write(buf)!
}

fn (g &Generator) gen_enums() ! {
	mut buf := strings.new_builder(1024)
	buf.writeln('module godot')

	for enm in g.api.global_enums {
		name := convert_type(enm.name)
		buf.writeln('')
		buf.writeln('pub enum ${name} as i64 {')
		mut bits := []i64{cap: enm.values.len}

		for val in enm.values {
			if val.value !in bits {
				bits << val.value
				buf.write_string(docstring(val.description, before: '\t', after: '\n'))
				buf.writeln('\t${val.name.to_lower()} = ${val.value}')
			}
		}

		buf.writeln('}')
	}

	mut f := os.create(g.file('__enums.v'))!
	defer { f.close() }
	f.write(buf)!
}

// Generate signals for each class.
fn (mut g Generator) gen_signals() ! {
	mut buf := strings.new_builder(1024)
	buf.writeln('module godot')

	mut sigs := map[string]bool{}
	mut clauses := []string{}

	for class in g.api.classes {
		for signal in class.signals {
			sig, sig_name := signature(signal.arguments, strip_names: true)

			if sig_name in sigs {
				continue
			}

			sigs[sig_name] = true
			buf.writeln('')
			buf.writeln('pub type ${sig_name} = ${sig}')

			mut clause := 'if f is ${sig_name} {'
			mut arg_list := []string{cap: signal.arguments.len}
			for a, arg in signal.arguments {
				type := convert_strings(convert_type(arg.type))
				match type {
					'bool' {
						clause += '\n|		arg${a} := unsafe { args[${a}].to_bool() }'
					}
					'string' {
						clause += '\n|		arg${a} := unsafe { args[${a}].to_string() }'
					}
					'i64' {
						clause += '\n|		arg${a} := unsafe { args[${a}].to_i64() }'
					}
					'f64' {
						clause += '\n|		arg${a} := unsafe { args[${a}].to_f64() }'
					}
					'Variant' {
						clause += '\n|		arg${a} := unsafe { args[${a}] }'
					}
					else {
						clause += '\n|		arg${a} := unsafe { ${type}.from_variant(args[${a}]) }'
					}
				}
				arg_list << 'arg${a}'
			}
			clause += '\n|		f(${arg_list.join(', ')})'
			clause += '\n|	}'
			clauses << clause
		}
	}

	buf.writeln('
		|pub type SignalFn = string | Callable | ${sigs.keys().join(' | ')}
		|
		|fn signal_func[T](data voidptr, args &&Variant, arg_count GDExtensionInt, ret &Variant, err &GDExtensionCallError) {
		|	ctx := unsafe { &SignalCtx(data) }
		|
		|	match ctx.kind {
		|		.string {
		|		}
		|		.callable {
		|		}
		|		.func_void {
		|			ctx.func_void()
		|		}
		|	}
		|
		|}
	'.strip_margin().trim_right('\n'))
	// |	${clauses.join(' else ')}

	mut f := os.create(g.file('__signals.v'))!
	defer { f.close() }
	f.write(buf)!
}

fn (mut g Generator) gen_builtin_classes() ! {
	for class in g.api.builtin_classes {
		if class.name.is_lower() {
			continue
		}

		class_name := convert_type(class.name)
		mut buf := strings.new_builder(1024)

		// module
		buf.writeln('module godot')

		// enums
		for enm in class.enums {
			mut bits := []i64{cap: enm.values.len}
			mut enum_name := enm.name
			if !enm.name.starts_with(class_name) {
				enum_name = '${class_name}${enm.name}'
			}
			buf.writeln('')
			buf.writeln('pub enum ${enum_name} as i64 {')

			for val in enm.values {
				if val.value !in bits {
					bits << val.value
					buf.write_string(docstring(val.description, before: '\t', after: '\n'))
					buf.writeln('\t${val.name.to_lower()} = ${val.value}')
				}
			}
			buf.writeln('}')
		}

		// struct
		buf.writeln('')
		buf.write_string(docstring(class.brief_description, after: '\n//\n'))
		buf.write_string(docstring(class.description, after: '\n'))
		buf.writeln('@[packed]')
		buf.writeln('pub struct ${class.name} {')
		mut defined_size := 0
		// TODO: is using builtin_class_member_offsets necessary?
		if offsets := g.api.builtin_class_member_offsets[g.layout_index()].classes.filter(it.name == class.name)[0] {
			// TODO: is sorting necessary?
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

		// constants
		for constant in class.constants {
			const_name := '${class.name.to_lower()}_${convert_name(constant.name)}'
			value := convert_dumb_value(class.name, constant.value) or { 'none' }
			doc := docstring(constant.description, prefix: '|')
			buf.writeln('
				${doc}
				|pub const ${const_name} = ${value}
				|
				${doc}
				|@[inline]
				|pub fn ${class.name}.${convert_name(constant.name)}() ${constant.type} {
				|	return ${const_name}
				|}
			'.strip_margin().trim_right('\n'))
		}

		// constructors
		for method in class.constructors {
			has_args := method.arguments.len > 0

			// fn def
			buf.writeln('')
			buf.write_string(docstring(method.description, after: '\n'))
			buf.write_string('pub fn ${class.name}.new${method.index}(')
			for a, arg in method.arguments {
				if a != 0 {
					buf.write_string(', ')
				}
				if arg.type == 'Variant' {
					buf.write_string('${convert_name(arg.name)}_ ToVariant')
				} else {
					buf.write_string('${convert_name(arg.name)} ${convert_strings(convert_type(arg.type))}')
				}
			}
			buf.writeln(') ${class.name} {')
			buf.writeln('\tmut inst := ${class.name}{}')
			buf.writeln('\tconstructor := gdf.variant_get_ptr_constructor(GDExtensionVariantType.type_${class.name.to_lower()}, ${method.index})')

			// args
			if has_args {
				buf.writeln('\tmut args := []voidptr{cap: ${method.arguments.len}}')
			}
			for a, arg in method.arguments {
				name := convert_name(arg.name)
				// Variant -> ToVariant
				if arg.type == 'Variant' {
					buf.writeln('\t${name} := ${name}_.to_variant()')
				}
				match true {
					arg.type in strings {
						buf.writeln('\targ${a} := ${arg.type}.new(${name})')
						buf.writeln('\tdefer { arg${a}.deinit() }')
						buf.writeln('\targs << &arg${a}')
					}
					convert_type(arg.type) in g.class_names {
						buf.writeln('\targ${a} := ${name}.ptr')
						buf.writeln('\targs << &arg${a}')
					}
					arg.type.starts_with('enum::') || arg.type.starts_with('bitfield::') {
						buf.writeln('\ti64_${name} := i64(${name})')
						buf.writeln('\targs << &i64_${name}')
					}
					else {
						buf.writeln('\targs << unsafe{&${name}}')
					}
				}
			}

			// call
			arg_ptr := match true {
				has_args {
					'unsafe { &args[0] }'
				}
				else {
					'unsafe{nil}'
				}
			}
			buf.writeln('\tconstructor(voidptr(&inst), ${arg_ptr})')

			// return
			buf.writeln('\treturn inst')
			buf.writeln('}')
		}

		// destructor
		if class.has_destructor {
			buf.writeln('
				|pub fn (s &${class.name}) deinit() {
				|	destructor := gdf.variant_get_ptr_destructor(GDExtensionVariantType.type_${class.name.to_lower()})
				|	destructor(voidptr(s))
				|}
			'.strip_margin().trim_right('\n'))
		}

		// methods
		for method in class.methods {
			has_args := method.arguments.len > 0
			has_return := method.return_type != ''
			return_type := convert_type(method.return_type)
			method_name := convert_name(method.name)
			has_optionals := method.arguments.any(it.default_value != '')
			ptr := match true {
				method.is_static { 'unsafe{nil}' }
				class.name in g.class_names { 's.ptr' }
				else { 'voidptr(s)' }
			}

			// create trailing struct for optional arguments
			if has_optionals {
				buf.writeln('')
				buf.writeln('@[params]')
				buf.writeln('pub struct ${class.name}_${method_name}_Cfg {')
				buf.writeln('pub:')
				for arg in method.arguments {
					// skip required args
					if arg.default_value == '' {
						continue
					}
					field_name := convert_name(arg.name)
					field_type := if arg.type == 'Variant' {
						'ToVariant'
					} else {
						convert_strings(convert_type(arg.type))
					}
					field_value := if val := convert_dumb_value(arg.type, arg.default_value) {
						' = ${val}'
					} else {
						''
					}
					buf.writeln('\t${field_name} ${field_type}${field_value}')
				}
				buf.writeln('}')
			}

			// fn def
			buf.writeln('')
			buf.write_string(docstring(method.description, after: '\n'))
			if method.is_static {
				buf.write_string('pub fn ${class.name}.${method_name}(')
			} else {
				buf.write_string('pub fn (s &${class.name}) ${method_name}(')
			}

			// args
			mut first_arg_optional := true
			for a, arg in method.arguments {
				if arg.default_value != '' {
					continue
				}
				first_arg_optional = false
				if a != 0 {
					buf.write_string(', ')
				}
				if arg.type == 'Variant' {
					buf.write_string('${convert_name(arg.name)}_ ToVariant')
				} else {
					buf.write_string('${convert_name(arg.name)} ${convert_strings(convert_type(arg.type))}')
				}
			}
			// varargs get tacked on to the end
			if method.is_vararg {
				if has_args {
					buf.write_string(', ')
				}
				buf.write_string('varargs ...ToVariant')
			}

			// trailing struct
			if has_optionals {
				if !first_arg_optional {
					buf.write_string(', ')
				}
				buf.write_string('cfg ${class.name}_${method_name}_Cfg')
			}

			// return signature
			if has_return {
				buf.writeln(') ${return_type} {')
			} else {
				buf.writeln(') {')
			}

			// body
			buf.writeln("\tf := builtin_method_bind(${g.builtin_bind}, GDExtensionVariantType.type_${class.name.to_lower()}, '${method.name}', i64(${method.hash}))")
			g.builtin_bind++

			// args
			// NOTE: this won't handle optionals + varargs if any were ever added
			if method.is_vararg {
				// varargs can't use a fixed-size array
				buf.writeln('\ttotal_args := ${method.arguments.len} + varargs.len')
				buf.writeln('\tmut args := []voidptr{cap: total_args}')
			} else if has_args {
				buf.writeln('\tmut args := []voidptr{cap: ${method.arguments.len}}')
			}
			// add the fixed arguments
			for a, arg in method.arguments {
				name := convert_name(arg.name)
				mut name_prefix := if has_optionals && arg.default_value != '' {
					'cfg.'
				} else {
					''
				}
				name_suffix := if arg.type == 'Variant' && name_prefix != '' {
					''
				} else {
					'_'
				}
				// Variant -> ToVariant
				if arg.type == 'Variant' {
					buf.writeln('\t${name} := ${name_prefix}${name}${name_suffix}.to_variant()')
					name_prefix = ''
				}
				// TODO: I think if I pull out the arg value before adding, I can make all the vararg stuff happen in one place
				match true {
					arg.type in strings {
						buf.writeln('\targ${a} := ${arg.type}.new(${name_prefix}${name})')
						buf.writeln('\tdefer { arg${a}.deinit() }')
						if method.is_vararg {
							buf.writeln('\targ${a}_var := arg${a}.to_variant()')
							buf.writeln('\tdefer { arg${a}_var.deinit() }')
							buf.writeln('\targs << &arg${a}_var')
						} else {
							buf.writeln('\targs << &arg${a}')
						}
					}
					convert_type(arg.type) in g.class_names {
						buf.writeln('\targ${a} := ${name_prefix}${name}.ptr')
						if method.is_vararg {
							println('TODO: varargs for classes: ${class.name}#${method.name}')
						}
						buf.writeln('\targs << &arg${a}')
					}
					arg.type.starts_with('enum::') || arg.type.starts_with('bitfield::') {
						buf.writeln('\ti64_${name} := i64(${name_prefix}${name})')
						buf.writeln('\targs << &i64_${name}')
						if method.is_vararg {
							println('TODO: varargs for enums: ${class.name}#${method.name}')
						}
					}
					else {
						buf.writeln('\targs << unsafe{&${name_prefix}${name}}')
						if method.is_vararg {
							println('TODO: varargs for else: ${class.name}#${method.name}')
						}
					}
				}
			}
			if method.is_vararg {
				// add each vararg
				buf.writeln('
					|	for i in 0..varargs.len {
					|		vararg := varargs[i].to_variant()
					|		args << &vararg
					|	}
				'.strip_margin().trim('\n'))
			}

			// call
			arg_ptr := match true {
				has_args || method.is_vararg {
					'unsafe { &args[0] }'
				}
				else {
					'unsafe{ nil }'
				}
			}
			ret_ptr := if has_return {
				'voidptr(&result)'
			} else {
				'unsafe{ nil }'
			}
			if has_return {
				buf.writeln('\tmut result := ${convert_return(return_type, method.return_type, g.enum_defaults)}')
			}
			if method.is_vararg {
				buf.writeln('
					|	if total_args > 0 {
					|		f(${ptr}, ${arg_ptr}, ${ret_ptr}, total_args)
					|	} else {
					|		f(${ptr}, unsafe { nil }, ${ret_ptr}, total_args)
					|	}
				'.strip_margin().trim_right('\n'))
			} else {
				buf.writeln('\tf(${ptr}, ${arg_ptr}, ${ret_ptr}, ${method.arguments.len})')
			}

			// return
			if has_return {
				buf.writeln('\treturn result')
			}

			// end
			buf.writeln('}')
		}

		// to Variant
		buf.writeln('
			|pub fn (s &${class.name}) to_variant() Variant {
			|	to_variant := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_${class.name.to_lower()})
			|	result := Variant{}
			|	to_variant(GDExtensionUninitializedVariantPtr(&result), GDExtensionTypePtr(s))
			|	return result
			|}
		'.strip_margin().trim_right('\n'))

		// from Variant
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

		if class.indexing_return_type != '' {
			return_type := convert_type(class.indexing_return_type)

			// keyed
			if class.is_keyed {
				// get
				buf.writeln('
					|pub fn (v &${class.name}) index_get(i &Variant) ?Variant {
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

				// get_named
				buf.writeln('
					|pub fn (v &${class.name}) index_get_named(sn &StringName) ?Variant {
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

				// get_keyed
				buf.writeln('
					|pub fn (v &${class.name}) index_get_keyed(i &Variant) ?Variant {
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

				// set
				buf.writeln('
					|pub fn (v &${class.name}) index_set(key &Variant, value &Variant) ! {
					|	as_var := v.to_variant()
					|	suc := GDExtensionBool(false)
					|	gdf.variant_set(&as_var, key, value, &suc)
					|	if suc != GDExtensionBool(true) {
					|		return error("invalid set on ${class.name}")
					|	}
					|}
				'.strip_margin().trim_right('\n'))

				// set_named
				buf.writeln('
					|pub fn (v &${class.name}) index_set_named(key &StringName, value &Variant) ! {
					|	as_var := v.to_variant()
					|	suc := GDExtensionBool(false)
					|	gdf.variant_set_named(&as_var, key, value, &suc)
					|	if suc != GDExtensionBool(true) {
					|		return error("invalid set_named on ${class.name}")
					|	}
					|}
				'.strip_margin().trim_right('\n'))

				// set_keyed
				buf.writeln('
					|pub fn (v &${class.name}) index_set_keyed(key &Variant, value &Variant) ! {
					|	as_var := v.to_variant()
					|	suc := GDExtensionBool(false)
					|	gdf.variant_set_keyed(&as_var, key, value, &suc)
					|	if suc != GDExtensionBool(true) {
					|		return error("invalid set_keyed on ${class.name}")
					|	}
					|}
				'.strip_margin().trim_right('\n'))
			} else {
				// index
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
		}

		// operators
		gen_operators(mut buf, class_name, class.operators)

		mut f := os.create(g.file('_${class.name}.v'))!
		defer { f.close() }
		f.write(buf)!
	}
}

fn (mut g Generator) gen_classes() ! {
	for class in g.api.classes {
		mut buf := strings.new_builder(1024)

		// module
		buf.writeln('module godot')

		// enums
		for enm in class.enums {
			mut bits := []i64{cap: enm.values.len}
			mut enum_name := enm.name
			if !enm.name.starts_with(class.name) {
				enum_name = '${class.name}${enm.name}'
			}
			buf.writeln('')
			buf.writeln('pub enum ${enum_name} as i64 {')

			for val in enm.values {
				if val.value !in bits {
					bits << val.value
					buf.write_string(docstring(val.description, before: '\t', after: '\n'))
					buf.writeln('\t${val.name.to_lower()} = ${val.value}')
				}
			}
			buf.writeln('}')
		}

		// struct
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

		// constants
		for constant in class.constants {
			const_name := '${class.name.to_lower()}_${convert_name(constant.name)}'
			doc := docstring(constant.description, prefix: '|')
			buf.writeln('
				${doc}
				|pub const ${const_name} = ${constant.value}
				|
				${doc}
				|@[inline]
				|pub fn ${class.name}.${convert_name(constant.name)}() int {
				|	return ${const_name}
				|}
			'.strip_margin().trim_right('\n'))
		}

		// constructor
		if class.is_instantiable {
			buf.writeln("
				|pub fn ${class.name}.new() ${class.name} {
				|	variant := ClassDB.singleton().instantiate('${class.name}')
				|	mut result := ${class.name}{}
				|	result.from_variant(variant)
				|	return result
				|}
			".strip_margin().trim_right('\n'))
		}

		// singleton
		singletons := g.api.singletons.filter(it.type == class.name)
		if singletons.len > 0 {
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

		// signals
		for signal in class.signals {
			doc := docstring(signal.description, prefix: '|')
			_, sig_name := signature(signal.arguments, strip_names: true)
			buf.writeln('
				${doc}
				|pub fn (s &${class.name}) ${convert_name(signal.name)}() &VSignal[${sig_name}] {
				|	signal := Signal.new2(s.obj(), "${signal.name}")
				|	return &VSignal[${sig_name}]{signal}
				|}
			'.strip_margin().trim_right('\n'))
		}

		// to Variant
		buf.writeln('
			|pub fn (s &${class.name}) to_variant() Variant {
			|	if s.ptr == unsafe{nil} { return Variant{} }
			|	to_variant := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_object)
			|	result := Variant{}
			|	to_variant(GDExtensionUninitializedVariantPtr(&result), s.ptr)
			|	return result
			|}
		'.strip_margin().trim_right('\n'))

		// from Variant
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

		// methods
		for method in class.methods {
			has_args := method.arguments.len > 0
			has_return := method.return_value.type != ''
			return_type := convert_type(method.return_value.type)
			method_name := convert_name(method.name)
			has_optionals := method.arguments.any(it.default_value != '')
			ptr := match true {
				method.is_static { 'unsafe { nil }' }
				class.name in g.class_names { 's.ptr' }
				else { 'voidptr(s)' }
			}

			if method.is_virtual {
				buf.writeln('')
				buf.writeln('pub interface ${interface_name(.virtual, class.name, method.name)} {')
				buf.writeln('mut:')
				mut virt_name := '${convert_name(method.name[1..])}_'

				buf.write_string('\t${virt_name}(')
				for i, arg in method.arguments {
					if i != 0 {
						buf.write_string(', ')
					}

					mut name := convert_name(arg.name)
					buf.write_string('${name} ${convert_type(arg.type)}')
				}
				if has_return {
					buf.writeln(') ${return_type}')
				} else {
					buf.writeln(')')
				}
				buf.writeln('}')
			}

			// create trailing struct for optional arguments
			if has_optionals {
				buf.writeln('')
				buf.writeln('// Optional parameters for ${class.name}#${method_name}')
				buf.writeln('@[params]')
				buf.writeln('pub struct ${class.name}_${method_name}_Cfg {')
				buf.writeln('pub:')
				for arg in method.arguments {
					// skip required args
					if arg.default_value == '' {
						continue
					}
					field_name := convert_name(arg.name)
					field_type := if arg.type == 'Variant' {
						'ToVariant'
					} else {
						convert_strings(convert_type(arg.type))
					}
					field_value := if val := convert_dumb_value(arg.type, arg.default_value) {
						' = ${val}'
					} else {
						''
					}
					buf.writeln('\t${field_name} ${field_type}${field_value}')
				}
				buf.writeln('}')
			}

			// fn def
			buf.writeln('')
			buf.write_string(docstring(method.description, after: '\n'))
			if method.is_static {
				buf.write_string('pub fn ${class.name}.${method_name}(')
			} else {
				buf.write_string('pub fn (s &${class.name}) ${method_name}(')
			}

			// args
			mut first_arg_optional := true
			for a, arg in method.arguments {
				if arg.default_value != '' {
					continue
				}
				first_arg_optional = false
				if a != 0 {
					buf.write_string(', ')
				}
				if arg.type == 'Variant' {
					buf.write_string('${convert_name(arg.name)}_ ToVariant')
				} else {
					buf.write_string('${convert_name(arg.name)} ${convert_strings(convert_type(arg.type))}')
				}
			}
			// varargs get tacked on to the end
			if method.is_vararg {
				if method.arguments.len > 0 {
					buf.write_string(', ')
				}
				buf.write_string('varargs ...ToVariant')
			}

			// trailing struct
			if has_optionals {
				if !first_arg_optional {
					buf.write_string(', ')
				}
				buf.write_string('cfg ${class.name}_${method_name}_Cfg')
			}

			// return signature
			if has_return {
				buf.writeln(') ${convert_strings(return_type)} {')
			} else {
				buf.writeln(') {')
			}

			// body
			buf.writeln("\tmb := class_method_bind(${g.class_bind}, '${class.name}', '${method.name}', i64(${method.hash}))")
			g.class_bind++

			// args
			// NOTE: this won't handle optionals + varargs if any were ever added
			if method.is_vararg {
				// varargs can't use a fixed-size array
				buf.writeln('\ttotal_args := ${method.arguments.len} + varargs.len')
				buf.writeln('\tmut args := []voidptr{cap: total_args}')
			} else if has_args {
				buf.writeln('\tmut args := []voidptr{cap: ${method.arguments.len}}')
			}
			// add the fixed arguments
			for a, arg in method.arguments {
				name := convert_name(arg.name)
				mut name_prefix := if has_optionals && arg.default_value != '' {
					'cfg.'
				} else {
					''
				}
				name_suffix := if arg.type == 'Variant' && name_prefix != '' {
					''
				} else {
					'_'
				}
				// Variant -> ToVariant
				if arg.type == 'Variant' {
					buf.writeln('\t${name} := ${name_prefix}${name}${name_suffix}.to_variant()')
					name_prefix = ''
				}
				// TODO: I think if I pull out the arg value before adding, I can make all the vararg stuff happen in one place
				match true {
					arg.type in strings {
						buf.writeln('\targ${a} := ${arg.type}.new(${name_prefix}${name})')
						buf.writeln('\tdefer { arg${a}.deinit() }')
						if method.is_vararg {
							buf.writeln('\targ${a}_var := arg${a}.to_variant()')
							buf.writeln('\tdefer { arg${a}_var.deinit() }')
							buf.writeln('\targs << &arg${a}_var')
						} else {
							buf.writeln('\targs << &arg${a}')
						}
					}
					convert_type(arg.type) in g.class_names {
						buf.writeln('\targ${a} := ${name_prefix}${name}.ptr')
						if method.is_vararg {
							println('TODO: varargs for classes: ${class.name}#${method.name}')
						}
						buf.writeln('\targs << &arg${a}')
					}
					arg.type.starts_with('enum::') || arg.type.starts_with('bitfield::') {
						buf.writeln('\ti64_${name} := i64(${name_prefix}${name})')
						buf.writeln('\targs << &i64_${name}')
						if method.is_vararg {
							println('TODO: varargs for enums: ${class.name}#${method.name}')
						}
					}
					else {
						buf.writeln('\targs << unsafe{&${name_prefix}${name}}')
						if method.is_vararg {
							println('TODO: varargs for else: ${class.name}#${method.name}')
						}
					}
				}
			}
			if method.is_vararg {
				// add each vararg
				buf.writeln('
					|	for i in 0..varargs.len {
					|		vararg := varargs[i].to_variant()
					|		args << &vararg
					|	}
				'.strip_margin().trim('\n'))
			}

			// call
			arg_ptr := match true {
				has_args {
					'unsafe { &args[0] }'
				}
				else {
					'unsafe{nil}'
				}
			}
			ret_ptr := if has_return {
				'voidptr(&result)'
			} else {
				'unsafe{nil}'
			}
			if has_return {
				buf.writeln('\tmut result := ${convert_return(return_type, method.return_value.type, g.enum_defaults)}')
			}
			if method.is_vararg {
				buf.writeln('\tmut err := GDExtensionCallError{}')
				buf.writeln('\tgdf.object_method_bind_call(mb, ${ptr}, voidptr(${arg_ptr}), total_args, ${ret_ptr}, &err)')
			} else {
				buf.writeln('\tgdf.object_method_bind_ptrcall(mb, ${ptr}, ${arg_ptr}, ${ret_ptr})')
			}

			// return
			if has_return {
				match true {
					method.return_value.type in strings {
						buf.writeln('\tresult_v := result.to_v()')
						buf.writeln('\tdefer { result.deinit() }')
						buf.writeln('\treturn result_v')
					}
					method.return_value.type.starts_with('enum::')
						|| method.return_value.type.starts_with('bitfield::') {
						buf.writeln('\treturn unsafe{${return_type}(result)}')
					}
					else {
						buf.writeln('\treturn result')
					}
				}
			}

			// end
			buf.writeln('}')
		}

		mut f := os.create(g.file('_${class.name}.v'))!
		defer { f.close() }
		f.write(buf)!
	}
}

fn (g &Generator) gen_structs() ! {
	mut buf := strings.new_builder(1024)
	buf.writeln('module godot')

	for structure in g.api.native_structures {
		structure_name := convert_type(structure.name)

		buf.writeln('')
		buf.writeln('pub struct ${structure_name} {')

		members := structure.format.split(';')
		buf.writeln('pub mut:')
		for member in members {
			segments := member.split(' = ')
			parts := segments[0].split(' ')

			mut mtype := convert_type(parts[..parts.len - 1].join(' '))
			mut mname := convert_name(parts.last())
			for mname.starts_with('*') {
				mtype = '&${mtype}'
				mname = mname[1..]
			}

			mut mvalue := (segments[1] or { '' }).trim_space()
			if mvalue.ends_with('f') {
				mvalue = mvalue[..mvalue.len - 1]
			}
			if mvalue.ends_with('.') {
				mvalue = mvalue[..mvalue.len - 1]
			}
			if segments.len > 1 && mvalue != '0' {
				buf.writeln('\t${mname} ${mtype} = ${mvalue}')
			} else {
				buf.writeln('\t${mname} ${mtype}')
			}
		}

		buf.writeln('}')
	}

	mut f := os.create(g.file('__structs.v'))!
	defer { f.close() }
	f.write(buf)!
}

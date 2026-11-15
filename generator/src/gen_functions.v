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

fn (mut g GeneratorAPI) gen_functions() ! {
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
			buf.writeln('\tmut vararg_values := []Variant{len: varargs.len}')
			buf.writeln('\tfor i in 0 .. varargs.len {')
			buf.writeln('\t\tvararg_values[i] = varargs[i].to_variant()')
			buf.writeln('\t\targs << voidptr(&vararg_values[i])')
			buf.writeln('\t}')
			buf.writeln('\tdefer {')
			buf.writeln('\t\tfor mut item in vararg_values {')
			buf.writeln('\t\t\titem.deinit()')
			buf.writeln('\t\t}')
			buf.writeln('\t}')
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

	mut f := os.create(g.file('_gen_functions.v'))!
	defer { f.close() }
	f.write(buf)!
}

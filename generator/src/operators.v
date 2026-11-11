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

import strings

@[params]
struct OpOptions {
	is_binary       bool
	different_types bool
}

const binary_ops = ['<', '>', '==', '!=', '<=', '>=', 'in']!

const op_types = {
	'+':  '.op_add'
	'-':  '.op_subtract'
	'*':  '.op_multiply'
	'/':  '.op_divide'
	'%':  '.op_module'
	'<':  '.op_less'
	'>':  '.op_greater'
	'==': '.op_equal'
	'!=': '.op_not_equal'
	'<=': '.op_less_equal'
	'>=': '.op_greater_equal'
	'in': '.op_in'
}

const op_prefixes = {
	'+':  'add_'
	'-':  'sub_'
	'*':  'mul_'
	'/':  'div_'
	'%':  'mod_'
	'<':  'lt_'
	'>':  'gt_'
	'==': 'eq_'
	'!=': 'ne_'
	'<=': 'le_'
	'>=': 'ge_'
	'in': 'in_'
}

fn gen_operator(mut buf strings.Builder, class_name string, op_name string, op_type string, op APIOperator, opts OpOptions) {
	class_name_lower := class_name.to_lower()

	mut right_type := class_name
	mut right_type_lower := class_name_lower
	mut return_type := if opts.is_binary { 'bool' } else { class_name }
	mut res_init := if opts.is_binary { 'false' } else { '${class_name}{}' }
	mut right_type_suffix := ''

	if opts.different_types {
		right_type = convert_type(op.right_type)
		right_type_lower = right_type.to_lower()
		right_type_suffix = right_type_lower

		if !opts.is_binary {
			return_type = convert_type(op.return_type)

			if return_type in ['f32', 'f64', 'i8', 'u8', 'i16', 'u16', 'i32', 'u32', 'i64', 'u64'] {
				res_init = '${return_type}(0)'
			} else if return_type == 'voidptr' {
				res_init = 'unsafe{nil}'
			} else {
				res_init = '${return_type}{}'
			}
		}
	}

	// use $tmpl which will have access to all the variables we've defined
	right_type_variant := if right_type_lower == 'i64' {
		'int'
	} else if right_type_lower == 'f64' {
		'float'
	} else {
		right_type_lower
	}
	code := $tmpl('./templates/operator.vtmpl').trim_space_right()
	buf.writeln('')
	buf.write_string(docstring(op.description, after: '\n'))
	buf.writeln(code)
}

fn gen_operators(mut buf strings.Builder, class_name string, operators []APIOperator) {
	for op in operators {
		// skip if operator type is not supported
		if op.name !in op_types {
			// println('Warning: Operator `${op.name}` not supported for class `${class_name}`')
			continue
		}

		op_type := op_types[op.name]
		is_binary := op.name in binary_ops

		// same type operators
		if op.right_type == class_name && op.name !in ['!=', '>', '<=', '>='] {
			gen_operator(mut buf, class_name, '${op.name} ', op_type, op, is_binary: is_binary)
		}

		// different type operators
		if op.right_type != 'Variant' {
			gen_operator(mut buf, class_name, op_prefixes[op.name], op_type, op,
				is_binary:       is_binary
				different_types: true
			)
		}
	}
}

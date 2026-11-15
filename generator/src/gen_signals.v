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

fn write_emit(mut buf strings.Builder, class_name string, method_name string, args []APIArg) {
	buf.writeln('')
	buf.write_string('pub fn (s &${class_name}) emit_${method_name}(')
	for i, arg in args {
		if i != 0 {
			buf.write_string(', ')
		}
		buf.write_string('${convert_name(arg.name)} ${convert_strings(convert_type(arg.type))}')
	}
	buf.writeln(') {')
	if args.len == 0 {
		buf.writeln('\ts.${method_name}().emit()')
		buf.writeln('}')
		return
	}
	mut values := []string{cap: args.len}
	for arg in args {
		name := convert_name(arg.name)
		kind := convert_strings(convert_type(arg.type))
		match kind {
			'bool' {
				buf.writeln('\t${name}_v := Variant.from_bool(${name})')
				values << '${name}_v'
			}
			'i64' {
				buf.writeln('\t${name}_v := Variant.from_i64(${name})')
				values << '${name}_v'
			}
			'f64' {
				buf.writeln('\t${name}_v := Variant.from_f64(${name})')
				values << '${name}_v'
			}
			'string' {
				buf.writeln('\t${name}_v := String.new(${name})')
				buf.writeln('\tdefer { ${name}_v.deinit() }')
				values << '${name}_v'
			}
			else {
				values << name
			}
		}
	}
	buf.writeln('\ts.${method_name}().emit(${values.join(', ')})')
	buf.writeln('}')
}

// Generate signals for each class.
fn (mut g GeneratorAPI) gen_signals() ! {
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

	mut f := os.create(g.file('_gen_signals.v'))!
	defer { f.close() }
	f.write(buf)!
}

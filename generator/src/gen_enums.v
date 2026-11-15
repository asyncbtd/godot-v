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

fn (g &GeneratorAPI) gen_enums() ! {
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

	mut f := os.create(g.file('_gen_enums.v'))!
	defer { f.close() }
	f.write(buf)!
}

struct Coverage {
pub mut:
	classes         int
	vararg          int
	static_methods  int
	virtual_methods int
	properties      int
	signals         int
	singletons      int
}

// coverage counts the API shapes the generator binds.

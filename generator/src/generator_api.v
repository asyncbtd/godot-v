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

pub struct GeneratorAPI {
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

fn (g &GeneratorAPI) layout_index() int {
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

// GeneratorAPI.new decodes an extension API dump into a generator.
pub fn GeneratorAPI.new(api_dump string, out_dir string) GeneratorAPI {
	api := json2.decode[API](api_dump) or { panic('Failed to parse API dump JSON: ${err}') }

	return GeneratorAPI{
		api:     api
		out_dir: out_dir
	}
}

fn (g &GeneratorAPI) file(name string) string {
	return os.join_path(g.out_dir, name)
}

// run writes the V bindings for the decoded API.
pub fn (mut g GeneratorAPI) run() ! {
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

fn (g &GeneratorAPI) gen_bind_counts() ! {
	os.write_file(g.file('_gen_bind_count.v'), "
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
fn (mut g GeneratorAPI) setup() {
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
			g.enum_defaults[avoid_interface_clash(key)] = convert_name(class_enum.values.first().name)
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

fn (g &GeneratorAPI) gen_gdext_info() ! {
	manifest_path := os.join_path(os.dir(g.out_dir), 'v.mod')
	manifest_text := os.read_file(manifest_path) or { panic(err) }
	mod := vmod.decode(manifest_text) or { panic(err) }
	version := mod.version.split('.')
	name := mod.name
	description := mod.description
	major := version[0].int()
	minor := version[1].int()
	patch := version[2].int()
	full := 'v${mod.version}'
	stamp := time.now().unix()
	godot_major := g.api.header.version_major
	godot_minor := g.api.header.version_minor
	godot_patch := g.api.header.version_patch
	godot_full := g.api.header.version_full_name
	godot_status := g.api.header.version_status
	godot_build := g.api.header.version_build
	code := $tmpl('./templates/info.vtmpl')
	os.write_file(g.file('_gen_info.v'), code.trim('\n'))!
}

fn (g &GeneratorAPI) coverage() Coverage {
	mut found := Coverage{
		classes:    g.api.classes.len
		singletons: g.api.singletons.len
	}
	for class in g.api.classes {
		found.properties += class.properties.len
		found.signals += class.signals.len
		for method in class.methods {
			if method.is_vararg {
				found.vararg++
			}
			if method.is_static {
				found.static_methods++
			}
			if method.is_virtual {
				found.virtual_methods++
			}
		}
	}
	return found
}

fn (g &GeneratorAPI) gen_structs() ! {
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

	mut f := os.create(g.file('_gen_structs.v'))!
	defer { f.close() }
	f.write(buf)!
}

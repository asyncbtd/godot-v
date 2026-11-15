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

import json2
import os
import strings

// Structures mirroring gdextension_interface.json (`--dump-gdextension-interface-json`).
// The dump carries `types` (enums, handles, aliases, function types, structs)
// and `interface` (the entry points resolved through get_proc_address).

// supported_format_version is the only dump schema this generator understands.
const supported_format_version = 1

// base_minor is the oldest supported Godot 4.x minor version. Entry points
// introduced later are resolved only when the bindings are built for them.
const base_minor = 5

struct GDExtDeprecated {
	since        string
	replace_with string
	message      string
}

struct GDExtValue {
	name  string
	value int
}

struct GDExtMember {
	name string
	typ  string @[json: 'type']
}

struct GDExtReturn {
	typ string @[json: 'type']
}

struct GDExtArg {
	name string
	typ  string @[json: 'type']
}

struct GDExtType {
	name         string
	kind         string
	typ          string @[json: 'type']
	values       []GDExtValue
	members      []GDExtMember
	return_value GDExtReturn @[json: 'return_value']
	arguments    []GDExtArg
	deprecated   GDExtDeprecated
}

struct GDExtFn {
	name         string
	arguments    []GDExtArg
	return_value GDExtReturn @[json: 'return_value']
	since        string
	deprecated   GDExtDeprecated
}

struct GDExtDump {
	format_version int @[json: 'format_version']
	types          []GDExtType
	interface_fns  []GDExtFn @[json: 'interface']
}

const interface_license = '// Copyright 2026 Timofey Brukhanchik
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

'

pub struct GeneratorInterface {
	data    GDExtDump
	out_dir string
	// max_minor is the newest Godot 4.x minor version present in the dump.
	max_minor int
}

// GeneratorInterface.new decodes a gdextension_interface.json dump into a generator.
pub fn GeneratorInterface.new(json string, out_dir string) !GeneratorInterface {
	data := json2.decode[GDExtDump](json)!
	if data.format_version != supported_format_version {
		return error('unsupported interface dump format_version ${data.format_version}, expected ${supported_format_version}')
	}
	mut max_minor := base_minor
	for f in data.interface_fns {
		max_minor = int_max(max_minor, since_minor(f.since))
	}
	return GeneratorInterface{
		data:      data
		out_dir:   out_dir
		max_minor: max_minor
	}
}

// run writes extension/interface.v. Maintainers commit that file; users do not
// regenerate it. `extension/_*.v` stays the per-Godot API output.
pub fn (mut g GeneratorInterface) run() ! {
	mut out := g.gen_interface()!
	out += g.gen_version()
	out += g.gen_load()
	os.write_file(os.join_path(g.out_dir, 'interface.v'), out)!
}

// is_function_type reports whether `name` is a function pointer type of the dump.
fn (g &GeneratorInterface) is_function_type(name string) bool {
	return g.data.types.any(it.kind == 'function' && it.name == name)
}

// gate returns the compile-time condition under which an entry point that
// appeared in Godot `since` is resolved, empty when it is always resolved.
// Building with `-d godot_4_N` targets Godot 4.N and newer.
fn (g &GeneratorInterface) gate(since string) string {
	minor := since_minor(since)
	if minor <= base_minor {
		return ''
	}
	mut conds := []string{}
	for k in minor .. g.max_minor + 1 {
		conds << 'godot_4_${k} ?'
	}
	return conds.join(' || ')
}

// gated_fns groups the interface entries by their compile-time gate.
fn (g &GeneratorInterface) gated_fns() map[string][]GDExtFn {
	mut groups := map[string][]GDExtFn{}
	for f in g.data.interface_fns {
		groups[g.gate(f.since)] << f
	}
	return groups
}

// gate_keys returns the gates in a stable order, the always-on gate first.
fn (g &GeneratorInterface) gate_keys(groups map[string][]GDExtFn) []string {
	mut keys := groups.keys()
	keys.sort()
	return keys
}

fn (g &GeneratorInterface) gen_interface() !string {
	mut buf := strings.new_builder(16384)
	buf.write_string(interface_license)
	buf.writeln('module godot')
	buf.writeln('')
	buf.writeln('// Generated from gdextension_interface.json — do not edit.')
	buf.writeln('')
	buf.writeln('// GDWideChar is the C `wchar_t`: 16 bits on Windows, 32 bits elsewhere.')
	buf.writeln('\$if windows {')
	buf.writeln('\tpub type GDWideChar = u16')
	buf.writeln('} \$else {')
	buf.writeln('\tpub type GDWideChar = u32')
	buf.writeln('}')
	buf.writeln('')
	buf.writeln('// GDSize is the C `size_t`: pointer-sized.')
	buf.writeln('\$if x64 {')
	buf.writeln('\tpub type GDSize = u64')
	buf.writeln('} \$else {')
	buf.writeln('\tpub type GDSize = u32')
	buf.writeln('}')
	buf.writeln('')
	for t in g.data.types {
		match t.kind {
			'enum' { g.write_enum(mut buf, t) }
			'handle' { g.write_handle(mut buf, t) }
			'alias' { g.write_alias(mut buf, t) }
			'function' { g.write_fn_type(mut buf, t) }
			'struct' { g.write_struct(mut buf, t) }
			else { return error('unknown type kind "${t.kind}" of ${t.name}') }
		}
	}
	g.write_interface_fn_types(mut buf)
	g.write_iface_fns(mut buf)
	return buf.str()
}

fn has_duplicate_values(values []GDExtValue) bool {
	mut seen := map[int]bool{}
	for v in values {
		if v.value in seen {
			return true
		}
		seen[v.value] = true
	}
	return false
}

// Interface enums are C enums, i.e. 32-bit: they are embedded in structs and
// passed by value, so they must not use the 64-bit layout of the API enums.
fn (g &GeneratorInterface) write_enum(mut buf strings.Builder, t GDExtType) {
	if has_duplicate_values(t.values) {
		buf.writeln('@[_allow_multiple_values]')
	}
	mut members := []EnumMember{cap: t.values.len}
	for v in t.values {
		members << EnumMember{
			name:  enum_value_name(t.name, v.name)
			value: i64(v.value)
		}
	}
	write_enum(mut buf, t.name, '', members, false)
	buf.writeln('')
}

fn (g &GeneratorInterface) write_handle(mut buf strings.Builder, t GDExtType) {
	if smart_v(t.name) != '' {
		return
	}
	buf.writeln('pub type ${t.name} = voidptr')
	buf.writeln('')
}

fn (g &GeneratorInterface) write_alias(mut buf strings.Builder, t GDExtType) {
	write_note(mut buf, t.deprecated)
	buf.writeln('pub type ${t.name} = ${base_type(t.typ)}')
	buf.writeln('')
}

fn (g &GeneratorInterface) write_fn_type(mut buf strings.Builder, t GDExtType) {
	write_note(mut buf, t.deprecated)
	buf.writeln('pub type ${t.name} = ${fn_signature(t.arguments, t.return_value)}')
	buf.writeln('')
}

fn (g &GeneratorInterface) write_struct(mut buf strings.Builder, t GDExtType) {
	write_note(mut buf, t.deprecated)
	buf.writeln('pub struct ${t.name} {')
	buf.writeln('pub mut:')
	for m in t.members {
		fname := safe_name(m.name)
		ftype := c_to_v(m.typ)
		if g.is_function_type(m.typ) || ftype.starts_with('&') {
			buf.writeln('\t${fname} ${ftype} = unsafe { nil }')
		} else {
			buf.writeln('\t${fname} ${ftype}')
		}
	}
	buf.writeln('}')
	buf.writeln('')
}

fn (g &GeneratorInterface) write_interface_fn_types(mut buf strings.Builder) {
	for f in g.data.interface_fns {
		write_note(mut buf, f.deprecated)
		buf.writeln('pub type ${interface_type_name(f.name)} = ${fn_signature(f.arguments, f.return_value)}')
		buf.writeln('')
	}
}

fn (g &GeneratorInterface) write_iface_fns(mut buf strings.Builder) {
	buf.writeln('// GDExtensionInterfaceFunctions holds every entry point of the interface.')
	buf.writeln('// Entry points introduced after Godot 4.${base_minor} are resolved only when built with')
	buf.writeln('// `-d godot_4_N`, otherwise they stay nil. Deprecated ones may be nil on newer Godot.')
	buf.writeln('@[heap]')
	buf.writeln('pub struct GDExtensionInterfaceFunctions {')
	buf.writeln('pub mut:')
	buf.writeln('\tgpaddr fn (&i8) GDExtensionInterfaceFunctionPtr @[required]')
	buf.writeln('\tclp GDExtensionClassLibraryPtr @[required]')
	for f in g.data.interface_fns {
		since := if f.since == '' { '' } else { ' // since ${f.since}' }
		buf.writeln('\t${f.name} ${interface_type_name(f.name)} = unsafe { nil }${since}')
	}
	buf.writeln('}')
}

// gen_version emits the supported-version constants and target_godot_minor.
// The upper bound is the newest `since` in the dump, so a 4.7 dump covers
// builds for 4.5, 4.6 and 4.7.
fn (g &GeneratorInterface) gen_version() string {
	mut buf := strings.new_builder(512)
	buf.writeln('')
	buf.writeln('// Version of the interface dump schema this file was generated from.')
	buf.writeln('pub const gdextension_interface_format_version = ${g.data.format_version}')
	buf.writeln('')
	buf.writeln('// Oldest Godot 4.x minor version the bindings support.')
	buf.writeln('pub const godot_base_minor = ${base_minor}')
	buf.writeln('')
	buf.writeln('// target_godot_minor is the Godot 4.x minor version the bindings were built')
	buf.writeln('// for: the newest `-d godot_4_N` flag given, or ${base_minor} by default.')
	buf.writeln('pub fn target_godot_minor() int {')
	for k := g.max_minor; k > base_minor; k-- {
		buf.writeln('\t\$if godot_4_${k} ? {')
		buf.writeln('\t\treturn ${k}')
		buf.writeln('\t}')
	}
	buf.writeln('\treturn godot_base_minor')
	buf.writeln('}')
	return buf.str()
}

// gen_load emits the interface loader: every entry point of the dump is
// resolved through get_proc_address, grouped by its compile-time gate, and
// every required (non-deprecated) entry point is checked against the running
// Godot. Deprecated entry points may legitimately be nil on newer Godot.
fn (g &GeneratorInterface) gen_load() string {
	groups := g.gated_fns()
	keys := g.gate_keys(groups)
	mut buf := strings.new_builder(16384)
	buf.writeln('')
	buf.writeln('// interface_load resolves every interface entry point through get_proc_address.')
	buf.writeln('// Entry points introduced after Godot 4.${base_minor} resolve only when built')
	buf.writeln('// with `-d godot_4_N`; required ones panic when the running Godot lacks them.')
	buf.writeln('pub fn interface_load(mut fns &GDExtensionInterfaceFunctions) {')
	buf.writeln('\tif fns.gpaddr == unsafe { nil } {')
	buf.writeln("\t\tpanic('GDExtension interface: get_proc_address is null')")
	buf.writeln('\t}')
	buf.writeln('\tif fns.clp == unsafe { nil } {')
	buf.writeln("\t\tpanic('GDExtension interface: class library pointer is null')")
	buf.writeln('\t}')
	for gate in keys {
		fns := groups[gate]
		if fns.len == 0 {
			continue
		}
		g.write_group(mut buf, gate, fns, fn (f GDExtFn) string {
			return 'fns.${f.name} = unsafe { ${interface_type_name(f.name)}(fns.gpaddr(c"${f.name}")) }'
		})
		required := fns.filter(it.deprecated.since == '')
		if required.len == 0 {
			continue
		}
		g.write_group(mut buf, gate, required, fn (f GDExtFn) string {
			return "if fns.${f.name} == unsafe { nil } { panic('GDExtension interface: missing entry point ${f.name} (ABI mismatch with running Godot)') }"
		})
	}
	buf.writeln('}')
	return buf.str()
}

// write_group emits the lines of one gate group, wrapped in `$if` when gated.
fn (g &GeneratorInterface) write_group(mut buf strings.Builder, gate string, fns []GDExtFn, line fn (GDExtFn) string) {
	indent := if gate == '' { '\t' } else { '\t\t' }
	if gate != '' {
		buf.writeln('\t\$if ${gate} {')
	}
	for f in fns {
		buf.writeln(indent + line(f))
	}
	if gate != '' {
		buf.writeln('\t}')
	}
}

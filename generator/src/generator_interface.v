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

// safe_name resolves V keyword collisions for field and parameter names.
fn safe_name(name string) string {
	return if name in keywords { '${name}_' } else { name }
}

// since_minor extracts the minor version of a "4.x" string, 0 when absent.
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

pub struct InterfaceGen {
	data    GDExtDump
	out_dir string
	// max_minor is the newest Godot 4.x minor version present in the dump.
	max_minor int
}

// InterfaceGen.new decodes a gdextension_interface.json dump into a generator.
pub fn InterfaceGen.new(json string, out_dir string) !InterfaceGen {
	data := json2.decode[GDExtDump](json)!
	if data.format_version != supported_format_version {
		return error('unsupported interface dump format_version ${data.format_version}, expected ${supported_format_version}')
	}
	mut max_minor := base_minor
	for f in data.interface_fns {
		max_minor = int_max(max_minor, since_minor(f.since))
	}
	return InterfaceGen{
		data:      data
		out_dir:   out_dir
		max_minor: max_minor
	}
}

// run writes interface.v and runtime.v.
pub fn (mut g InterfaceGen) run() ! {
	os.write_file(os.join_path(g.out_dir, 'interface.v'), g.gen_interface()!)!
	os.write_file(os.join_path(g.out_dir, 'runtime.v'), g.gen_runtime())!
}

// is_function_type reports whether `name` is a function pointer type of the dump.
fn (g &InterfaceGen) is_function_type(name string) bool {
	return g.data.types.any(it.kind == 'function' && it.name == name)
}

// gate returns the compile-time condition under which an entry point that
// appeared in Godot `since` is resolved, empty when it is always resolved.
// Building with `-d godot_4_N` targets Godot 4.N and newer.
fn (g &InterfaceGen) gate(since string) string {
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
fn (g &InterfaceGen) gated_fns() map[string][]GDExtFn {
	mut groups := map[string][]GDExtFn{}
	for f in g.data.interface_fns {
		groups[g.gate(f.since)] << f
	}
	return groups
}

// gate_keys returns the gates in a stable order, the always-on gate first.
fn (g &InterfaceGen) gate_keys(groups map[string][]GDExtFn) []string {
	mut keys := groups.keys()
	keys.sort()
	return keys
}

fn (g &InterfaceGen) gen_interface() !string {
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
	buf.writeln('')
	buf.writeln('pub struct Class {')
	buf.writeln('\tgodot_class bool = true')
	buf.writeln('}')
	buf.writeln('')
	buf.writeln('// HACK: using this to distinguish user-defined classes')
	buf.writeln('pub interface IClass {')
	buf.writeln('\t// ptr voidptr')
	buf.writeln('\tgodot_class bool')
	buf.writeln('}')
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

// write_note writes the deprecation comment of a declaration, if any.
fn write_note(mut buf strings.Builder, d GDExtDeprecated) {
	note := deprecation_note(d)
	if note != '' {
		buf.writeln(note)
	}
}

// Interface enums are C enums, i.e. 32-bit: they are embedded in structs and
// passed by value, so they must not use the 64-bit layout of the API enums.
fn (g &InterfaceGen) write_enum(mut buf strings.Builder, t GDExtType) {
	if has_duplicate_values(t.values) {
		buf.writeln('@[_allow_multiple_values]')
	}
	buf.writeln('pub enum ${t.name} {')
	for v in t.values {
		buf.writeln('\t${enum_value_name(t.name, v.name)} = ${v.value}')
	}
	buf.writeln('}')
	buf.writeln('')
}

fn (g &InterfaceGen) write_handle(mut buf strings.Builder, t GDExtType) {
	if smart_v(t.name) != '' {
		return
	}
	buf.writeln('pub type ${t.name} = voidptr')
	buf.writeln('')
}

fn (g &InterfaceGen) write_alias(mut buf strings.Builder, t GDExtType) {
	write_note(mut buf, t.deprecated)
	buf.writeln('pub type ${t.name} = ${base_type(t.typ)}')
	buf.writeln('')
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

fn (g &InterfaceGen) write_fn_type(mut buf strings.Builder, t GDExtType) {
	write_note(mut buf, t.deprecated)
	buf.writeln('pub type ${t.name} = ${fn_signature(t.arguments, t.return_value)}')
	buf.writeln('')
}

fn (g &InterfaceGen) write_struct(mut buf strings.Builder, t GDExtType) {
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

fn interface_type_name(name string) string {
	return 'GDExtensionInterface' + pascal_case(name)
}

fn (g &InterfaceGen) write_interface_fn_types(mut buf strings.Builder) {
	for f in g.data.interface_fns {
		write_note(mut buf, f.deprecated)
		buf.writeln('pub type ${interface_type_name(f.name)} = ${fn_signature(f.arguments, f.return_value)}')
		buf.writeln('')
	}
}

fn (g &InterfaceGen) write_iface_fns(mut buf strings.Builder) {
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

fn (g &InterfaceGen) gen_runtime() string {
	groups := g.gated_fns()
	keys := g.gate_keys(groups)
	mut buf := strings.new_builder(16384)
	buf.write_string(interface_license)
	buf.writeln('module godot')
	buf.writeln('')
	buf.writeln('import time')
	buf.writeln('')
	buf.writeln('__global (')
	buf.writeln('\tgdf = &GDExt(unsafe { nil })')
	buf.writeln(')')
	buf.writeln('')
	buf.writeln('pub struct GDExt {')
	buf.writeln('\tGDExtensionInterfaceFunctions')
	buf.writeln('}')
	buf.writeln('')
	buf.writeln('// Version of the interface dump schema this module was generated from.')
	buf.writeln('pub const gdextension_interface_format_version = ${g.data.format_version}')
	buf.writeln('')
	buf.writeln('// Oldest Godot 4.x minor version the bindings support.')
	buf.writeln('pub const godot_base_minor = ${base_minor}')
	buf.writeln('')
	g.write_target_minor(mut buf)
	buf.writeln('// setup loads the GDExtension interface and keeps it for later calls.')
	buf.writeln('pub fn setup(gpaddr fn (&i8) GDExtensionInterfaceFunctionPtr, clp GDExtensionClassLibraryPtr) &GDExt {')
	buf.writeln('\tC._vinit(0, unsafe { nil })')
	buf.writeln('')
	buf.writeln('\tmut interface_fns := &GDExtensionInterfaceFunctions{')
	buf.writeln('\t\tgpaddr: gpaddr')
	buf.writeln('\t\tclp: clp')
	buf.writeln('\t}')
	for gate in keys {
		g.write_group(mut buf, gate, groups[gate], fn (f GDExtFn) string {
			return 'interface_fns.${f.name} = unsafe { ${interface_type_name(f.name)}(gpaddr(c"${f.name}")) }'
		})
	}
	buf.writeln('')
	buf.writeln('\tgdf = &GDExt{')
	buf.writeln('\t\tGDExtensionInterfaceFunctions: interface_fns')
	buf.writeln('\t}')
	buf.writeln('\tcheck_interface(interface_fns)')
	buf.writeln('\tprepare_binds()')
	buf.writeln('')
	buf.writeln('\treturn gdf')
	buf.writeln('}')
	buf.writeln('')
	g.write_check_interface(mut buf, groups, keys)
	buf.write_string(runtime_tail)
	return buf.str()
}

// write_group emits the lines of one gate group, wrapped in `$if` when gated.
fn (g &InterfaceGen) write_group(mut buf strings.Builder, gate string, fns []GDExtFn, line fn (GDExtFn) string) {
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

// write_target_minor emits target_godot_minor, the `-d godot_4_N` selection.
fn (g &InterfaceGen) write_target_minor(mut buf strings.Builder) {
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
	buf.writeln('')
}

// write_check_interface emits a runtime ABI check. The running Godot must not be
// older than the version the bindings were built for, and every non-deprecated
// entry point enabled for that version must have resolved through
// get_proc_address. Deprecated entry points may legitimately be gone.
fn (g &InterfaceGen) write_check_interface(mut buf strings.Builder, groups map[string][]GDExtFn, keys []string) {
	buf.writeln('// check_interface verifies the running Godot against the bindings: its version')
	buf.writeln('// must be at least the build target and every required entry point must exist.')
	buf.writeln('fn check_interface(fns &GDExtensionInterfaceFunctions) {')
	buf.writeln('\tif fns.gpaddr == unsafe { nil } {')
	buf.writeln("\t\tpanic('GDExtension interface: get_proc_address is null')")
	buf.writeln('\t}')
	buf.writeln('\tif fns.clp == unsafe { nil } {')
	buf.writeln("\t\tpanic('GDExtension interface: class library pointer is null')")
	buf.writeln('\t}')
	buf.writeln('\tcheck_target_version(fns)')
	for gate in keys {
		required := groups[gate].filter(it.deprecated.since == '')
		if required.len == 0 {
			continue
		}
		g.write_group(mut buf, gate, required, fn (f GDExtFn) string {
			return "if fns.${f.name} == unsafe { nil } { panic('GDExtension interface: missing entry point ${f.name} (ABI mismatch with running Godot)') }"
		})
	}
	buf.writeln('}')
	buf.writeln('')
	buf.write_string(version_check)
}

// version_check is emitted verbatim after check_interface.
const version_check = r'fn check_target_version(fns &GDExtensionInterfaceFunctions) {
	mut version := GDExtensionGodotVersion2{}
	fns.get_godot_version2(&version)
	target := target_godot_minor()
	if version.major == 4 && int(version.minor) < target {
		panic("GDExtension interface: built for Godot 4.${target}+ but Godot 4.${version.minor} is running, rebuild without -d godot_4_${target}")
	}
	if version.major == 4 && int(version.minor) < godot_base_minor {
		panic("GDExtension interface: Godot 4.${version.minor} is older than the supported 4.${godot_base_minor}")
	}
}

'

// runtime_tail is the hand-written portion of runtime.v that does not depend on
// the dump: the version info structs, the bind cache and the method-bind helpers.
const runtime_tail = r'pub struct InfoVersion {
	name        string
	description string
	major       int
	minor       int
	patch       int
	full        string
	time        time.Time
	status      string
	build       string
}

pub struct Info {
	version InfoVersion
	godot   InfoVersion
}

__global (
	class_bind_ptrs   []voidptr
	builtin_bind_ptrs []voidptr
	utility_bind_ptrs []voidptr
)

// prepare_binds allocates the method-bind pointer tables.
pub fn prepare_binds() {
	if class_bind_ptrs.len != class_bind_count {
		class_bind_ptrs = []voidptr{len: class_bind_count, init: unsafe { nil }}
	}
	if builtin_bind_ptrs.len != builtin_bind_count {
		builtin_bind_ptrs = []voidptr{len: builtin_bind_count, init: unsafe { nil }}
	}
	if utility_bind_ptrs.len != utility_bind_count {
		utility_bind_ptrs = []voidptr{len: utility_bind_count, init: unsafe { nil }}
	}
}

fn class_method_bind(index int, class_name string, method string, hash i64) voidptr {
	prepare_binds()
	cached := class_bind_ptrs[index]
	if cached != unsafe { nil } {
		return cached
	}
	classname := StringName.new(class_name)
	fnname := StringName.new(method)
	defer {
		classname.deinit()
		fnname.deinit()
	}
	ptr := gdf.classdb_get_method_bind(&classname, &fnname, hash)
	class_bind_ptrs[index] = ptr
	return ptr
}

fn builtin_method_bind(index int, typ GDExtensionVariantType, method string, hash i64) GDExtensionPtrBuiltInMethod {
	prepare_binds()
	cached := builtin_bind_ptrs[index]
	if cached != unsafe { nil } {
		return GDExtensionPtrBuiltInMethod(cached)
	}
	fnname := StringName.new(method)
	defer {
		fnname.deinit()
	}
	ptr := gdf.variant_get_ptr_builtin_method(typ, &fnname, hash)
	builtin_bind_ptrs[index] = voidptr(ptr)
	return ptr
}

fn utility_function(index int, method string, hash i64) GDExtensionPtrUtilityFunction {
	prepare_binds()
	cached := utility_bind_ptrs[index]
	if cached != unsafe { nil } {
		return GDExtensionPtrUtilityFunction(cached)
	}
	fnname := StringName.new(method)
	defer {
		fnname.deinit()
	}
	ptr := gdf.variant_get_ptr_utility_function(&fnname, hash)
	utility_bind_ptrs[index] = voidptr(ptr)
	return ptr
}
'

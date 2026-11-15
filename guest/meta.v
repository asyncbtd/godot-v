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

module godot

import os

const kind_bool = 1
const kind_int = 2
const kind_i64 = 3
const kind_f32 = 4
const kind_f64 = 5
const kind_string = 6
const kind_vector2 = 7
const kind_object = 8

struct MethodArg {
	name string
	typ  string
}

struct MethodRecord {
mut:
	name string
	args []MethodArg
	ret  string
	line int
	rpc  bool
}

struct PropRecord {
mut:
	name        string
	typ         string
	hint        string
	hint_string string
	exported    bool
	line        int
}

struct SignalRecord {
	name string
	args []MethodArg
	line int
}

struct SignalLink {
mut:
	method string
	node   string
	signal string
}

struct ScriptIssue {
	line    int
	column  int
	message string
}

struct ScriptOutline {
mut:
	name     string
	base     string
	icon     string
	tool     bool
	abstract bool
	methods  []MethodRecord
	props    []PropRecord
	signals  []SignalRecord
	links    []SignalLink
}

struct ValidateReport {
mut:
	errors    []ScriptIssue
	warnings  []ScriptIssue
	functions []MethodRecord
}

struct CallValue {
mut:
	kind int
	b    bool
	i    i64
	f    f64
	s    string
	x    f32
	y    f32
	o    voidptr
}

__global (
	bound_state      = unsafe { nil }
	bound_state_type = ''
	bound_force      = false
	bound_values     = []CallValue{}
	bound_result     = CallValue{}
	bound_ret        = unsafe { nil }
	bound_key        = ''
	loose_states     = map[string]voidptr{}
)

fn heap_alloc(size int) voidptr {
	bytes := if size < 1 { 1 } else { size }
	if godot_host.api.mem_alloc != unsafe { nil } {
		return alloc(uint(bytes))
	}
	return unsafe { malloc(bytes) }
}

fn heap_free(ptr voidptr) {
	if ptr == unsafe { nil } {
		return
	}
	if godot_host.api.mem_free != unsafe { nil } {
		free_mem(ptr)
		return
	}
	unsafe { free(ptr) }
}

fn alloc_state[T]() voidptr {
	ptr := heap_alloc(int(sizeof(T)))
	unsafe {
		*(&T(ptr)) = T{}
	}
	return ptr
}

fn ensure_state[T]() &T {
	if bound_state != unsafe { nil } && (bound_force || bound_state_type == T.name) {
		bound_state_type = T.name
		return unsafe { &T(bound_state) }
	}
	if ptr := loose_states[T.name] {
		bound_state = ptr
		bound_state_type = T.name
		return unsafe { &T(ptr) }
	}
	ptr := alloc_state[T]()
	loose_states[T.name] = ptr
	bound_state = ptr
	bound_state_type = T.name
	return unsafe { &T(ptr) }
}

fn reset_state[T]() {
	if ptr := loose_states[T.name] {
		heap_free(ptr)
	}
	loose_states.delete(T.name)
	if bound_state_type == T.name {
		bound_state = unsafe { nil }
		bound_state_type = ''
	}
	bound_force = false
	bound_values = []CallValue{}
	bound_result = CallValue{}
}

fn take_arg(index int) CallValue {
	if index < 0 || index >= bound_values.len {
		return CallValue{}
	}
	return bound_values[index]
}

fn value_from_variant(variant voidptr) CallValue {
	if variant == unsafe { nil } || gdf == unsafe { nil } {
		return CallValue{}
	}
	kind := int(gdf.variant_get_type(variant))
	to := gdf.get_variant_to_type_constructor
	match kind {
		1 {
			mut flag := u8(0)
			to(GDExtensionVariantType.type_bool)(voidptr(&flag), variant)
			return CallValue{
				kind: kind_bool
				b:    flag != 0
			}
		}
		2 {
			mut value := i64(0)
			to(GDExtensionVariantType.type_int)(voidptr(&value), variant)
			return CallValue{
				kind: kind_i64
				i:    value
			}
		}
		3 {
			mut value := f64(0)
			to(GDExtensionVariantType.type_float)(voidptr(&value), variant)
			return CallValue{
				kind: kind_f64
				f:    value
			}
		}
		4 {
			mut text := GdString{}
			to(GDExtensionVariantType.type_string)(voidptr(&text), variant)
			value := text.text()
			text.clear()
			return CallValue{
				kind: kind_string
				s:    value
			}
		}
		5 {
			mut point := Vector2{}
			to(GDExtensionVariantType.type_vector2)(voidptr(&point), variant)
			return CallValue{
				kind: kind_vector2
				x:    point.x
				y:    point.y
			}
		}
		24 {
			mut obj := unsafe { nil }
			to(GDExtensionVariantType.type_object)(voidptr(&obj), variant)
			return CallValue{
				kind: kind_object
				o:    obj
			}
		}
		else {
			return CallValue{}
		}
	}
}

fn decode_args(args voidptr, count i64) []CallValue {
	mut values := []CallValue{}
	if args == unsafe { nil } || count <= 0 {
		return values
	}
	for i in 0 .. int(count) {
		variant := unsafe { (&voidptr(args))[i] }
		values << value_from_variant(variant)
	}
	return values
}

fn write_result() {
	if bound_ret == unsafe { nil } || gdf == unsafe { nil } {
		return
	}
	from := gdf.get_variant_from_type_constructor
	match bound_result.kind {
		kind_bool {
			flag := u8(if bound_result.b { 1 } else { 0 })
			from(GDExtensionVariantType.type_bool)(bound_ret, voidptr(&flag))
		}
		kind_int, kind_i64 {
			value := bound_result.i
			from(GDExtensionVariantType.type_int)(bound_ret, voidptr(&value))
		}
		kind_f32, kind_f64 {
			value := bound_result.f
			from(GDExtensionVariantType.type_float)(bound_ret, voidptr(&value))
		}
		kind_string {
			mut text := GdString{}
			text.set_text(bound_result.s)
			from(GDExtensionVariantType.type_string)(bound_ret, voidptr(&text))
			text.clear()
		}
		kind_vector2 {
			point := Vector2{
				x: bound_result.x
				y: bound_result.y
			}
			from(GDExtensionVariantType.type_vector2)(bound_ret, voidptr(&point))
		}
		kind_object {
			obj := bound_result.o
			from(GDExtensionVariantType.type_object)(bound_ret, voidptr(&obj))
		}
		else {}
	}
}

fn wants_alias(name string, called string, allow bool) bool {
	if called == name {
		return true
	}
	return allow && called == '_${name}'
}

fn virtual_zero(name string) bool {
	return name == 'ready' || name == 'enter_tree' || name == 'exit_tree' || name == 'predelete'
}

fn virtual_delta(name string) bool {
	return name == 'process' || name == 'physics_process'
}

fn virtual_input(name string) bool {
	return name == 'input' || name == 'unhandled_input'
}

fn notification_name(what int) string {
	return match what {
		1 { 'predelete' }
		10 { 'enter_tree' }
		11 { 'exit_tree' }
		13 { 'ready' }
		16 { 'physics_process' }
		17 { 'process' }
		else { '' }
	}
}

fn parse_outline(source string) ScriptOutline {
	mut outline := ScriptOutline{}
	mut pending := []string{}
	mut link := SignalLink{}
	mut have_link := false
	mut in_block := false
	mut named := false
	for index, raw in source.split_into_lines() {
		text := raw.trim_space()
		line := index + 1
		if in_block {
			if text.contains('*/') {
				in_block = false
			}
			continue
		}
		if text.contains('/*') && text.contains('*/') == false {
			in_block = true
			continue
		}
		if text == '' || text.starts_with('//') {
			continue
		}
		if text.starts_with('@[') {
			pending << text
			if text.contains('NodeClass') {
				quoted := strings_of(text)
				if quoted.len > 0 {
					outline.base = quoted[0]
				}
			}
			if strings_of(text).len == 2 && (text.contains('SignalOn') || text.contains('signal_on')) {
				quoted := strings_of(text)
				link = SignalLink{
					node:   quoted[0]
					signal: quoted[1]
				}
				have_link = true
			}
			continue
		}
		if text == 'pub mut:' || text == 'mut:' || text == 'pub:' || text == '{' || text == '}' {
			continue
		}
		if is_function_line(text) {
			name := method_from_line(text)
			if name != '' {
				outline.methods << MethodRecord{
					name: name
					args: args_from_signature(text)
					line: line
					rpc:  attr_has(pending, 'rpc')
				}
				if have_link {
					link.method = name
					outline.links << link
					have_link = false
					link = SignalLink{}
				}
			}
			pending = []string{}
			continue
		}
		if struct_name := struct_from_line(text) {
			marked := attr_has(pending, 'nodeclass')
			if named == false || marked {
				outline.name = struct_name
				outline.tool = attr_has(pending, 'tool')
				outline.abstract = attr_has(pending, 'abstract')
				outline.icon = icon_from(pending)
				if marked {
					named = true
				}
			}
			pending = []string{}
			continue
		}
		if name, typ := field_from_line(text) {
			mut prop := prop_from_pending(name, typ, line, pending)
			if prop.exported {
				outline.props << prop
			}
			if typ.contains('VSignal') || has_signal_attr(pending) {
				outline.signals << SignalRecord{
					name: name
					args: signal_args(typ)
					line: line
				}
			}
			pending = []string{}
			continue
		}
		if text.contains('NodeClass') {
			quoted := strings_of(text)
			if quoted.len > 0 {
				outline.base = quoted[0]
			}
		}
		pending = []string{}
	}
	return outline
}

fn attr_has(pending []string, name string) bool {
	needle := name.to_lower()
	for attr in pending {
		low := attr.to_lower()
		if low.contains('[${needle}') || low.contains('.${needle}') {
			return true
		}
	}
	return false
}

fn icon_from(pending []string) string {
	for attr in pending {
		if attr_has([attr], 'icon') {
			quoted := strings_of(attr)
			if quoted.len > 0 {
				return quoted[0]
			}
		}
	}
	return ''
}

fn struct_from_line(text string) ?string {
	if text.starts_with('struct ') == false && text.contains(' struct ') == false {
		return none
	}
	rest := text.all_after('struct ').all_before('{').all_before('[').trim_space()
	if rest == '' || rest.contains('(') {
		return none
	}
	return rest
}

fn is_function_line(text string) bool {
	return text.starts_with('fn ') || text.contains(' fn ')
}

fn method_from_line(text string) string {
	body := text.trim_space()
	if body.starts_with('fn (') || body.contains(' fn (') {
		after := body.all_after(') ').trim_space()
		return after.all_before('(').trim_space()
	}
	rest := body.all_after('fn ').trim_space()
	if rest.starts_with('(') {
		return ''
	}
	return rest.all_before('(').trim_space()
}

fn args_from_signature(text string) []MethodArg {
	sig := if text.contains(') ') { text.all_after(') ') } else { text }
	inside := sig.all_after('(').all_before(')')
	if inside.trim_space() == '' {
		return []MethodArg{}
	}
	mut args := []MethodArg{}
	for part in inside.split(',') {
		bit := part.trim_space()
		if bit == '' {
			continue
		}
		bits := bit.split(' ')
		if bits.len >= 2 {
			args << MethodArg{
				name: bits[0]
				typ:  bits[1]
			}
		} else {
			args << MethodArg{
				typ: bits[0]
			}
		}
	}
	return args
}

fn field_from_line(text string) ?(string, string) {
	if text.contains('(') || text.contains(')') || text.contains(':=') {
		return none
	}
	parts := text.split(' ')
	if parts.len < 2 {
		return none
	}
	if parts[0] in ['pub', 'mut', 'module', 'import', 'struct', 'const', 'type', 'enum', 'interface',
		'return'] {
		return none
	}
	return parts[0], parts[1]
}

fn prop_from_pending(name string, typ string, line int, pending []string) PropRecord {
	mut prop := PropRecord{
		name: name
		typ:  typ
		line: line
	}
	for attr in pending {
		low := attr.to_lower()
		if low.contains('export_range') || low.contains('exportrange') {
			prop.exported = true
			prop.hint = 'range'
			prop.hint_string = strings_of(attr).join(',')
		} else if low.contains('export_enum') || low.contains('exportenum') {
			prop.exported = true
			prop.hint = 'enum'
			prop.hint_string = strings_of(attr).join(',')
		} else if low.contains('export') {
			prop.exported = true
		}
	}
	return prop
}

fn has_signal_attr(pending []string) bool {
	for attr in pending {
		if attr.contains('signal') && attr.contains('SignalOn') == false {
			return true
		}
	}
	return false
}

fn signal_args(typ string) []MethodArg {
	if typ.contains('[') == false {
		return []MethodArg{}
	}
	inner := typ.all_after('[').all_before(']')
	if inner == '' || inner == 'void' {
		return []MethodArg{}
	}
	return [
		MethodArg{
			typ: inner
		},
	]
}

fn strings_of(text string) []string {
	mut found := []string{}
	mut current := ''
	mut open := false
	for ch in text {
		if ch == `'` || ch == `"` {
			if open {
				found << current
				current = ''
				open = false
			} else {
				open = true
			}
			continue
		}
		if open {
			current += u8(ch).ascii_str()
		}
	}
	return found
}

fn find_function_line(name string, source string) int {
	plain := if name.starts_with('_') { name[1..] } else { name }
	for method in parse_outline(source).methods {
		if method.name == name || method.name == plain {
			return method.line
		}
	}
	return -1
}

fn find_member_line(name string, source string) int {
	line := find_function_line(name, source)
	if line > 0 {
		return line
	}
	plain := if name.starts_with('_') { name[1..] } else { name }
	outline := parse_outline(source)
	for prop in outline.props {
		if prop.name == name || prop.name == plain {
			return prop.line
		}
	}
	for signal in outline.signals {
		if signal.name == name || signal.name == plain {
			return signal.line
		}
	}
	return -1
}

fn validate_source(source string) ValidateReport {
	outline := parse_outline(source)
	mut checked := ValidateReport{
		functions: outline.methods
	}
	errors, warnings := compiler_issues(source)
	checked.errors = errors
	checked.warnings = warnings
	return checked
}

__global (
	checked_source   = ''
	checked_errors   = []ScriptIssue{}
	checked_warnings = []ScriptIssue{}
)

fn compiler_issues(source string) ([]ScriptIssue, []ScriptIssue) {
	if source == checked_source {
		return checked_errors.clone(), checked_warnings.clone()
	}
	path := os.join_path(os.temp_dir(), 'godot_v_check_${os.getpid()}.v')
	os.write_file(path, source) or {
		return [
			ScriptIssue{
				line:    1
				column:  1
				message: err.msg()
			},
		], []ScriptIssue{}
	}
	defer {
		os.rm(path) or {}
	}
	output, exit_code := run_v_check(path)
	mut errors := []ScriptIssue{}
	mut warnings := []ScriptIssue{}
	for line in output.split_into_lines() {
		if issue := issue_from_compiler(line) {
			if line.contains(': warning:') {
				warnings << issue
			} else if line.contains(': error:') {
				errors << issue
			}
		}
	}
	if exit_code != 0 && errors.len == 0 {
		errors << ScriptIssue{
			line:    1
			column:  1
			message: output.trim_space()
		}
	}
	checked_source = source
	checked_errors = errors.clone()
	checked_warnings = warnings.clone()
	return errors, warnings
}

fn run_v_check(path string) (string, int) {
	bin := os.find_abs_path_of_executable('v') or { return 'v was not found', 1 }
	mut checker := os.new_process(bin)
	checker.set_args(['-nocolor', '-check-syntax', path])
	checker.set_redirect_stdio()
	checker.wait()
	text := checker.stdout_slurp() + checker.stderr_slurp()
	return text, checker.code
}

fn issue_from_compiler(line string) ?ScriptIssue {
	kind := if line.contains(': error:') {
		': error:'
	} else if line.contains(': warning:') {
		': warning:'
	} else {
		return none
	}
	head := line.all_before(kind)
	message := line.all_after(kind).trim_space()
	parts := head.split(':')
	if parts.len < 3 {
		return none
	}
	column := parts[parts.len - 1].int()
	row := parts[parts.len - 2].int()
	if row <= 0 {
		return none
	}
	return ScriptIssue{
		line:    row
		column:  column
		message: message
	}
}

fn outline_of_script(instance voidptr) ScriptOutline {
	state := script_state(instance)
	parsed := parse_outline(state.source.text())
	key := script_id_of_path(state.path.text())
	if slot := godot_host.registry.get(key) {
		if slot.info.len > 0 || slot.props.len > 0 || slot.signals.len > 0 {
			mut outline := ScriptOutline{
				base:    slot.base
				methods: slot.info
				props:   slot.props
				signals: slot.signals
				links:   slot.links
			}
			if parsed.methods.len > 0 {
				outline.methods = merge_lines(slot.info, parsed.methods)
			}
			return outline
		}
	}
	return parsed
}

fn merge_lines(info []MethodRecord, parsed []MethodRecord) []MethodRecord {
	mut out := []MethodRecord{}
	for method in info {
		mut updated := method
		if updated.line == 0 {
			for item in parsed {
				if item.name == method.name {
					updated.line = item.line
					break
				}
			}
		}
		out << updated
	}
	return out
}

fn script_has_signal_name(instance voidptr, name string) bool {
	for signal in outline_of_script(instance).signals {
		if signal.name == name {
			return true
		}
	}
	return false
}

fn member_line_of(instance voidptr, name string) int {
	return find_member_line(name, script_state(instance).source.text())
}

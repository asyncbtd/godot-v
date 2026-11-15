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

struct ClassFacts {
mut:
	name     string
	base     string
	icon     string
	tool     bool
	abstract bool
	rpcs     []string
}

struct ScriptTemplate {
	inherit     string
	name        string
	description string
	content     string
	id          int
}

fn v_keywords() []string {
	return ['as', 'asm', 'assert', 'atomic', 'break', 'const', 'continue', 'defer', 'dump', 'else',
		'enum', 'false', 'fn', 'for', 'go', 'goto', '__global', 'if', 'import', 'in', 'interface',
		'is', 'isreftype', '_likely_', 'lock', 'match', 'module', 'mut', 'nil', 'none', '__offsetof',
		'or', 'pub', 'return', 'rlock', 'select', 'shared', 'sizeof', 'spawn', 'static', 'struct',
		'true', 'type', 'typeof', 'union', '_unlikely_', 'unsafe', 'volatile']
}

fn v_flow_keywords() []string {
	return ['assert', 'break', 'continue', 'defer', 'else', 'for', 'goto', 'if', 'lock', 'match',
		'return', 'rlock', 'select']
}

fn is_v_keyword(word string) bool {
	return word in v_keywords()
}

fn is_v_flow(word string) bool {
	return word in v_flow_keywords()
}

fn doc_comment_delimiters() []string {
	return ['///']
}

fn is_ident_char(ch u8, first bool) bool {
	if ch == `_` || (ch >= `a` && ch <= `z`) || (ch >= `A` && ch <= `Z`) {
		return true
	}
	return first == false && ch >= `0` && ch <= `9`
}

fn is_v_ident(name string) bool {
	if name == '' || is_ident_char(name[0], true) == false {
		return false
	}
	for index in 1 .. name.len {
		if is_ident_char(name[index], false) == false {
			return false
		}
	}
	return true
}

fn path_problem(path string) string {
	name := script_id_of_path(path)
	if name.len == 0 {
		return 'file name is empty'
	}
	if is_v_keyword(name) {
		return '${name} is a V keyword'
	}
	if is_v_ident(name) == false {
		return '${name} is not a V identifier'
	}
	return ''
}

fn builtin_templates(object string) []ScriptTemplate {
	all := [
		script_template('Node', 'Node', 'V script for a Node', 0),
		script_template('Node2D', 'Node2D', 'V script for a Node2D', 1),
		script_template('Area2D', 'Area2D', 'V script for an Area2D', 2),
		script_template('CharacterBody2D', 'CharacterBody2D', 'V script for a CharacterBody2D', 3),
		ScriptTemplate{
			inherit:     ''
			name:        'Empty'
			description: 'Empty V script'
			content:     "@[godot.NodeClass('Node')]\npub struct Script {\n}\n"
			id:          4
		},
	]
	if object == '' {
		return all
	}
	mut found := []ScriptTemplate{}
	for item in all {
		if item.inherit == object {
			found << item
		}
	}
	if found.len == 0 {
		found << all[all.len - 1]
	}
	return found
}

fn script_template(name string, inherit string, description string, id int) ScriptTemplate {
	return ScriptTemplate{
		inherit:     inherit
		name:        name
		description: description
		content:     template_source(name, inherit)
		id:          id
	}
}

fn facts_of(outline ScriptOutline) ClassFacts {
	mut rpcs := []string{}
	for method in outline.methods {
		if method.rpc {
			rpcs << method.name
		}
	}
	return ClassFacts{
		name:     outline.name
		base:     outline.base
		icon:     outline.icon
		tool:     outline.tool
		abstract: outline.abstract
		rpcs:     rpcs
	}
}

fn script_facts(instance voidptr) ClassFacts {
	if instance == unsafe { nil } {
		return ClassFacts{}
	}
	source := script_state(instance).source.text()
	if source.len > 0 {
		return facts_of(parse_outline(source))
	}
	key := script_id_of_path(script_state(instance).path.text())
	if slot := registry.get(key) {
		return slot.facts
	}
	return ClassFacts{}
}

fn global_class_at(path string) ClassFacts {
	for state in script_resources {
		if script_state(state).path.text() == path {
			return script_facts(state)
		}
	}
	text := os.read_file(path) or { '' }
	if text.len > 0 {
		return facts_of(parse_outline(text))
	}
	if slot := registry.get(script_id_of_path(path)) {
		return slot.facts
	}
	return ClassFacts{}
}

fn handles_global_class(typ string) bool {
	return typ == 'VScript' || typ == 'Script'
}

fn editor_program() string {
	chosen := os.getenv('GODOT_V_EDITOR')
	if chosen.len > 0 {
		return chosen
	}
	for name in ['cursor', 'code', 'vim'] {
		if _ := os.find_abs_path_of_executable(name) {
			return name
		}
	}
	return ''
}

fn editor_args(program string, file string, line i64, column i64) []string {
	base := program.all_after_last('/')
	if base == 'vim' || base == 'vi' || base == 'nvim' {
		return ['+${line}', file]
	}
	return ['-g', '${file}:${line}:${column}']
}

fn local_script_path(path string) string {
	if path.starts_with('res://') == false {
		return path
	}
	return path.all_after('res://')
}

fn open_in_editor(script voidptr, line i64, column i64) i64 {
	program := editor_program()
	if program.len == 0 || script == unsafe { nil } {
		return i64(GDError.err_unavailable)
	}
	file := local_script_path(script_state(script).path.text())
	if file.len == 0 {
		return i64(GDError.err_unavailable)
	}
	bin := os.find_abs_path_of_executable(program) or { program }
	mut proc := os.new_process(bin)
	proc.set_args(editor_args(program, file, line, column))
	proc.run()
	return i64(GDError.ok)
}

fn write_builtin_templates(ret voidptr, object string) {
	if ret == unsafe { nil } || api.new_array == unsafe { nil } || gdf == unsafe { nil } {
		return
	}
	write_array(ret)
	for item in builtin_templates(object) {
		dict := heap_alloc(24)
		write_dictionary(dict)
		dict_put_text(dict, 'inherit', item.inherit)
		dict_put_text(dict, 'name', item.name)
		dict_put_text(dict, 'description', item.description)
		dict_put_text(dict, 'content', item.content)
		dict_put_int(dict, 'id', i64(item.id))
		dict_put_int(dict, 'origin', 0)
		mut wrapped := [24]u8{}
		from := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_dictionary)
		from(voidptr(&wrapped[0]), dict)
		push_array(ret, voidptr(&wrapped[0]))
	}
}

fn write_global_class(ret voidptr, facts ClassFacts) {
	if ret == unsafe { nil } || api.new_dictionary == unsafe { nil } {
		return
	}
	write_dictionary(ret)
	dict_put_text(ret, 'name', facts.name)
	dict_put_text(ret, 'base_type', facts.base)
	dict_put_text(ret, 'icon_path', facts.icon)
	dict_put_bool(ret, 'is_abstract', facts.abstract)
	dict_put_bool(ret, 'is_tool', facts.tool)
}

fn write_rpc_config(ret voidptr, names []string) {
	if ret == unsafe { nil } {
		return
	}
	zero(ret, 24)
	if api.new_dictionary == unsafe { nil } || gdf == unsafe { nil } {
		return
	}
	dict := heap_alloc(24)
	write_dictionary(dict)
	for name in names {
		inner := heap_alloc(24)
		write_dictionary(inner)
		dict_put_int(inner, 'rpc_mode', 2)
		dict_put_int(inner, 'transfer_mode', 2)
		dict_put_bool(inner, 'call_local', false)
		dict_put_int(inner, 'channel', 0)
		mut wrapped := [24]u8{}
		from := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_dictionary)
		from(voidptr(&wrapped[0]), inner)
		dict_put_raw(dict, name, voidptr(&wrapped[0]))
	}
	from := gdf.get_variant_from_type_constructor(GDExtensionVariantType.type_dictionary)
	from(ret, dict)
}

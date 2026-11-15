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

// vfmt off
@[Tool]
@[Abstract]
@[Icon('res://icon.svg')]
@[NodeClass('Area2D')]
struct Marked {
}

@[Rpc]
fn (mut self Marked) ping() {}
// vfmt on

fn test_keywords_and_control_flow() {
	assert 'fn' in v_keywords()
	assert 'match' in v_keywords()
	assert '__global' in v_keywords()
	assert is_v_flow('if')
	assert is_v_flow('for')
	assert is_v_flow('match')
	assert is_v_flow('fn') == false
	assert doc_comment_delimiters() == ['///']
}

fn test_path_problem_rejects_keywords_and_bad_names() {
	assert path_problem('res://scripts/player.v') == ''
	assert path_problem('res://fn.v') == 'fn is a V keyword'
	assert path_problem('res://1bad.v') == '1bad is not a V identifier'
	assert path_problem('res://has-dash.v') == 'has-dash is not a V identifier'
	assert path_problem('res://.v') == 'file name is empty'
}

fn test_builtin_templates_cover_the_node_classes() {
	all := builtin_templates('')
	assert all.len == 5
	assert all[0].name == 'Node'
	assert all[0].inherit == 'Node'
	assert all[0].content.contains("NodeClass('Node')")
	assert all[4].name == 'Empty'
	node2d := builtin_templates('Node2D')
	assert node2d.len == 1
	assert node2d[0].inherit == 'Node2D'
	blank := builtin_templates('Camera2D')
	assert blank.len == 1
	assert blank[0].name == 'Empty'
}

fn test_parser_prefers_the_node_class() {
	source := "struct Helper {\n\tlabel string\n}\n\n/*\nstruct Ignored {\n}\n*/\n@[godot.Tool]\n@[godot.NodeClass('Area2D')]\npub struct Player {\n}\n"
	outline := parse_outline(source)
	assert outline.name == 'Player'
	assert outline.base == 'Area2D'
	assert outline.tool
}

fn test_parser_reads_tool_abstract_icon_and_rpc() {
	source := "@[tool]\n@[abstract]\n@[icon('res://icon.svg')]\n@[godot.NodeClass('Node2D')]\npub struct Player {\n}\n\n@[rpc]\nfn (mut self Player) ping() {}\n"
	facts := facts_of(parse_outline(source))
	assert facts.name == 'Player'
	assert facts.base == 'Node2D'
	assert facts.tool
	assert facts.abstract
	assert facts.icon == 'res://icon.svg'
	assert facts.rpcs == ['ping']
}

fn test_register_stores_class_facts() {
	register[Marked]()
	slot := godot_host.registry.get('marked') or {
		assert false
		return
	}
	assert slot.facts.name == 'Marked'
	assert slot.facts.base == 'Area2D'
	assert slot.facts.tool
	assert slot.facts.abstract
	assert slot.facts.icon == 'res://icon.svg'
	assert slot.facts.rpcs == ['ping']
	assert slot.info.len == 1
	assert slot.info[0].rpc
}

fn test_global_class_type_and_editor_launch() {
	assert handles_global_class('VScript')
	assert handles_global_class('Script')
	assert handles_global_class('Node') == false
	assert editor_args('vim', 'player.v', 4, 2) == ['+4', 'player.v']
	assert editor_args('/usr/bin/code', 'player.v', 4, 2) == ['-g', 'player.v:4:2']
	assert local_script_path('res://scripts/player.v') == 'scripts/player.v'
	assert local_script_path('/tmp/player.v') == '/tmp/player.v'
}

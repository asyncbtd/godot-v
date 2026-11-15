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

import os

const sample_api = '{
	"header": {
		"version_major": 4,
		"version_minor": 7,
		"version_patch": 0,
		"version_status": "stable",
		"version_build": "test",
		"version_full_name": "Godot Engine v4.7.stable.test",
		"precision": "float"
	},
	"builtin_class_sizes": [
		{"build_configuration": "float_32", "sizes": [{"name": "int", "size": 8}]},
		{"build_configuration": "float_64", "sizes": [{"name": "int", "size": 8}]}
	],
	"builtin_class_member_offsets": [
		{"build_configuration": "float_64", "classes": []}
	],
	"global_constants": [],
	"global_enums": [{
		"name": "Error",
		"is_bitfield": false,
		"values": [
			{"name": "FAILED", "value": 1},
			{"name": "ERR_DUP", "value": 1}
		]
	}],
	"utility_functions": [{
		"name": "abs",
		"return_type": "int",
		"category": "math",
		"is_vararg": false,
		"hash": 7,
		"arguments": [{"name": "x", "type": "int"}]
	}],
	"builtin_classes": [{
		"name": "int",
		"is_keyed": false,
		"operators": [],
		"has_destructor": false,
		"constructors": []
	}],
	"classes": [
		{
			"name": "Node",
			"is_refcounted": false,
			"is_instantiable": true,
			"api_type": "core",
			"enums": [{
				"name": "ProcessMode",
				"is_bitfield": false,
				"values": [{"name": "INHERIT", "value": 0}]
			}],
			"constants": [{"name": "NOTIFICATION_ENTER_TREE", "value": 10}],
			"signals": [
				{"name": "ready", "arguments": []},
				{"name": "hit", "arguments": [{"name": "amount", "type": "int"}]}
			],
			"properties": [{
				"type": "bool",
				"name": "visible",
				"setter": "set_visible",
				"getter": "is_visible"
			}],
			"methods": [{
				"name": "get_index",
				"is_const": true,
				"is_vararg": false,
				"is_static": false,
				"is_virtual": false,
				"hash": 42,
				"return_value": {"type": "int"},
				"arguments": []
			}, {
				"name": "rpc",
				"is_const": false,
				"is_vararg": true,
				"is_static": false,
				"is_virtual": false,
				"hash": 43,
				"return_value": {"type": ""},
				"arguments": []
			}, {
				"name": "find_node",
				"is_const": true,
				"is_vararg": false,
				"is_static": true,
				"is_virtual": false,
				"hash": 44,
				"return_value": {"type": "int"},
				"arguments": []
			}, {
				"name": "_process",
				"is_const": false,
				"is_vararg": false,
				"is_static": false,
				"is_virtual": true,
				"hash": 45,
				"return_value": {"type": ""},
				"arguments": [{"name": "delta", "type": "float"}]
			}, {
				"name": "is_visible",
				"is_const": true,
				"is_vararg": false,
				"is_static": false,
				"is_virtual": false,
				"hash": 46,
				"return_value": {"type": "bool"},
				"arguments": []
			}, {
				"name": "set_visible",
				"is_const": false,
				"is_vararg": false,
				"is_static": false,
				"is_virtual": false,
				"hash": 47,
				"return_value": {"type": ""},
				"arguments": [{"name": "value", "type": "bool"}]
			}]
		},
		{
			"name": "Sprite",
			"is_refcounted": false,
			"is_instantiable": false,
			"inherits": "Node",
			"api_type": "core"
		},
		{
			"name": "GDExtension",
			"is_refcounted": false,
			"is_instantiable": false,
			"api_type": "core",
			"enums": [{
				"name": "GDExtensionInitializationLevel",
				"is_bitfield": false,
				"values": [{"name": "CORE", "value": 0}]
			}]
		},
		{"name": "Input", "is_refcounted": false, "is_instantiable": false, "api_type": "core"},
		{"name": "OS", "is_refcounted": false, "is_instantiable": false, "api_type": "core"},
		{"name": "Engine", "is_refcounted": false, "is_instantiable": false, "api_type": "core"}
	],
	"singletons": [
		{"name": "Node", "type": "Node"},
		{"name": "Input", "type": "Input"},
		{"name": "OS", "type": "OS"},
		{"name": "Engine", "type": "Engine"}
	],
	"native_structures": [{"name": "ObjectID", "format": "uint64_t id"}]
}'

const test_manifest = "Module {
	name: 'godot'
	description: 'test module'
	version: '1.2.3'
	license: 'MIT'
	dependencies: []
}
"

fn test_coverage_counts_bound_shapes() {
	g := GeneratorAPI.new(sample_api, '')
	found := g.coverage()
	assert found.classes == 6
	assert found.vararg == 1
	assert found.static_methods == 1
	assert found.virtual_methods == 1
	assert found.properties == 1
	assert found.signals == 2
	assert found.singletons == 4
	names := g.api.singletons.map(it.type)
	assert 'Input' in names
	assert 'OS' in names
	assert 'Engine' in names
}

fn test_setup_records_names_and_enum_defaults() {
	mut g := GeneratorAPI.new(sample_api, '')
	g.setup()
	assert g.class_names == ['Node', 'Sprite', 'GDExtension', 'Input', 'OS', 'Engine']
	assert g.builtin_names == ['i64']
	assert g.enum_defaults['GDError'] == 'failed'
	assert g.enum_defaults['NodeProcessMode'] == 'inherit'
	assert g.enum_defaults['GDExtensionLibraryInitializationLevel'] == 'core'
	bits := if sizeof(voidptr) == 8 { '64' } else { '32' }
	assert g.api.builtin_class_sizes[g.layout_index()].build_configuration == 'float_${bits}'
	assert g.file('a.v') == os.join_path('', 'a.v')
}

fn test_layout_index_follows_header_precision() {
	mut body := sample_api.replace('"precision": "float"', '"precision": "double"')
	body = body.replace('"build_configuration": "float_32"', '"build_configuration": "double_32"')
	body = body.replace('"build_configuration": "float_64"', '"build_configuration": "double_64"')
	g := GeneratorAPI.new(body, '/tmp/out')
	bits := if sizeof(voidptr) == 8 { '64' } else { '32' }
	assert g.api.builtin_class_sizes[g.layout_index()].build_configuration == 'double_${bits}'
	assert g.file('a.v') == os.join_path('/tmp/out', 'a.v')
}

fn test_setup_records_builtin_enum_keys() {
	enums := '[{"name": "intSigned", "values": [{"name": "SIGNED", "value": 1}]}, {"name": "Mode", "values": [{"name": "ANY", "value": 0}]}]'
	body := sample_api.replace('"constructors": []', '"constructors": [], "enums": ${enums}')
	mut g := GeneratorAPI.new(body, '')
	g.setup()
	assert g.enum_defaults['intSigned'] == 'signed'
	assert g.enum_defaults['intMode'] == 'any'
}

fn test_run_writes_api_bindings() {
	root := os.join_path(@VMODROOT, 'api_test_out')
	out_dir := os.join_path(root, 'extension')
	os.mkdir_all(out_dir) or { panic(err) }
	defer {
		os.rmdir_all(root) or { panic(err) }
	}
	os.write_file(os.join_path(root, 'v.mod'), test_manifest) or { panic(err) }

	mut g := GeneratorAPI.new(sample_api, out_dir)
	g.run()!

	enums := os.read_file(os.join_path(out_dir, '_gen_enums.v'))!
	assert enums.contains('pub enum GDError as i64 {')
	assert enums.contains('\tfailed = 1')
	assert !enums.contains('err_dup')

	functions := os.read_file(os.join_path(out_dir, '_gen_functions.v'))!
	assert functions.contains('pub fn abs(x i64) i64 {')
	assert functions.contains("utility_function(0, 'abs', i64(7))")

	node := os.read_file(os.join_path(out_dir, '_Node.v'))!
	assert node.contains('pub enum NodeProcessMode as i64 {')
	assert node.contains('pub struct Node {')
	assert node.contains('pub fn Node.new() Node {')
	assert node.contains('pub fn Node.singleton() Node {')
	assert node.contains('pub const node_notification_enter_tree = 10')
	assert node.contains('pub fn (s &Node) ready() &VSignal[SignalFn_void] {')
	assert node.contains('pub fn (s &Node) get_index() i64 {')
	assert node.contains("class_method_bind(0, 'Node', 'get_index', i64(42))")
	assert node.contains('pub fn (s &Node) rpc(varargs ...ToVariant) {')
	assert node.contains('pub fn Node.find_node() i64 {')
	assert node.contains('pub interface INodeProcess {')
	assert node.contains('process_(delta f64)')
	assert node.contains('pub fn (s &Node) visible() bool {')
	assert node.contains('return s.is_visible()')
	assert node.contains('pub fn (s &Node) connect_ready(cb Callable, cfg Signal_connect_Cfg) i64 {')
	assert node.contains('pub fn (s &Node) emit_ready() {')
	assert node.contains('pub fn (s &Node) emit_hit(amount i64) {')
	assert node.contains('amount_v := Variant.from_i64(amount)')

	input := os.read_file(os.join_path(out_dir, '_Input.v'))!
	assert input.contains('pub fn Input.singleton() Input {')
	os_file := os.read_file(os.join_path(out_dir, '_OS.v'))!
	assert os_file.contains('pub fn OS.singleton() OS {')
	engine := os.read_file(os.join_path(out_dir, '_Engine.v'))!
	assert engine.contains('pub fn Engine.singleton() Engine {')

	sprite := os.read_file(os.join_path(out_dir, '_Sprite.v'))!
	assert sprite.contains('pub struct Sprite {')
	assert sprite.contains('\tNode')

	gd_ext := os.read_file(os.join_path(out_dir, '_GDExtension.v'))!
	assert gd_ext.contains('pub enum GDExtensionLibraryInitializationLevel as i64 {')

	structs := os.read_file(os.join_path(out_dir, '_gen_structs.v'))!
	assert structs.contains('pub struct ObjectID {')
	assert structs.contains('\tid u64')

	counts := os.read_file(os.join_path(out_dir, '_gen_bind_count.v'))!
	assert counts.contains('const class_bind_count = 6')
	assert counts.contains('const builtin_bind_count = 0')
	assert counts.contains('const utility_bind_count = 1')

	info := os.read_file(os.join_path(out_dir, '_gen_info.v'))!
	assert info.contains("name:        'godot'")
	assert info.contains('major:       1')
	assert info.contains('minor:       2')
	assert info.contains('patch:       3')
	assert info.contains("full:        'Godot Engine v4.7.stable.test'")

	assert !os.exists(os.join_path(out_dir, '_int.v'))
}

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
			"signals": [{"name": "ready", "arguments": []}],
			"methods": [{
				"name": "get_index",
				"is_const": true,
				"is_vararg": false,
				"is_static": false,
				"is_virtual": false,
				"hash": 42,
				"return_value": {"type": "int"},
				"arguments": []
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
		}
	],
	"singletons": [{"name": "Node", "type": "Node"}],
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

fn test_setup_records_names_and_enum_defaults() {
	mut g := GeneratorAPI.new(sample_api, '')
	g.setup()
	assert g.class_names == ['Node', 'Sprite', 'GDExtension']
	assert g.builtin_names == ['i64']
	assert g.enum_defaults['GDError'] == 'failed'
	assert g.enum_defaults['NodeProcessMode'] == 'inherit'
	assert g.enum_defaults['GDExtensionLibraryInitializationLevel'] == 'core'
	bits := if sizeof(voidptr) == 8 { '64' } else { '32' }
	assert g.api.builtin_class_sizes[g.layout_index()].build_configuration == 'float_${bits}'
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

	enums := os.read_file(os.join_path(out_dir, '__enums.v'))!
	assert enums.contains('pub enum GDError as i64 {')
	assert enums.contains('\tfailed = 1')
	assert !enums.contains('err_dup')

	functions := os.read_file(os.join_path(out_dir, '__functions.v'))!
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

	sprite := os.read_file(os.join_path(out_dir, '_Sprite.v'))!
	assert sprite.contains('pub struct Sprite {')
	assert sprite.contains('\tNode')

	gd_ext := os.read_file(os.join_path(out_dir, '_GDExtension.v'))!
	assert gd_ext.contains('pub enum GDExtensionLibraryInitializationLevel as i64 {')

	structs := os.read_file(os.join_path(out_dir, '__structs.v'))!
	assert structs.contains('pub struct ObjectID {')
	assert structs.contains('\tid u64')

	counts := os.read_file(os.join_path(out_dir, '__bind_count.v'))!
	assert counts.contains('const class_bind_count = 1')
	assert counts.contains('const builtin_bind_count = 0')
	assert counts.contains('const utility_bind_count = 1')

	info := os.read_file(os.join_path(out_dir, '__info.v'))!
	assert info.contains("name:        'godot'")
	assert info.contains('major:       1')
	assert info.contains('minor:       2')
	assert info.contains('patch:       3')
	assert info.contains("full:        'Godot Engine v4.7.stable.test'")

	assert !os.exists(os.join_path(out_dir, '_int.v'))
}

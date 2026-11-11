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

// This file checks the virtual method table in `method_specs` against the
// Godot extension API dump, so that:
//   - every registered spec is a real Godot virtual method (no typos),
//   - no spec is registered twice,
//   - the set of methods we do not register matches exactly the documented
//     "Not registered" list in docs/script-language-features.md.

import os
import json2

struct DumpMethod {
	name string
}

struct DumpClass {
	name    string
	methods []DumpMethod
}

struct DumpApi {
	classes []DumpClass
}

fn dump_path() string {
	from_env := os.getenv('GODOT_EXTENSION_API')
	if from_env != '' {
		return from_env
	}
	return os.join_path(@VMODROOT, 'generator', 'extension_api.json')
}

fn dump_virtual_methods() map[string][]string {
	body := os.read_file(dump_path()) or { panic('extension API dump not found at ${dump_path()}') }
	api_dump := json2.decode[DumpApi](body) or { panic('invalid extension API dump: ${err}') }
	mut want := map[string][]string{}
	for entry in api_dump.classes {
		if entry.name in ['ScriptLanguageExtension', 'ScriptExtension', 'ResourceFormatLoader',
			'ResourceFormatSaver'] {
			want[entry.name] = entry.methods.map(it.name)
		}
	}
	return want
}

fn spec_class(kind int) string {
	return match kind {
		kind_language { 'ScriptLanguageExtension' }
		kind_script { 'ScriptExtension' }
		kind_loader { 'ResourceFormatLoader' }
		kind_saver { 'ResourceFormatSaver' }
		else { '' }
	}
}

// Virtual methods documented as not registered yet.
fn not_registered_yet() map[string][]string {
	return {
		'ScriptLanguageExtension': ['_get_doc_comment_delimiters', '_preferred_file_name_casing']
		'ScriptExtension':         ['_get_class_icon_path', '_get_script_method_argument_count',
			'_is_abstract', '_placeholder_erased']
		'ResourceFormatLoader':    ['_exists', '_get_classes_used', '_get_dependencies',
			'_get_resource_script_class', '_get_resource_uid', '_rename_dependencies']
		'ResourceFormatSaver':     ['_set_uid']
	}
}

fn test_method_specs_match_godot() {
	want := dump_virtual_methods()
	mut have := map[string][]string{}
	gaps := not_registered_yet()
	mut seen := map[string]bool{}
	for spec in method_specs() {
		cls := spec_class(spec.kind)
		assert cls != '', 'unknown spec kind ${spec.kind} for ${spec.name}'
		key := '${cls}.${spec.name}'
		assert !(key in seen), 'duplicate spec ${key}'
		seen[key] = true
		assert spec.name in want[cls], '${key} is not a Godot virtual method'
		have[cls] << spec.name
	}
	for cls, wanted in want {
		for name in wanted {
			if name in have[cls] {
				continue
			}
			assert name in gaps[cls], '${cls}.${name} is missing from method_specs and not documented as skipped'
		}
		for name in gaps[cls] {
			assert name !in have[cls], '${cls}.${name} is registered: remove it from not_registered_yet'
		}
	}
}

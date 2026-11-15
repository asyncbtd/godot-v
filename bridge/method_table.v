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

const action_stub = 0
const action_lang_name = 1
const action_lang_type = 2
const action_lang_extension = 3
const action_lang_extensions = 4
const action_lang_comments = 5
const action_lang_strings = 6
const action_lang_template = 7
const action_lang_create = 8
const action_lang_templates = 9
const action_lang_validate = 10
const action_script_can_instantiate = 11
const action_script_base = 12
const action_script_placeholder = 13
const action_script_has_source = 14
const action_script_get_source = 15
const action_script_set_source = 16
const action_script_reload = 17
const action_script_valid = 18
const action_script_language = 19
const action_script_reload_file = 20
const action_loader_extensions = 21
const action_loader_handles = 22
const action_loader_type = 23
const action_loader_recognize = 24
const action_loader_load = 25
const action_saver_recognize = 26
const action_saver_extensions = 27
const action_saver_path = 28
const action_saver_save = 29
const action_script_instance = 30
const action_script_has_method = 31
const action_scripts_refresh = 32
const action_script_methods = 33

fn write_stub(ret voidptr, kind int) {
	if ret == unsafe { nil } {
		return
	}
	match kind {
		ret_bool { write_bool(ret, false) }
		ret_number { write_number(ret, 0) }
		ret_pointer { write_pointer(ret, unsafe { nil }) }
		ret_string { zero(ret, 8) }
		ret_string_name { zero(ret, 8) }
		ret_dictionary { write_dictionary(ret) }
		ret_array { write_array(ret) }
		ret_packed_string { write_packed(ret, []string{}) }
		ret_variant { zero(ret, 24) }
		else {}
	}
}

fn method_specs() []Spec {
	return [
		Spec{kind_language, '_get_name', action_lang_name, ret_string},
		Spec{kind_language, '_init', action_stub, ret_none},
		Spec{kind_language, '_get_type', action_lang_type, ret_string},
		Spec{kind_language, '_get_extension', action_lang_extension, ret_string},
		Spec{kind_language, '_finish', action_stub, ret_none},
		Spec{kind_language, '_get_reserved_words', action_stub, ret_packed_string},
		Spec{kind_language, '_is_control_flow_keyword', action_stub, ret_bool},
		Spec{kind_language, '_get_comment_delimiters', action_lang_comments, ret_packed_string},
		Spec{kind_language, '_get_string_delimiters', action_lang_strings, ret_packed_string},
		Spec{kind_language, '_make_template', action_lang_template, ret_pointer},
		Spec{kind_language, '_get_built_in_templates', action_stub, ret_array},
		Spec{kind_language, '_is_using_templates', action_lang_templates, ret_bool},
		Spec{kind_language, '_validate', action_lang_validate, ret_dictionary},
		Spec{kind_language, '_validate_path', action_stub, ret_string},
		Spec{kind_language, '_create_script', action_lang_create, ret_pointer},
		Spec{kind_language, '_has_named_classes', action_stub, ret_bool},
		Spec{kind_language, '_supports_builtin_mode', action_stub, ret_bool},
		Spec{kind_language, '_supports_documentation', action_stub, ret_bool},
		Spec{kind_language, '_can_inherit_from_file', action_stub, ret_bool},
		Spec{kind_language, '_find_function', action_stub, ret_number},
		Spec{kind_language, '_make_function', action_stub, ret_string},
		Spec{kind_language, '_can_make_function', action_stub, ret_bool},
		Spec{kind_language, '_open_in_external_editor', action_stub, ret_number},
		Spec{kind_language, '_overrides_external_editor', action_stub, ret_bool},
		Spec{kind_language, '_complete_code', action_stub, ret_dictionary},
		Spec{kind_language, '_lookup_code', action_stub, ret_dictionary},
		Spec{kind_language, '_auto_indent_code', action_stub, ret_string},
		Spec{kind_language, '_add_global_constant', action_stub, ret_none},
		Spec{kind_language, '_add_named_global_constant', action_stub, ret_none},
		Spec{kind_language, '_remove_named_global_constant', action_stub, ret_none},
		Spec{kind_language, '_thread_enter', action_stub, ret_none},
		Spec{kind_language, '_thread_exit', action_stub, ret_none},
		Spec{kind_language, '_debug_get_error', action_stub, ret_string},
		Spec{kind_language, '_debug_get_stack_level_count', action_stub, ret_number},
		Spec{kind_language, '_debug_get_stack_level_line', action_stub, ret_number},
		Spec{kind_language, '_debug_get_stack_level_function', action_stub, ret_string},
		Spec{kind_language, '_debug_get_stack_level_source', action_stub, ret_string},
		Spec{kind_language, '_debug_get_stack_level_locals', action_stub, ret_dictionary},
		Spec{kind_language, '_debug_get_stack_level_members', action_stub, ret_dictionary},
		Spec{kind_language, '_debug_get_stack_level_instance', action_stub, ret_pointer},
		Spec{kind_language, '_debug_get_globals', action_stub, ret_dictionary},
		Spec{kind_language, '_debug_parse_stack_level_expression', action_stub, ret_string},
		Spec{kind_language, '_debug_get_current_stack_info', action_stub, ret_array},
		Spec{kind_language, '_reload_all_scripts', action_scripts_refresh, ret_none},
		Spec{kind_language, '_reload_scripts', action_scripts_refresh, ret_none},
		Spec{kind_language, '_reload_tool_script', action_scripts_refresh, ret_none},
		Spec{kind_language, '_get_recognized_extensions', action_lang_extensions, ret_packed_string},
		Spec{kind_language, '_get_public_functions', action_stub, ret_array},
		Spec{kind_language, '_get_public_constants', action_stub, ret_dictionary},
		Spec{kind_language, '_get_public_annotations', action_stub, ret_array},
		Spec{kind_language, '_profiling_start', action_stub, ret_none},
		Spec{kind_language, '_profiling_stop', action_stub, ret_none},
		Spec{kind_language, '_profiling_set_save_native_calls', action_stub, ret_none},
		Spec{kind_language, '_profiling_get_accumulated_data', action_stub, ret_number},
		Spec{kind_language, '_profiling_get_frame_data', action_stub, ret_number},
		Spec{kind_language, '_frame', action_scripts_refresh, ret_none},
		Spec{kind_language, '_handles_global_class_type', action_stub, ret_bool},
		Spec{kind_language, '_get_global_class_name', action_stub, ret_dictionary},
		Spec{kind_script, '_editor_can_reload_from_file', action_script_reload_file, ret_bool},
		Spec{kind_script, '_can_instantiate', action_script_can_instantiate, ret_bool},
		Spec{kind_script, '_get_base_script', action_stub, ret_pointer},
		Spec{kind_script, '_get_global_name', action_stub, ret_string_name},
		Spec{kind_script, '_inherits_script', action_stub, ret_bool},
		Spec{kind_script, '_get_instance_base_type', action_script_base, ret_string_name},
		Spec{kind_script, '_instance_create', action_script_instance, ret_pointer},
		Spec{kind_script, '_placeholder_instance_create', action_script_placeholder, ret_pointer},
		Spec{kind_script, '_instance_has', action_stub, ret_bool},
		Spec{kind_script, '_has_source_code', action_script_has_source, ret_bool},
		Spec{kind_script, '_get_source_code', action_script_get_source, ret_string},
		Spec{kind_script, '_set_source_code', action_script_set_source, ret_none},
		Spec{kind_script, '_reload', action_script_reload, ret_number},
		Spec{kind_script, '_get_doc_class_name', action_stub, ret_string_name},
		Spec{kind_script, '_get_documentation', action_stub, ret_array},
		Spec{kind_script, '_has_method', action_script_has_method, ret_bool},
		Spec{kind_script, '_has_static_method', action_stub, ret_bool},
		Spec{kind_script, '_get_method_info', action_stub, ret_dictionary},
		Spec{kind_script, '_is_tool', action_stub, ret_bool},
		Spec{kind_script, '_is_valid', action_script_valid, ret_bool},
		Spec{kind_script, '_get_language', action_script_language, ret_pointer},
		Spec{kind_script, '_has_script_signal', action_stub, ret_bool},
		Spec{kind_script, '_get_script_signal_list', action_stub, ret_array},
		Spec{kind_script, '_has_property_default_value', action_stub, ret_bool},
		Spec{kind_script, '_get_property_default_value', action_stub, ret_variant},
		Spec{kind_script, '_update_exports', action_stub, ret_none},
		Spec{kind_script, '_get_script_method_list', action_script_methods, ret_array},
		Spec{kind_script, '_get_script_property_list', action_stub, ret_array},
		Spec{kind_script, '_get_member_line', action_stub, ret_number},
		Spec{kind_script, '_get_constants', action_stub, ret_dictionary},
		Spec{kind_script, '_get_members', action_stub, ret_array},
		Spec{kind_script, '_is_placeholder_fallback_enabled', action_stub, ret_bool},
		Spec{kind_script, '_get_rpc_config', action_stub, ret_variant},
		Spec{kind_loader, '_get_recognized_extensions', action_loader_extensions, ret_packed_string},
		Spec{kind_loader, '_handles_type', action_loader_handles, ret_bool},
		Spec{kind_loader, '_get_resource_type', action_loader_type, ret_string},
		Spec{kind_loader, '_recognize_path', action_loader_recognize, ret_bool},
		Spec{kind_loader, '_load', action_loader_load, ret_variant},
		Spec{kind_saver, '_recognize', action_saver_recognize, ret_bool},
		Spec{kind_saver, '_get_recognized_extensions', action_saver_extensions, ret_packed_string},
		Spec{kind_saver, '_recognize_path', action_saver_path, ret_bool},
		Spec{kind_saver, '_save', action_saver_save, ret_number},
	]
}

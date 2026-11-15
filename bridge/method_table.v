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

fn method_specs() []MethodSpec {
	return [
		MethodSpec{ kind: kind_language, name: '_get_name', ret: ret_string, handler: on_lang_name },
		MethodSpec{ kind: kind_language, name: '_init', ret: ret_none },
		MethodSpec{ kind: kind_language, name: '_get_type', ret: ret_string, handler: on_lang_type },
		MethodSpec{ kind: kind_language, name: '_get_extension', ret: ret_string, handler: on_lang_extension },
		MethodSpec{ kind: kind_language, name: '_finish', ret: ret_none },
		MethodSpec{ kind: kind_language, name: '_get_reserved_words', ret: ret_packed_string, handler: on_lang_reserved },
		MethodSpec{ kind: kind_language, name: '_is_control_flow_keyword', ret: ret_bool, handler: on_lang_flow },
		MethodSpec{ kind: kind_language, name: '_get_doc_comment_delimiters', ret: ret_packed_string, handler: on_lang_doc },
		MethodSpec{ kind: kind_language, name: '_get_comment_delimiters', ret: ret_packed_string, handler: on_lang_comments },
		MethodSpec{ kind: kind_language, name: '_get_string_delimiters', ret: ret_packed_string, handler: on_lang_strings },
		MethodSpec{ kind: kind_language, name: '_make_template', ret: ret_pointer, handler: on_lang_template },
		MethodSpec{ kind: kind_language, name: '_get_built_in_templates', ret: ret_array, handler: on_lang_builtin },
		MethodSpec{ kind: kind_language, name: '_is_using_templates', ret: ret_bool, handler: on_lang_templates },
		MethodSpec{ kind: kind_language, name: '_validate', ret: ret_dictionary, handler: on_lang_validate },
		MethodSpec{ kind: kind_language, name: '_validate_path', ret: ret_string, handler: on_lang_path },
		MethodSpec{ kind: kind_language, name: '_create_script', ret: ret_pointer, handler: on_lang_create },
		MethodSpec{ kind: kind_language, name: '_has_named_classes', ret: ret_bool },
		MethodSpec{ kind: kind_language, name: '_supports_builtin_mode', ret: ret_bool },
		MethodSpec{ kind: kind_language, name: '_supports_documentation', ret: ret_bool },
		MethodSpec{ kind: kind_language, name: '_can_inherit_from_file', ret: ret_bool },
		MethodSpec{ kind: kind_language, name: '_find_function', ret: ret_number, handler: on_lang_find },
		MethodSpec{ kind: kind_language, name: '_make_function', ret: ret_string },
		MethodSpec{ kind: kind_language, name: '_can_make_function', ret: ret_bool },
		MethodSpec{ kind: kind_language, name: '_open_in_external_editor', ret: ret_number, handler: on_lang_open },
		MethodSpec{ kind: kind_language, name: '_overrides_external_editor', ret: ret_bool, handler: on_lang_external },
		MethodSpec{ kind: kind_language, name: '_complete_code', ret: ret_dictionary },
		MethodSpec{ kind: kind_language, name: '_lookup_code', ret: ret_dictionary },
		MethodSpec{ kind: kind_language, name: '_auto_indent_code', ret: ret_string },
		MethodSpec{ kind: kind_language, name: '_add_global_constant', ret: ret_none },
		MethodSpec{ kind: kind_language, name: '_add_named_global_constant', ret: ret_none },
		MethodSpec{ kind: kind_language, name: '_remove_named_global_constant', ret: ret_none },
		MethodSpec{ kind: kind_language, name: '_thread_enter', ret: ret_none },
		MethodSpec{ kind: kind_language, name: '_thread_exit', ret: ret_none },
		MethodSpec{ kind: kind_language, name: '_debug_get_error', ret: ret_string },
		MethodSpec{ kind: kind_language, name: '_debug_get_stack_level_count', ret: ret_number },
		MethodSpec{ kind: kind_language, name: '_debug_get_stack_level_line', ret: ret_number },
		MethodSpec{ kind: kind_language, name: '_debug_get_stack_level_function', ret: ret_string },
		MethodSpec{ kind: kind_language, name: '_debug_get_stack_level_source', ret: ret_string },
		MethodSpec{ kind: kind_language, name: '_debug_get_stack_level_locals', ret: ret_dictionary },
		MethodSpec{ kind: kind_language, name: '_debug_get_stack_level_members', ret: ret_dictionary },
		MethodSpec{ kind: kind_language, name: '_debug_get_stack_level_instance', ret: ret_pointer },
		MethodSpec{ kind: kind_language, name: '_debug_get_globals', ret: ret_dictionary },
		MethodSpec{ kind: kind_language, name: '_debug_parse_stack_level_expression', ret: ret_string },
		MethodSpec{ kind: kind_language, name: '_debug_get_current_stack_info', ret: ret_array },
		MethodSpec{ kind: kind_language, name: '_reload_all_scripts', ret: ret_none, handler: on_scripts_refresh },
		MethodSpec{ kind: kind_language, name: '_reload_scripts', ret: ret_none, handler: on_scripts_refresh },
		MethodSpec{ kind: kind_language, name: '_reload_tool_script', ret: ret_none, handler: on_scripts_refresh },
		MethodSpec{ kind: kind_language, name: '_get_recognized_extensions', ret: ret_packed_string, handler: on_lang_extensions },
		MethodSpec{ kind: kind_language, name: '_get_public_functions', ret: ret_array },
		MethodSpec{ kind: kind_language, name: '_get_public_constants', ret: ret_dictionary },
		MethodSpec{ kind: kind_language, name: '_get_public_annotations', ret: ret_array },
		MethodSpec{ kind: kind_language, name: '_profiling_start', ret: ret_none },
		MethodSpec{ kind: kind_language, name: '_profiling_stop', ret: ret_none },
		MethodSpec{ kind: kind_language, name: '_profiling_set_save_native_calls', ret: ret_none },
		MethodSpec{ kind: kind_language, name: '_profiling_get_accumulated_data', ret: ret_number },
		MethodSpec{ kind: kind_language, name: '_profiling_get_frame_data', ret: ret_number },
		MethodSpec{ kind: kind_language, name: '_frame', ret: ret_none, handler: on_scripts_refresh },
		MethodSpec{ kind: kind_language, name: '_handles_global_class_type', ret: ret_bool, handler: on_lang_global_type },
		MethodSpec{ kind: kind_language, name: '_get_global_class_name', ret: ret_dictionary, handler: on_lang_global_class },
		MethodSpec{ kind: kind_script, name: '_editor_can_reload_from_file', ret: ret_bool, handler: on_script_reload_file },
		MethodSpec{ kind: kind_script, name: '_can_instantiate', ret: ret_bool, handler: on_script_can_instantiate },
		MethodSpec{ kind: kind_script, name: '_get_base_script', ret: ret_pointer },
		MethodSpec{ kind: kind_script, name: '_get_global_name', ret: ret_string_name, handler: on_script_global },
		MethodSpec{ kind: kind_script, name: '_inherits_script', ret: ret_bool },
		MethodSpec{ kind: kind_script, name: '_get_instance_base_type', ret: ret_string_name, handler: on_script_base },
		MethodSpec{ kind: kind_script, name: '_instance_create', ret: ret_pointer, handler: on_script_instance },
		MethodSpec{ kind: kind_script, name: '_placeholder_instance_create', ret: ret_pointer, handler: on_script_placeholder },
		MethodSpec{ kind: kind_script, name: '_instance_has', ret: ret_bool },
		MethodSpec{ kind: kind_script, name: '_has_source_code', ret: ret_bool, handler: on_script_has_source },
		MethodSpec{ kind: kind_script, name: '_get_source_code', ret: ret_string, handler: on_script_get_source },
		MethodSpec{ kind: kind_script, name: '_set_source_code', ret: ret_none, handler: on_script_set_source },
		MethodSpec{ kind: kind_script, name: '_reload', ret: ret_number, handler: on_script_reload },
		MethodSpec{ kind: kind_script, name: '_get_doc_class_name', ret: ret_string_name },
		MethodSpec{ kind: kind_script, name: '_get_documentation', ret: ret_array },
		MethodSpec{ kind: kind_script, name: '_has_method', ret: ret_bool, handler: on_script_has_method },
		MethodSpec{ kind: kind_script, name: '_has_static_method', ret: ret_bool },
		MethodSpec{ kind: kind_script, name: '_get_method_info', ret: ret_dictionary },
		MethodSpec{ kind: kind_script, name: '_is_tool', ret: ret_bool, handler: on_script_tool },
		MethodSpec{ kind: kind_script, name: '_is_abstract', ret: ret_bool, handler: on_script_abstract },
		MethodSpec{ kind: kind_script, name: '_get_class_icon_path', ret: ret_string, handler: on_script_icon },
		MethodSpec{ kind: kind_script, name: '_is_valid', ret: ret_bool, handler: on_script_valid },
		MethodSpec{ kind: kind_script, name: '_get_language', ret: ret_pointer, handler: on_script_language },
		MethodSpec{ kind: kind_script, name: '_has_script_signal', ret: ret_bool, handler: on_script_has_signal },
		MethodSpec{ kind: kind_script, name: '_get_script_signal_list', ret: ret_array, handler: on_script_signals },
		MethodSpec{ kind: kind_script, name: '_has_property_default_value', ret: ret_bool },
		MethodSpec{ kind: kind_script, name: '_get_property_default_value', ret: ret_variant },
		MethodSpec{ kind: kind_script, name: '_update_exports', ret: ret_none },
		MethodSpec{ kind: kind_script, name: '_get_script_method_argument_count', ret: ret_variant, handler: on_script_arg_count },
		MethodSpec{ kind: kind_script, name: '_get_script_method_list', ret: ret_array, handler: on_script_methods },
		MethodSpec{ kind: kind_script, name: '_get_script_property_list', ret: ret_array, handler: on_script_properties },
		MethodSpec{ kind: kind_script, name: '_get_member_line', ret: ret_number, handler: on_script_member },
		MethodSpec{ kind: kind_script, name: '_get_constants', ret: ret_dictionary },
		MethodSpec{ kind: kind_script, name: '_get_members', ret: ret_array },
		MethodSpec{ kind: kind_script, name: '_is_placeholder_fallback_enabled', ret: ret_bool },
		MethodSpec{ kind: kind_script, name: '_get_rpc_config', ret: ret_variant, handler: on_script_rpc },
		MethodSpec{ kind: kind_loader, name: '_get_recognized_extensions', ret: ret_packed_string, handler: on_loader_extensions },
		MethodSpec{ kind: kind_loader, name: '_handles_type', ret: ret_bool, handler: on_loader_handles },
		MethodSpec{ kind: kind_loader, name: '_get_resource_type', ret: ret_string, handler: on_loader_type },
		MethodSpec{ kind: kind_loader, name: '_recognize_path', ret: ret_bool, handler: on_loader_recognize },
		MethodSpec{ kind: kind_loader, name: '_load', ret: ret_variant, handler: on_loader_load },
		MethodSpec{ kind: kind_saver, name: '_recognize', ret: ret_bool, handler: on_saver_recognize },
		MethodSpec{ kind: kind_saver, name: '_get_recognized_extensions', ret: ret_packed_string, handler: on_saver_extensions },
		MethodSpec{ kind: kind_saver, name: '_recognize_path', ret: ret_bool, handler: on_saver_path },
		MethodSpec{ kind: kind_saver, name: '_save', ret: ret_number, handler: on_saver_save },
	]
}
